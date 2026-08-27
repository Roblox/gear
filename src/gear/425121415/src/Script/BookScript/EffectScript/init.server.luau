--Made by Luckymaxer

Character = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Effect = script:FindFirstChild("Effect")
LookAtAnimation = script:FindFirstChild("LookAt")
PoofSound = script:FindFirstChild("Poof")

Glasses = {11884330, 221255437, 301820724, 301820310, 125369932, 116778553}

OriginalHats = {}

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	Debris:AddItem(AssetModel, 1)
	return Asset
end

function PickUpAndRead(Character)
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
		C1 = CFrame.new(-0.300000012, -0.200000003, 0, 0, 0, -1, -1, 0, 0, 0, 1, 0), --Effect grip offset
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
	local AnimationTrack = Humanoid:LoadAnimation(LookAtAnimation)
	AnimationTrack:Play(0.25, nil, 0.25)
	wait(1.5)
	local Sound = PoofSound:Clone()
	Sound.Parent = EffectObject
	Sound:Play()
	if EffectObject and EffectObject.Parent then
		EffectObject:Destroy()
	end
	for i, v in pairs(Tools) do
		if v and v.Parent then
			Humanoid:EquipTool(v)
		end
	end
	--[[for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Hat") then
			table.insert(OriginalHats, v)
			v.Parent = nil
		end
	end]]
	local NewHats = {}
	local HatsSelected = {Glasses[math.random(1, #Glasses)]}
	for i, v in pairs(HatsSelected) do
		local NewHat = InsertAsset(v):Clone()
		table.insert(NewHats, NewHat)
		NewHat.Parent = Character
	end
	wait(10)
	for i, v in pairs(NewHats) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(OriginalHats) do
		v.Parent = Character
	end
	OriginalHats = {}
end

function DestroyScript()
	Debris:AddItem(script, 1)
end

if not Effect or not Effect.Value or not LookAtAnimation or not PoofSound then
	DestroyScript()
	return
end

Effect = Effect.Value:Clone()

PickUpAndRead(Character)

DestroyScript()