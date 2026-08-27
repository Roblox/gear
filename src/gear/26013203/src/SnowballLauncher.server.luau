Tool = script.Parent
VELOCITY = 50 -- constant
loaded=false

local Pellet = Instance.new("Part")
Pellet.Size = Vector3.new(1,1,4)
Pellet.Shape = 1
Pellet.BrickColor = BrickColor.new("Pastel light blue")
Pellet.Material = Enum.Material.Ice
Pellet.Locked = true
Pellet.TopSurface = 0
Pellet.Transparency = 0.2
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
	missile.CFrame = CFrame.new(launch,shootDirect)
	missile.Position = launch
	missile.Velocity = v * 60

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,942,0)
	force.Parent = missile

	missile.SnowballScript.Disabled = false


	missile.Parent = game.Workspace

end

function gunUp()
	Tool.GripPos =  Vector3.new(0.3,0,-1.2)
end

function gunOut()
	Tool.GripPos = Vector3.new(0.3,0,-1.5)
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

	local reload = 5


	gunUp()
	fire(lookAt, shootDirect)
	wait(0.1)
	gunOut()
	wait(reload)
	wait(reload)

	enabled = true

end

script.Parent.Activated:connect(onActivated)
