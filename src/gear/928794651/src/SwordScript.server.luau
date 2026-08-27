--// Made by StarWars
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

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
UnsheathSound.Volume = 1
local LungeSound = Handle:WaitForChild("Lunge")
LungeSound.Volume = 0.6
local SlashSound = Handle:WaitForChild("Slash")
SlashSound.Volume = 0.7

local OverrideGrips = {
	Out = CFrame.new(0, -1.5, 0.2, 1, 0, 0, 0, 0, -1, -0, 1, 0),
	Up = CFrame.new(0, -1.5, 0.2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

local SpecialAttackReady = true
local LastAttack = 0
local RangeDamage = 45

function CreateWave()
	SpecialAttackReady = false
	local WedgePart = Instance.new("WedgePart")
	WedgePart.Name = "EffectFlag"
	WedgePart.BrickColor = BrickColor.new("Bright blue")
	WedgePart.Transparency = 0.25
	WedgePart.Size = Vector3.new(10, 3, 6.18)
	WedgePart.CanCollide = false
	WedgePart.TopSurface = "Smooth"
	WedgePart.BottomSurface = "Smooth"
	WedgePart.Velocity = Torso.CFrame.lookVector * 30 
	WedgePart.CFrame = Torso.CFrame * CFrame.new(1.5, 0.5, -3) * CFrame.Angles(math.pi * 0.5, 0, 0)
	
	local Fire = Instance.new("Fire")
	Fire.Color = Color3.new(0, 0.3, 1)
	Fire.SecondaryColor = Color3.new(0.9, 0.95, 1)
	Fire.Size = 15
	Fire.Heat = 3
	Fire.Parent = WedgePart
	
	local BodyForce = Instance.new("BodyForce")
	BodyForce.Force = Vector3.new(0, workspace.Gravity * WedgePart:GetMass(), 0)
	BodyForce.Parent = WedgePart
	WedgePart.Touched:Connect(function(hit)
		if hit and hit.Parent then
			local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if HitHumanoid and HitHumanoid ~= Humanoid then
				HitHumanoid:TakeDamage(RangeDamage)
				WedgePart:Destroy()
			end
		end
	end)
	
	local WaveSound = Handle:FindFirstChild("WaveSound")
	if WaveSound then
		WaveSound:Play()
	end
	
	Debris:AddItem(WedgePart, 1.5)
	WedgePart.Parent = workspace
	delay(10, function()
		SpecialAttackReady = true 
	end)
end

function OnActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false
	--// Check to see if you are double clicking then lunge attack
	if tick() - LastAttack < 0.2 then
		Config.Damage.Value = SwordData.Damage.Lunge
		LungeSound:Play()
		SwordData.Functions.Lunge(Player, Tool)
		wait(0.2)
		Tool.Grip = OverrideGrips.Out
		if SpecialAttackReady then
			CreateWave()
		end
		wait(0.75)
		Tool.Grip = OverrideGrips.Up
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
	Player = Players:GetPlayerFromCharacter(Character)
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
