Tool = script.Parent
VELOCITY = 50 -- constant
loaded=false

local Pellet = Instance.new("Part")
Pellet.Size = Vector3.new(0.5,0.5,0.5)
Pellet.Shape = 0
Pellet.formFactor = 0
Pellet.BrickColor = BrickColor.new(193) -- red-orange
Pellet.Material = Enum.Material.Plastic
Pellet.Locked = true
Pellet.TopSurface = 0
Pellet.BottomSurface = 0

script.Parent.SnowballScript:clone().Parent = Pellet



function fire(v, shootDirect)

-- find player's head pos
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local head = vCharacter:findFirstChild("Head")
	if head == nil then return end

	Tool.Handle.Fire:Play()
	local launch = head.Position + 10 * v

	local missile = Pellet:clone()
	
	if math.random(0,1) == 0 then missile.BrickColor = BrickColor.new(26) end -- want black half the time

	missile.CFrame = CFrame.new(launch,shootDirect)
	missile.Position = launch
	missile.Velocity = v * 200

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,98,0)
	force.Parent = missile

	missile.SnowballScript.Disabled = false


	missile.Parent = game.Workspace

end

function gunUp()
	Tool.GripPos = Vector3.new(0,0,0.8)
end

function gunOut()
	Tool.GripPos = Vector3.new(0,0,1)
end

function onEquipped()

	Tool.Handle.Fire:Stop()

end

function onUnequipped()

	Tool.Handle.Fire:Stop()

end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


enabled = true
function onActivated()
	if not enabled  then
		return
	end

	enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit
	shootDirect = targetPos

	local reload = 0.1


	gunUp()
	fire(lookAt, shootDirect)
	wait(reload)
	gunOut()
	wait(reload)

	enabled = true

end

script.Parent.Activated:connect(onActivated)
