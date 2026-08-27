local Tool = script.Parent;
local mouse = nil

enabled = true
script.Parent.Enabled = true

local firer = Instance.new("Fire")
firer.Color = Color3.new(1,160/255,51/255)
firer.Size = 8

local PewPew = Tool.Handle:FindFirstChild("PewPew")
if (PewPew == nil) then
	PewPew = Instance.new("Sound")
	PewPew.Name = "PewPew"
	PewPew.SoundId = "http://www.roblox.com/asset/?id=31758982"
	PewPew.Parent = Tool.Handle
	PewPew.Volume = 0
end

function fire(v)
	local vCharacter = Tool.Parent
	if (vCharacter.Name == "Backpack") then return end
	spawnPos = vCharacter.PrimaryPart.Position
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local missile = Instance.new("Part")
	
	firer:Clone().Parent = missile	

	spawnPos  = spawnPos + (v * 2)

	
	missile.Position = spawnPos
	missile.Size = Vector3.new(3.5,3.5,3.5)
	missile.Velocity = v * 20
	missile.Name = "Flame"
	missile.Transparency = 1
	missile.CanCollide = false

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,missile:GetMass()*200,0)
	force.Parent = missile
	--missile.Anchored = true

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile

	--local number_tag = Instance.new("NumberValue")
	--number_tag.Name = "numberTag"
	--number_tag.Parent = missile
	--number_tag.Value = tostring(num)
	
	local new_script = script.Parent.FlameBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace
end



function gunUp()
	--Tool.GripForward = Vector3.new(0,.981,-.196)
	--Tool.GripUp = Vector3.new(0,.196,.981)
	Tool.GripForward = Vector3.new(0, .196, -.981)
	Tool.GripUp = Vector3.new(0, .981, .196) -- -.196
end

function gunOut()
	Tool.GripPos = Vector3.new(0, 0, 1.3)
	Tool.GripForward = Vector3.new(0,0,-1)
	Tool.GripUp = Vector3.new(0,1,0)
end


function onActivated()
	if not script.Parent.Enabled then
		return
	end

	script.Parent.Enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local pauseTime = .10 --.10 --replaced humanoid.Parent.Torso.CFrame below with Workspace.CurrentCamera.CoordinateFrame
	local tempVect = Workspace.CurrentCamera.CoordinateFrame:pointToObjectSpace(humanoid.TargetPoint)
	local oldTargetDepth = tempVect.Z
	-- need to use a CFrame to figure out the orientation of the torso for firing purposes (whether you use spherical projection or simply truncate the z-values as done below)
	--     (just translate below calculations to and from the rotation defined in CFrame of object)

	Workspace.CurrentCamera.CoordinateFrame:pointToObjectSpace(humanoid.TargetPoint)
	
	PewPew.Volume = 1
	PewPew:Play()
	for i = 1,20 do
		local headPos = character.Head.Position
		--local targetPoint = Workspace.CurrentCamera.CoordinateFrame:pointToObjectSpace(humanoid.TargetPoint)
		--if (oldTargetDepth < targetPoint.Z) then targetPoint = Vector3.new(targetPoint.X, targetPoint.Y, oldTargetDepth) end
		--local cf = mouse.Hit
		--targetPoint = targetPoint * 2
		--local v = cf.lookVector
		--targetPoint = Workspace.CurrentCamera.CoordinateFrame:pointToWorldSpace(targetPoint)

		--fire(v.unit)
		--fire((targetPoint-headPos).unit)
		--wait(pauseTime)
		
		--headPos = character.Head.Position
		--targetPoint = Workspace.CurrentCamera.CoordinateFrame:pointToObjectSpace(humanoid.TargetPoint)
		--if (oldTargetDepth < targetPoint.Z) then targetPoint = Vector3.new(targetPoint.X, targetPoint.Y, oldTargetDepth) end
		--cf = mouse.Hit
		--targetPoint = targetPoint * 2
		--v = cf.lookVector
		--targetPoint = Workspace.CurrentCamera.CoordinateFrame:pointToWorldSpace(targetPoint)

		

		local v = (humanoid.TargetPoint - headPos).unit
		if (script.Dir.Value.magnitude > .9 and script.Dir.Value.magnitude < 1.1) then
			v = script.Dir.Value
		end
		fire(v)
		--fire((targetPoint-headPos).unit)
		wait(pauseTime)
		PewPew:Play()
	end
	wait(1)
	gunUp()
	PewPew.Volume = 0

	local reload = 4
	--if (isTurbo(character)) then
	--	reload = .25
	--	print("turbo")
	--end
	wait(reload)
	gunOut()

	script.Parent.Enabled = true
end

function onEquipped(newMouse)
	mouse = newMouse
	--Tool.Handle.EquipSound:play()
	PewPew.Volume = 1
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
