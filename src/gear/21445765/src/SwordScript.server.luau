--// Made by StarWars

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local SwordData = Sword.SwordFunctions.GetData("Crowbar")
local SwordModel = Sword.SwordFunctions.GetSword("Crowbar")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("Unsheath")
local Smash1Sound = Handle:WaitForChild("Smash1")
local Smash2Sound = Handle:WaitForChild("Smash2")

local LastAttack = 0

function OnActivated()
	local SelectSound = nil
	local Chance = math.random()
	if Chance > 0.5 then
		SelectSound = Smash1Sound
	else
		SelectSound = Smash2Sound
	end
	SelectSound.Pitch = 0.9 + (math.random() * 0.2)
	SelectSound.Volume = 0.7 + (math.random() * 0.3)
	SelectSound:Play()
	Config.Damage.Value = SwordData.Damage.Slash
	SwordData.Functions.Slash(Player, Tool)
	
	LastAttack = tick()
	Config.Damage.Value = SwordData.Damage.Base
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
