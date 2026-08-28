local Tool = script.Parent
local Sai = Tool.Handle

Tool.Enabled = true

local vCharacter
local leftSai

local damage = 25

function blow(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil then 
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Sai or rightGrip.Part1 == Sai) then 
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1.0)
				untagHumanoid(humanoid)
			end
		end
	end
end

function blow2(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil then 
		leftArm = vCharacter:FindFirstChild("Left Arm")
		if leftArm then 
			leftGrip = leftArm:FindFirstChild("LeftGrip")
			if leftGrip and (leftGrip.Part0 == leftSai or leftGrip.Part1 == leftSai) then 
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1.0)
				untagHumanoid(humanoid)
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid then 
		tag = humanoid:FindFirstChild("creator")
		if tag then tag:Remove() end
	end
end


function onActivated()
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false

	wait(2.0)	
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent
	leftArm = vCharacter:FindFirstChild("Left Arm")
	if leftArm then 
		leftGrip = leftArm:FindFirstChild("LeftGrip")
		if leftGrip == nil and vCharacter:FindFirstChild("LeftSai") == nil then 
			leftSai = Sai:Clone()
			leftSai.Name = "LeftSai"
			leftSai.Parent = vCharacter

			leftGrip = Instance.new("Weld")
			leftGrip.Parent = leftArm
			leftGrip.Part0 = leftArm
			leftGrip.Part1 =  leftSai
			leftGrip.C1 = (CFrame.new(Vector3.new(0, 0, 0)) * CFrame.Angles(math.pi, 0, math.pi/2)) + Vector3.new(-1.0, 0, -1.0)
			leftGrip.Name = "LeftGrip"

			connection = leftSai.Touched:connect(blow2)
		end

		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		if myHumanoid then 
			myHumanoid.WalkSpeed = 20
		end
	end
end

function onUnequipped()
	if vCharacter then
		leftArm = vCharacter:FindFirstChild("Left Arm")
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
	end
	if leftArm then  
		leftGrip = leftArm:FindFirstChild("LeftGrip")
		leftSai = vCharacter:FindFirstChild("LeftSai")
		if leftGrip then leftGrip:Remove() end
		if leftSai then leftSai:Remove() end
	end

	if connection then connection:disconnect() end

	if myHumanoid then myHumanoid.WalkSpeed = 16 end
	
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sai.Touched:connect(blow)

if leftSai then leftSai.Touched:connect(blow) end
