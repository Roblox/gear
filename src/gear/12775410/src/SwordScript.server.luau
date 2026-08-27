--// Made by StarWars

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local SwordData = Sword.SwordFunctions.GetData("HeroesAxe")
local SwordModel = Sword.SwordFunctions.GetSword("HeroesAxe")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("Unsheath")
UnsheathSound.Volume = 1
local SlashSound = Handle:WaitForChild("Slash")
SlashSound.Volume = 1

local LastAttack = 0

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	SlashSound:Play()
	Config.Damage.Value = SwordData.Damage.Slash
	SwordData.Functions.Slash(Player, Tool)

	LastAttack = tick()
	wait(1)
	Config.Damage.Value = SwordData.Damage.Base
	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass('Humanoid')
	Torso = Character:FindFirstChild('HumanoidRootPart')
	
	UnsheathSound:Play()
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
