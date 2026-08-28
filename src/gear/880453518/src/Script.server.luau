-- // Created by StarWars
local Players = game:GetService("Players")

local Tool = script.Parent
Tool.Grip = Tool.Handle.RightGripAttachment.CFrame
local Remotes = Tool.Remotes
local ServerControls = Remotes.ServerControls
local ClientControls = Remotes.ClientControls

local ToolEquipped = false

local Player = nil
local Character = nil
local Humanoid = nil

local Animations = 
{
	Hold = {Animatiojn = Tool.Animations.R6.Hold},
	Stab = {Animation = Tool.Animations.R6.Stab, Speed = 2},
	R15Hold = {Animation = Tool.Animations.R15.Hold},
	R15Stab = {Animation = Tool.Animations.R15.Stab, Speed = 2}
}

local RELOAD_TIME = 1
local MELEE_RANGE = 3
local MELEE_DAMAGE = 30
local MELEE_HEAD_MULT = 4

function InvokeClient(Mode, Value)
	local Result = nil
	
	pcall(function()
		Result = ClientControls:InvokeClient(Player, Mode, Value)
	end)
	
	return Result
end

function CheckIfAlive()
	return Player and Character and Humanoid and Humanoid.RootPart and Humanoid.Health > 0 
end

function RayCast(Start, Direction, Length)
	local NewRay = Ray.new(Start, Direction * Length)
	
	local Hit, Endpoint = workspace:FindPartOnRayWithIgnoreList(NewRay, {Character})
	
	return Hit, Endpoint
end

Tool.Activated:Connect(function()
	if not Tool.Enabled or not CheckIfAlive() then return end
	
	Tool.Enabled = false
	local Animation = Animations.Stab
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Stab
	end
	
	local Hit, Endpoint = RayCast(Humanoid.RootPart.CFrame.p, Humanoid.RootPart.CFrame.lookVector, MELEE_RANGE)
	if Hit and Hit.Parent then
		local ParentTo = Hit.Parent
		if ParentTo:IsA("Accessory") or ParentTo:IsA("Tool") then
			ParentTo = ParentTo.Parent
		end
		
		local HitHumanoid = ParentTo:FindFirstChildOfClass("Humanoid")
		if HitHumanoid then
			local Damage = MELEE_DAMAGE
			if Hit.Name == "Head" then
				-- Headshot!
				Damage = Damage * MELEE_HEAD_MULT
			end
			HitHumanoid:TakeDamage(Damage)
		end
	end
	InvokeClient("PlaySound", Tool.Handle.StabSound)
	InvokeClient("PlayAnimation", Animation)
	wait(RELOAD_TIME)
	Tool.Enabled = true
end)

Tool.Equipped:Connect(function()
	if ToolEquipped then return end
	ToolEquipped = true

	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
end)

Tool.Unequipped:Connect(function()
	if not ToolEquipped then return end
	ToolEquipped = false
	
	Character = nil
	Humanoid = nil
	Player = nil
end)