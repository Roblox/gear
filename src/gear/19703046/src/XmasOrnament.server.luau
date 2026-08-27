--Updated for R15 avatars by StarWars
Tool = script.Parent
VELOCITY = 80 -- constant
loaded=false

local Pellet =  Tool.Handle:Clone()

Tool.OrnamentScript:clone().Parent = Pellet



function fire(mouse_pos)
	local Character = Tool.Parent
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightUpperArm")
	local RightShoulder = Torso:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")
	RightShoulder.MaxVelocity = 0.7
	RightShoulder.DesiredAngle = 3.6
	wait(.1)
	RightShoulder.MaxVelocity = 1
	Tool.Handle.Transparency=1
	Tool.Handle.Fire:play()

-- find player's head pos

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	--local head = vCharacter:findFirstChild("Head")

	local head = locateHead()
	if head == nil then return end


	--computes a the intended direction of the projectile based on where the mouse was clicked in reference to the head
	local dir = mouse_pos - head.Position
	dir = computeDirection(dir)

	local launch = head.Position + 3 * dir

	local delta = mouse_pos - launch
	
	local dy = delta.y
	
	local new_delta = Vector3.new(delta.x, 0, delta.z)
	delta = new_delta

	local dx = delta.magnitude
	local unit_delta = delta.unit
	
	-- acceleration due to gravity in RBX units
	local g = (-9.81 * 20)

	local theta = computeLaunchAngle( dx, dy, g)

	local vy = math.sin(theta)
	local xz = math.cos(theta)
	local vx = unit_delta.x * xz
	local vz = unit_delta.z * xz
	

	local missile = Pellet:clone()
        
	missile.CanCollide = true
		

	missile.Position = launch
	missile.Velocity = Vector3.new(vx,vy,vz) * VELOCITY

	missile.RotVelocity = Vector3.new(math.random(), math.random(), math.random()).unit * 10
	
	missile.OrnamentScript.Disabled = false

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	missile.Parent = game.Workspace

end

function locateHead()
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	return vCharacter:findFirstChild("Head")
end
	

function computeLaunchAngle(dx,dy,grav)
	-- arcane
	-- http://en.wikipedia.org/wiki/Trajectory_of_a_projectile
	
	local g = math.abs(grav)
	local inRoot = (VELOCITY*VELOCITY*VELOCITY*VELOCITY) - (g * ((g*dx*dx) + (2*dy*VELOCITY*VELOCITY)))
	if inRoot <= 0 then
		return .25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((VELOCITY*VELOCITY) + root) / (g*dx)

	local inATan2 = ((VELOCITY*VELOCITY) - root) / (g*dx)
	local answer1 = math.atan(inATan1)
	local answer2 = math.atan(inATan2)
	if answer1 < answer2 then return answer1 end
	return answer2
end

function computeDirection(vec)
	local lenSquared = vec.magnitude * vec.magnitude
	local invSqrt = 1 / math.sqrt(lenSquared)
	return Vector3.new(vec.x * invSqrt, vec.y * invSqrt, vec.z * invSqrt)
end




Tool.Enabled = true
function onActivated()

	if not Tool.Enabled then
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

	fire(targetPos)

	wait(.8)

	Tool.Enabled = true
	Tool.Handle.Transparency = 0
end

script.Parent.Activated:connect(onActivated)
