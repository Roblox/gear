local Tool = script.Parent
local enabled = false
local humanoid = nil
local plushie = nil
local touchCon = nil

function onEquipped()
	humanoid = Tool.Parent:FindFirstChild("Humanoid")
end


function onUnequipped()
	humanoid = nil
end


Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


function onActivated()

	if enabled then
		return
	end

	enabled = true

	local reload = 40

	Tool.Handle.Transparency = 1

	local sound = math.random(3,4)
	if sound == 3 then
		Tool.Handle.Yell1:Play()
	else
		Tool.Handle.Yell2:Play()
	end

	chuckPlushie()
	wait(reload)
	Tool.Handle.Transparency = 0

	enabled = false

end


function onTouched(part)

	touchCon:disconnect()

	if plushie ~= nil then
		plushie.Transparency = 1
		local smoke = Instance.new("Smoke")
		smoke.Parent = plushie
		wait(3)
		plushie:remove()
		plushie = nil
	end

	Tool.CloakPart.Value = part

	local cloakvalue = Tool.CloakPart:clone()
	cloakvalue.Parent = humanoid.Parent

	local cloakscript = Tool.CloakingScript:clone()
	cloakscript.Parent = humanoid.Parent
	cloakscript.Disabled = false

end


function chuckPlushie()

	if humanoid == nil then
		return
	end

	local lookAt = (humanoid.TargetPoint - Tool.Parent.Head.Position).unit

	plushie = Tool.Handle:clone()
	plushie.Name = "NinjaPlushie"
	plushie.Transparency = 0
	plushie.CanCollide = true
	plushie.Position = Vector3.new(plushie.Position.x,plushie.Position.y + 5,plushie.Position.z)
	plushie.Velocity = lookAt * 60
	
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,100,0)
	force.Parent = plushie

	plushie.Parent = game.Workspace

	touchCon = plushie.Touched:connect(onTouched)

end


Tool.Activated:connect(onActivated)