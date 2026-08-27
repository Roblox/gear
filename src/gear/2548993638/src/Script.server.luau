local Tool = script.Parent
local last_attack = 0
local r = game:service("RunService")
local humanoid = nil

function onTouched(part)

	local h = part.Parent:FindFirstChild("Humanoid")
	if h ~= nil and h ~= humanoid and Tool.Attacking.Value == true then
		h:TakeDamage(5)
	end

end

function onEquipped()
	humanoid = Tool.Parent:FindFirstChild("Humanoid")
end

Tool.Equipped:connect(onEquipped)
Tool.Handle.Touched:connect(onTouched)

function throwTrident()

	wait(0.3)

	local v = (humanoid.TargetPoint - Tool.Parent.Head.Position).unit

	local trident = Tool.Handle:clone()
	trident.CanCollide = true
	trident.Locked = true
	trident.Position = Vector3.new(trident.Position.x,trident.Position.y + 5, trident.Position.z)
	trident.Velocity = v * 70
	trident.CFrame = CFrame.new(trident.Position, humanoid.TargetPoint)
	trident.CFrame = trident.CFrame * CFrame.Angles(math.rad(-90),0,0)

	local script = Tool.TridentScript:clone()
	script.Parent = trident
	script.Disabled = false
	
	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,workspace.Gravity * trident:GetMass() * 0.98,0)
	force.Parent = trident

	Tool.Handle.Transparency = 1
	trident.Name = "Trident"
	trident.Parent = game.Workspace

	wait(4)
	Tool.Handle.Transparency = 0

end

Tool.Enabled = true
function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	t = r.Stepped:wait()

	if (t - last_attack < .2) then
		changeValueTo("throw")
		Tool.Handle.Throw:Play()
		throwTrident()
	else
		Tool.Handle.Stab:Play()
		changeValueTo("stab")
	end

	last_attack = t

	Tool.Enabled = true
	
end

function changeValueTo(string)

	Tool.Action.Value = "changer"
	wait()
	Tool.Action.Value = string
	
end


Tool.Activated:connect(onActivated)
