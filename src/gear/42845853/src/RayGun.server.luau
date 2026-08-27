local Tool = script.Parent;

local fireEvent = Tool:WaitForChild('FireEvent')

enabled = true

--local spark = Instance.new("Sparkles")
local spark = Instance.new("Smoke")
spark.Color = Color3.new(0,.5,1)
spark.RiseVelocity = 5
spark.Size = 1
spark.Name = "IceFog"

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	
	spark:Clone().Parent = missile

	local spawnPos = vCharacter.PrimaryPart.Position
	

	
	spawnPos  = spawnPos + (v * 15)

	missile.CFrame = CFrame.new(spawnPos,spawnPos+v)
	missile.Position = spawnPos
	missile.Size = Vector3.new(1,1,15)
	missile.Velocity = v * 100
	missile.RotVelocity = 20*(missile.CFrame:vectorToWorldSpace(Vector3.new(0,0,1)).unit) --spinspinspin, spinspinspin
	--missile.BrickColor = BrickColor.new(1020)
	missile.BrickColor = BrickColor.new("Toothpaste")
	missile.Shape = 1 --0 is ball, 1 is block
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.Name = "Spark"
	missile.Reflectance = .5


	local force = Instance.new("BodyForce")
	--force.force = Vector3.new(0,98,0)
	force.force = Vector3.new(0, 196*missile:GetMass(), 0) --anti-grav it
	force.Parent = missile

	--local angVel = Instance.new("BodyAngularVelocity")
	--angVel.P = 1000
	--angVel.maxTorque = Vector3.new(angVel.P, angVel.P, angVel.P)
	--angVel.angularvelocity = 10*missile.CFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)).unit
	--angVel.Parent = missile

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	missile.Parent = game.Workspace

	local PewPew = Tool.Handle:FindFirstChild("DrinkSound")
	if PewPew ~= nil then PewPew:Play() end
end



function gunUp()
	Tool.GripForward = Vector3.new(0,-.981,.196)
	Tool.GripRight = Vector3.new(-1,0,0)
	Tool.GripUp = Vector3.new(0,.196,.981)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripRight = Vector3.new(-1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function isTurbo(character)
	return character:FindFirstChild("BoltHelm") ~= nil
end


function onActivated(targetPos)
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

	--local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit

	local reload = .2
	--if (isTurbo(character)) then
	--	reload = .25
	--	print("turbo")
	--end

	gunUp()
	fire(lookAt)
	wait(reload)
	gunOut()
	wait(reload)

	enabled = true

end

function onEquipped()
	--Tool.Handle.EquipSound:play()
end

fireEvent.OnServerEvent:connect(function(player, targetPos)
	print('recieved')
	onActivated(targetPos)
end)
--script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
