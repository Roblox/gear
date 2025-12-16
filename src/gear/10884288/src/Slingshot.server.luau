Tool = script.Parent
VELOCITY = 50 -- constant
loaded=false

local Pellet = Instance.new("Part")
Pellet.Name="Snowball"
Pellet.Locked = true
Pellet.BackSurface = 0
Pellet.BottomSurface = 0
Pellet.FrontSurface = 0
Pellet.LeftSurface = 0
Pellet.RightSurface = 0
Pellet.TopSurface = 0
Pellet.Shape = 0
Pellet.Size = Vector3.new(1,1,1)
Pellet.BrickColor = BrickColor.new(1)
script.Parent.PelletScript:clone().Parent = Pellet

function fire(mouse_pos)
	local Torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")
	local RightArm = Tool.Parent:FindFirstChild("RightUpperArm")
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

	local head = vCharacter:findFirstChild("Head")
	if head == nil then return end

	local dir = mouse_pos - head.Position
	dir = computeDirection(dir)

	local launch = head.Position + 5 * dir

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
        

	Tool.Handle.Mesh:clone().Parent = missile
		

	missile.Position = launch
	missile.Velocity = Vector3.new(vx,vy,vz) * VELOCITY

	missile.PelletScript.Disabled = false

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vCharacter
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	missile.Parent = game.Workspace

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
	local Torso = Tool.Parent:FindFirstChild("Torso") or Tool.Parent:FindFirstChild("UpperTorso")
	local RightArm = Tool.Parent:FindFirstChild("RightUpperArm")
	local RightShoulder = Torso:FindFirstChild("Right Shoulder") or RightArm:FindFirstChild("RightShoulder")
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
	if loaded==true then
		loaded=false
		local targetPos = humanoid.TargetPoint

		fire(targetPos)
		wait(.2)
		Tool.Enabled = true
	elseif loaded==false then
		RightShoulder.MaxVelocity = 0.6
		RightShoulder.DesiredAngle = -3.6
		wait(.1)
		Tool.Handle.Transparency=0
		wait(.1)
		loaded=true
	end
	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)
