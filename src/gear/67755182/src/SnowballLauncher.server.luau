local Tool = script.Parent
local Cannon = Tool.Handle 
local loaded = false

local snowBall = Instance.new("Part")
snowBall.Size = Vector3.new(1, 1, 1)
snowBall.Shape = 0
snowBall.BrickColor = BrickColor.new("Pastel blue-green")
snowBall.Material = Enum.Material.Concrete
snowBall.Locked = true
snowBall.TopSurface = 0
snowBall.BottomSurface = 0

script.Parent.SnowballScript:clone().Parent = snowBall

local debris = game:GetService("Debris")

function fire(v, turbo)
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local head = vCharacter:findFirstChild("Head")
	if head == nil then return end

	Tool.Handle.Fire:Play()

	local launch = head.Position + 10 * v

	local missile = snowBall:clone()

	missile.Position = launch
	missile.Velocity = v * 100

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0, workspace.Gravity * 0.43, 0)
	force.Parent = missile
	missile.SnowballScript.Disabled = false
	missile.Parent = game.Workspace

	debris:AddItem(missile, 5)
end

function gunUp()
	Tool.GripForward = Vector3.new(0, 0.981, -0.196)
	Tool.GripRight = Vector3.new(-1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0.196, 0.981)
end

function gunOut()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(-1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
end


Tool.Enabled = true
function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit

	local reload = 0.1

	gunUp() 
	wait()
	for i = 1, 5 do 
		targetPos = humanoid.TargetPoint
		lookAt = (targetPos - character.Head.Position).unit
		fire(lookAt)
		wait(0.05) 
	end 
	wait(reload)
	gunOut()
	wait(reload)

	Tool.Enabled = true
end

Tool.Activated:connect(onActivated)
