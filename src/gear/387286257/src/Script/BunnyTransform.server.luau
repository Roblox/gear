--Made by Luckymaxer
--Updated for R15 avatars by StarWars

local Character = script.Parent
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local PackageMaker = require(836581200)

local InsertService = game:GetService("InsertService")
local Debris = game:GetService("Debris")

local Duration = script:FindFirstChild("Duration")

local BunnyParts = {50383074, 50383173, 50383126, 50383219, 50383252}
local BunnyHat = 50382985

local R15Folder = Instance.new("Folder")
local R6Folder = Instance.new("Folder")
local Hats = {}

function DestroyScript()
	Debris:AddItem(script, 0.5)
end

if not Duration or Duration.Value <= 0 then
	DestroyScript()
	return
end

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("CharacterMesh") then
		v:Clone().Parent = R6Folder
	elseif v:IsA("MeshPart") then
		v:Clone().Parent = R15Folder
	elseif v:IsA("Accessory") then
		table.insert(Hats, v:Clone())
		v:Destroy()
	end	
end

for i, v in pairs(BunnyParts) do
	local BodyPartModel = InsertService:LoadAsset(v)
	PackageMaker.ApplyBodyPart(Character, BodyPartModel.R15, BodyPartModel.R6)
	Debris:AddItem(BodyPartModel, 1)
end

local Hat = InsertService:LoadAsset(BunnyHat)
Debris:AddItem(Hat, 1)
Humanoid:AddAccessory(Hat:GetChildren()[1])

while Duration.Value > 0 do
	local Delay = wait()
	Duration.Value = (Duration.Value - Delay)
end

Humanoid:RemoveAccessories()
for i, v in ipairs(Character:GetChildren()) do
	if v:IsA("CharacterMesh") then
		v:Destroy()
	end
end
PackageMaker.ApplyBodyPart(Character, R15Folder, R6Folder)

for i, v in ipairs(Hats) do
	if Humanoid then
		Humanoid:AddAccessory(v)
	end
end

DestroyScript()