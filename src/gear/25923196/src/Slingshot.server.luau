Tool = script.Parent
VELOCITY = 85 -- constant
FIRERATE = 2

local Pellet = Instance.new("Part")
Pellet.Locked = true
Pellet.BackSurface = 0
Pellet.BottomSurface = 0
Pellet.FrontSurface = 0
Pellet.LeftSurface = 0
Pellet.RightSurface = 0
Pellet.TopSurface = 0
Pellet.Shape = 0
Pellet.Size = Vector3.new(1,1,1)
Pellet.BrickColor = BrickColor.new("Reddish brown")
Pellet.Material = Enum.Material.CorrodedMetal
script.Parent.PelletScript:clone().Parent = Pellet
script.Parent.PlantScript:clone().Parent = Pellet
plantSound = Tool.Handle.PlantSound:clone()
plantSound.Parent = Pellet

function fire(mouse_pos)


	Tool.Handle.SlingshotSound:play()

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
        

		

	missile.Position = launch
	missile.Velocity = Vector3.new(vx,vy,vz) * VELOCITY

	missile.PelletScript.Disabled = false

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

	Tool.GripPos = Vector3.new(0,-0.5,0.5)
	
	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint

	fire(targetPos)
	wait(0.5)
	Tool.GripPos = Vector3.new(0,0,0.5)
	wait(FIRERATE - 0.5)

	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)


