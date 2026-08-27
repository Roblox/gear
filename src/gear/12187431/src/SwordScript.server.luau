--// Made by StarWars

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local SwordData = Sword.SwordFunctions.GetData("Scimitar")
local SwordModel = Sword.SwordFunctions.GetSword("Scimitar")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("Unsheath")
UnsheathSound.Volume = 1
local LungeSound = Handle:WaitForChild("Lunge")
LungeSound.Volume = 0.6
local SlashSound = Handle:WaitForChild("Slash")
SlashSound.Volume = 0.7

local LastAttack = 0

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	--// Check to see if you are double clicking then lunge attack
	if tick() - LastAttack < 0.2 then
		Config.Damage.Value = SwordData.Damage.Lunge
		LungeSound:Play()
		SwordData.Functions.Lunge(Player, Tool)
		wait(0.2)
		Tool.Grip = SwordData.Grips.Out
		wait(0.75)
		Tool.Grip = SwordData.Grips.Up
	else
		SlashSound:Play()
		Config.Damage.Value = SwordData.Damage.Slash
		SwordData.Functions.Slash(Player, Tool)
	end
	
	LastAttack = tick()
	Config.Damage.Value = SwordData.Damage.Base
	wait(0.5)
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
