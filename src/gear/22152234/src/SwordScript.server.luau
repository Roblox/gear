--// Made by StarWars

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local SwordData = Sword.SwordFunctions.GetData("SpiderKnife")
local SwordModel = Sword.SwordFunctions.GetSword("SpiderKnife")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("Unsheath")
local LungeSound = Handle:WaitForChild("Lunge")
local SlashSound = Handle:WaitForChild("Slash")

local LastAttack = 0

function OnActivated()
	--// Check to see if you are double clicking then lunge attack
	if not Tool.Enabled then return end
	Tool.Enabled = false
	if tick() - LastAttack < 0.2 then
		Config.Damage.Value = SwordData.Damage.Lunge
		LungeSound:Play()
		SwordData.Functions.Lunge(Player, Tool)
		wait(0.1)
		Tool.Grip = SwordData.Grips.Out
		wait(0.3)
		Tool.Grip = SwordData.Grips.Up
	else
		SlashSound:Play()
		Config.Damage.Value = SwordData.Damage.Slash
		SwordData.Functions.Slash(Player, Tool)
	end
	
	LastAttack = tick()
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
