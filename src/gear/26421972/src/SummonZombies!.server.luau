Tool = script.Parent

local debris = game:service("Debris")
zombies = 5
reloadTime = 30
Tool.Enabled = true

function fire(targetPos, humanoid)

	insertZombies(targetPos, humanoid)

end

function insertZombies(pos, humanoid)

	amountInFront = 15
	torsoNormal = humanoid.Parent.Torso.CFrame.lookVector
	denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
	posX = amountInFront * (torsoNormal.x/denom)
	posZ = amountInFront * (torsoNormal.z/denom)
	pos = Vector3.new(pos.x + posX,pos.y, pos.z + posZ)

	smoker = Instance.new("Smoke")

	smokeEmitter = Instance.new("Part")
	smokeEmitter.Size = Vector3.new(1,1,1)
	smokeEmitter.Transparency = 1
	smokeEmitter.Position = pos
	smokeEmitter.Anchored = true
	smokeEmitter.CanCollide = false
	
	smoker.Parent = smokeEmitter
	smokeEmitter.Parent = game.Workspace

	debris:AddItem(smokeEmitter, 10)

	wait(1)


	for i = 1, 5 do

		--This call will cause a "wait" until the data comes back
		local root = game:GetService("InsertService"):LoadAsset(26612470)

		local instances = root:GetChildren()
		if #instances == 0 then
			root:Remove()
			return
		end

		--Continue the insert process

		local zombeh = root.SummonedZombie
		zombeh.Owner.Value = humanoid

		local keepYoHead = Instance.new("Weld")
		keepYoHead.Part0 = zombeh.Head
		keepYoHead.Part1 = zombeh.Torso
		keepYoHead.C0 = CFrame.new(0,-1.5,0)
		keepYoHead.Parent = zombeh.Head

		local Robotron = Tool.Robot:clone()
		local Chaser = Tool.ChaseScript:clone()
		local SoundMan = Tool.PlaySounds:clone()
		local GarbageMan = Tool.Timer:clone()
		Chaser.Parent = zombeh
		Robotron.Parent = zombeh
		SoundMan.Parent = zombeh.Head
		GarbageMan.Parent = zombeh
		local spacing = 4
		--game:GetService("InsertService"):Insert(zombeh)
		zombeh.Parent = game.Workspace
		if i == 1 then
			zombeh:moveTo(Vector3.new(pos.x + spacing, pos.y,pos.z + spacing))
		elseif i == 2 then
			zombeh:moveTo(Vector3.new(pos.x - spacing, pos.y,pos.z + spacing))
		elseif i == 3 then
			zombeh:moveTo(Vector3.new(pos.x + spacing, pos.y,pos.z - spacing))
		elseif i == 4 then
			zombeh:moveTo(Vector3.new(pos.x - spacing, pos.y,pos.z - spacing))
		elseif i == 5 then
			zombeh:moveTo(pos)
		end

	end
	
end


function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.GripPos = Vector3.new(0,0.5,0)
	
	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.Parent.Torso.Position

	wait(0.5)
	Tool.GripPos = Vector3.new(0,0,0)

	fire(targetPos, humanoid)
	wait(reloadTime)

	Tool.Enabled = true
end

Tool.Activated:connect(onActivated)
