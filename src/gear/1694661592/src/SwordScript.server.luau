--// Made by StarWars

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local SwordData = Sword.SwordFunctions.GetData("Cane")
local SwordModel = Sword.SwordFunctions.GetSword("Cane")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("CaneUnsheath")
local SlashSound = Handle:WaitForChild("CaneSlash")

local LastAttack = 0

local OverrideGrips = {
	Out = Tool.Grip * CFrame.Angles(math.rad(-90), 0, 0),
	Up = Tool.Grip
}

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	--// Check to see if you are double clicking then lunge attack
	
	Config.Damage.Value = SwordData.Damage.Lunge
	SlashSound:Play()
	Tool.Grip = OverrideGrips.Out
	wait(0.4)
	Tool.Grip = OverrideGrips.Up
	
	LastAttack = tick()
	Config.Damage.Value = SwordData.Damage.Base
	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass('Humanoid')
	Torso = Character:FindFirstChild('HumanoidRootPart')
	Humanoid.WalkSpeed = 11
	
	UnsheathSound:Play()
end

function OnUnequipped()
	if Sword.Functions.CheckIfAlive(Character, Humanoid) then
		Humanoid.WalkSpeed = 16
	end
	Player = nil
	Character = nil
	Humanoid = nil
	Torso = nil
end


Tool.Activated:Connect(OnActivated)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
