local dGun = script.Parent


--This call will cause a "wait" until the data comes back
local error = true
local danceBomb = nil
while danceBomb == nil do
	error = false
	danceBomb = game:GetService("InsertService"):LoadAsset(45914702)

	local instances = danceBomb:GetChildren()
	if #instances == 0 then
		danceBomb:Remove()
		print("could not create dancebomb")
		error = true
		danceBomb = nil
	else 
		danceBomb = danceBomb:FindFirstChild("DanceBomb")
	end
	--local missile = root:Clone()
	wait()
end

danceBomb.Parent = nil -- should keep DanceBomb model only in memory

-- we had to anchor the parts initially, so they don't accidentally get killed, but now that the model is held in memory, we can remove the anchoring
danceBomb.DanceBall.Anchored = false
danceBomb.MusicBall.Anchored = false

dGun.Enabled = true

function gunUp()
	dGun.GripForward = Vector3.new(0, -.940, 0.342)
	dGun.GripRight = Vector3.new(-1, 0, 0)
	dGun.GripUp = Vector3.new(0, -.342, .940)	
end

function gunDown()
	dGun.GripForward = Vector3.new(0, -1, 0)
	dGun.GripRight = Vector3.new(-1, 0, 0)
	dGun.GripUp = Vector3.new(0, 0, 1)
end

function fire(dPos)
	local vCharacter = dGun.Parent
	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then return end
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position
	
	spawnPos = spawnPos + dPos.unit*10
	--dPos = dPos - dPos.unit * 10
	

	local missile = danceBomb:Clone()

	missile.MusicBall.CFrame=CFrame.new(spawnPos)
	missile.DanceBall.CFrame=CFrame.new(spawnPos)
	missile.MusicBall.Velocity = dPos.unit * 17
	missile.DanceBall.Velocity = dPos.unit * 17
	missile.MusicBall.RotVelocity = Vector3.new(0, 20 - math.random(0, 1)*40, 0)
	missile.DanceBall.RotVelocity = Vector3.new(0, 20 - math.random(0, 1)*40, 0)

	local missileFloat = Instance.new("BodyForce")
	missileFloat.force = Vector3.new(0, (missile.DanceBall:GetMass() + missile.MusicBall:GetMass()) * 196.1, 0)

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile.DanceBall
	
	local new_script = script.Parent.DanceBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile.DanceBall

	missile.Parent = game.Workspace
	missile.DanceBall.MusicBallScript.Disabled = false
	missileFloat.Parent = missile.DanceBall

	confettiBang = dGun.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then 
		confettiBang.Volume = .6
		confettiBang:Play() 
	end
end


function onActivated()
	if not dGun.Enabled  then
		return
	end
	dGun.Enabled = false

	local character = dGun.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		dGun.Enabled = true
		return 
	end

	local reload = 4
	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit
	gunUp()
	fire(lookAt)
	wait(.2)
	gunDown()
	wait(reload)

	confettiBang = dGun.Handle:FindFirstChild("ConfettiBang")
	if confettiBang ~= nil then confettiBang.Volume = 0 end

	dGun.Enabled = true
end

script.Parent.Activated:connect(onActivated)
