--Made by Luckymaxer

Character = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Effect = script:FindFirstChild("Effect")
EatAnimation = script:FindFirstChild("EatAnimation")
EatSound = script:FindFirstChild("EatSound")

function PickUpAndEat(Character)
	if not Character then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	local Torso = Character:FindFirstChild("HumanoidRootPart")
	local RightArm = Character:FindFirstChild("Right Arm")
	if not Humanoid or Humanoid.Health == 0 or not Torso or not RightArm then
		return
	end
	local EffectObject = Effect:Clone()
	local Weld = Create("Weld"){
		Name = "Weld",
		Part0 = RightArm,
		Part1 = EffectObject,
		C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0),
		C1 = CFrame.new(-0.0500000007, -0.200000003, 0.100000001, 0.897661805, 0, -0.440685183, -0.291757196, 0.749456644, -0.594300032, 0.330274463, 0.662053466, 0.67275852), --Effect grip offset
		Parent = EffectObject,
	}
	local Tools = {}
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player then
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				table.insert(Tools, v)
			end
		end
		Humanoid:UnequipTools()
	end
	Debris:AddItem(EffectObject, 5)
	EffectObject.Parent = Character
	local AnimationTrack = Humanoid:LoadAnimation(EatAnimation)
	AnimationTrack:Play()
	wait(1.5)
	local Sound = EatSound:Clone()
	Sound.Parent = EffectObject
	Sound:Play()
	Humanoid.Health = (Humanoid.Health + 15)
	wait(1.5)
	if EffectObject and EffectObject.Parent then
		EffectObject:Destroy()
	end
	for i, v in pairs(Tools) do
		if v and v.Parent then
			Humanoid:EquipTool(v)
		end
	end
end

function DestroyScript()
	Debris:AddItem(script, 1)
end

if not Effect or not Effect.Value or not EatAnimation or not EatSound then
	DestroyScript()
	return
end

Effect = Effect.Value:Clone()

PickUpAndEat(Character)

DestroyScript()