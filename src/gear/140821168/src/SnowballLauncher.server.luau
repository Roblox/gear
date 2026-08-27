Tool = script.Parent
VELOCITY = 50 -- constant
loaded=false

local Pellet = Instance.new("Part")
Pellet.Size = Vector3.new(1,1,1)
Pellet.Shape = 0
Pellet.BrickColor = BrickColor.new("Institutional white")
Pellet.Material = Enum.Material.Concrete
Pellet.Locked = true
Pellet.TopSurface = 0
Pellet.BottomSurface = 0

script.Parent.SnowballScript:clone().Parent = Pellet





function fire(v, turbo)


-- find player's head pos

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local head = vCharacter:findFirstChild("Head")
	if head == nil then return end

	Tool.Handle.Fire:Play()

	local launch = head.Position + 10 * v

	local missile = Pellet:clone()
    
	missile.Position = launch
	missile.Velocity = v * 100


	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,85,0)
	force.Parent = missile

	missile.SnowballScript.Disabled = false


	missile.Parent = game.Workspace

end

function gunUp()
	Tool.GripForward = Vector3.new(0,.981,-.196)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,.196,.981)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
end


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

	local reload = .1


	gunUp()
	fire(lookAt)
	wait(reload)
	gunOut()
	wait(reload)

	enabled = true

end

script.Parent.Activated:connect(onActivated)
