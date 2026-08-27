--// Made by StarWars

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local SwordData = Sword.SwordFunctions.GetData("WoodenMallet")
local SwordModel = Sword.SwordFunctions.GetSword("WoodenMallet")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("Unsheath")
UnsheathSound.Volume = 1
local LungeSound = Handle:WaitForChild("Lunge")
LungeSound.Volume = 0.6
local SlashSound = Handle:WaitForChild("Slash")
SlashSound.Volume = 0.7

local LastAttack = 0
local UsageCount = 4

Handle.Touched:Connect(function(hit)
	if not hit or not hit.Parent then return end
	
	local Humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		UsageCount = UsageCount - 1
		if UsageCount <= 0 then
			Tool:Destroy()
		end
	end
end)

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	--// Check to see if you are double clicking then lunge attack
	SlashSound:Play()
	Config.Damage.Value = SwordData.Damage.Slash
	SwordData.Functions.Slash(Player, Tool)

	
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
