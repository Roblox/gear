--// Made by StarWars
local Players = game:GetService("Players")

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local TridentData = Sword.SwordFunctions.GetData("Trident")
local TridentModel = Sword.SwordFunctions.GetSword("Trident")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, TridentData)

local LastAttack = 0

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	local CacheSpeed = Humanoid.WalkSpeed
	Config.Damage.Value = TridentData.Damage.Attack
	Humanoid.WalkSpeed = 0
	TridentData.Functions.Attack(Player, Tool)	
	
	wait(1)
	Config.Damage.Value = TridentData.Damage.Base
	Humanoid.WalkSpeed = CacheSpeed
	wait(.5)
	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass('Humanoid')
	Torso = Character:FindFirstChild('HumanoidRootPart')
end

function OnUnequipped()
	Player = nil
	Character = nil
	Humanoid = nil
	Torso = nil
end


Tool.Activated:Connect(OnActivated)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
