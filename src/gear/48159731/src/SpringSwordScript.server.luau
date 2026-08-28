--Fixed by Luckymaxer

Tool = script.Parent
Sword = Tool.Handle
Sparkle = Sword:WaitForChild("Sparkles")

Players = game:GetService("Players")

Growth = Tool:WaitForChild("Growth")

Sparkle.Enabled = false
Tool.Enabled = true

-- damage
damage = 12
-- Sound
local slashSound
local sparkleSound

-- Clone
local sparkleClone
local weldClone

local lock = false

local slashSound = Instance.new("Sound")
slashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
slashSound.Parent = Sword
slashSound.Volume = 1

function blow(hit)	
	if lock == true then 
		return
	end
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	vPlayer = Players:GetPlayerFromCharacter(vCharacter)
	local otherPlayer = Players:GetPlayerFromCharacter(hit.Parent)
	if otherPlayer and (not otherPlayer.Neutral and otherPlayer.TeamColor == vPlayer.TeamColor) then
		return
	end
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then 		
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm ~= nil then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip ~= nil and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then 
				if humanoid.Health >= 0 and humanoid.Health <= damage then 						
					lock = true
					tagHumanoid(humanoid, vPlayer)
					humanoid:TakeDamage(damage)
					wait(1.0)
					untagHumanoid(humanoid)					
					grow()
					damage = damage + 2
					lock = false					
				else			
					tagHumanoid(humanoid, vPlayer)
					humanoid:TakeDamage(damage)					
					wait(1.0)
					untagHumanoid(humanoid)
				end
			end
		end
	end
end


function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then 
		tag = humanoid:FindFirstChild("creator")
		if tag ~= nil then 
			tag:Remove()
		end
	end
end
function grow()	

	if Growth.Value < 6 then			

		local RightArm = Tool.Parent:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		weldClone = RightArm:FindFirstChild("RightGrip")
		if not weldClone then
			return
		end
		Growth.Value = Growth.Value + 1
		Sword.Size = Vector3.new(0.2, 0.31, 3.68) + (Vector3.new(0.046, 0.091, 0.45) * Growth.Value)
		Sword.Mesh.Scale = Vector3.new(1, 1, 1) + (Vector3.new(0.0, 0.066, 0.125) * Growth.Value)		
		if weldClone then weldClone.Parent = Tool.Parent:FindFirstChild("Right Arm") end


		local newWeld = Instance.new("Weld")
		Tool.GripPos =  Tool.GripPos + Vector3.new(0.0, 0.0, -0.14)
		Growth.Value = Growth.Value
		sparkleSound = Sword:FindFirstChild("SparkleSound")
		Sparkle.Enabled = true
		if sparkleSound then sparkleSound:Play() end
		wait(0.75)
		Sparkle.Enabled = false
	end		
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	Tool.Enabled = false		
	slashSound:Play()
	wait(1.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	damage = 12
	Growth.Value = 0
	Sword.Size = Vector3.new(0.2, 0.31, 3.68) 
	Sword.Mesh.Scale = Vector3.new(1, 1, 1) 
	Tool.Grip = CFrame.new(0, 0, -1.2, -1, -0, 0, 0, 0, 1, -0, 1, 0)
	for i, v in pairs({slashSound, sparkleSound}) do
		v:Stop()
	end
	Sparkle.Enabled = false
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)