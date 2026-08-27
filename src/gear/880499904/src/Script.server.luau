--// Made by StarWars
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local SwordData = Sword.SwordFunctions.GetData("BladeOfTheFederation")
local SwordModel = Sword.SwordFunctions.GetSword("BladeOfTheFederation")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("Unsheath")
local LungeSound = Handle:WaitForChild("Lunge")
local SlashSound = Handle:WaitForChild("Slash")

local LastAttack = 0

function OnActivated()
	--// Check to see if you are double clicking then lunge attack
	Handle.Trail.Enabled = true 
	local ClickTime = RunService.Stepped:wait()
	print(ClickTime - LastAttack)
	if ClickTime - LastAttack < 0.2 then
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

	Handle.Trail.Enabled = false 	
	LastAttack = ClickTime
	Config.Damage.Value = SwordData.Damage.Base
end

function OnEquipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass('Humanoid')
	Torso = Character:FindFirstChild('HumanoidRootPart')
	Handle.Trail.Enabled = false 
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