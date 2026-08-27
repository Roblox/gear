--// Made by StarWars	--Last touched by Stickmasterluke (8/1/2018)

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
if not Handle then return end

local Sword = require(754568173)

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local SwordData = Sword.SwordFunctions.GetData("Classic")
local SwordModel = Sword.SwordFunctions.GetSword("Classic")
local Config = Sword.SwordFunctions.CreateConfiguration(Tool, SwordData)

local UnsheathSound = Handle:WaitForChild("Unsheath")
local LungeSound = Handle:WaitForChild("Lunge")
local SlashSound = Handle:WaitForChild("Slash")

local LastAttack = 0

local grip = CFrame.new(0, 0.0500000007, 1.64999998, 1, 0, 0, -0, 0.0042520985, 0.999991, 0, -0.999991, 0.0042520985)
local gripOut = grip * CFrame.Angles(math.pi*.5, 0, 0)

local debounce = false
function OnActivated()
	--// Check to see if you are double clicking then lunge attack
	if not debounce then
		debounce = true
		if tick() - LastAttack < 0.2 then
			Config.Damage.Value = SwordData.Damage.Lunge
			LungeSound:Play()
			SwordData.Functions.Lunge(Player, Tool)
			wait(0.2)
			Tool.Grip = gripOut	--SwordData.Grips.Out
			wait(0.6)
			Tool.Grip = grip	--SwordData.Grips.Up
		else
			SlashSound:Play()
			Config.Damage.Value = SwordData.Damage.Slash
			SwordData.Functions.Slash(Player, Tool)
			wait(.5)
		end
		
		LastAttack = tick()
		Config.Damage.Value = SwordData.Damage.Base
		debounce = false
	end
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
