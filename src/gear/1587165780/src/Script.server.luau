-- // Created by StarWars
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local SpearTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true)

local Tool = script.Parent

local Remotes = Tool.Remotes
local ClientControls = Remotes.ClientControls
local ServerControls = Remotes.ServerControls

local Player = nil
local Character = nil
local Humanoid = nil
local CacheWalkSpeed = nil

local ToolEquipped = false

local RELOAD_TIME = 1.5
local SPEAR_LENGTH = 6
local SPEAR_DAMAGE = 30

local Animations =
{
	Stab = {Animation = Tool.Animations.R6.Stab},
	R15Stab = {Animation = Tool.Animations.R15.Stab}
}

function InvokeClient(Mode, Value)
	local Results = nil
	
	pcall(function()
		Results = ClientControls:InvokeClient(Player, Mode, Value)
	end)
	
	return Results
end

function RayCast(Start, Direction, Length)
	local NewRay = Ray.new(Start, Direction * Length)
	
	return workspace:FindPartOnRayWithIgnoreList(NewRay, {Character})
end

function CheckIfAlive()
	return Player and Character and Humanoid and Humanoid.RootPart and Humanoid.Health > 0
end

Tool.Activated:Connect(function()
	if not Tool.Enabled or not CheckIfAlive() then return end	
	
	Tool.Enabled = false
	
	local Animation = Animations.Stab
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Stab
	end
	InvokeClient("PlayAnimation", Animation)
	local SpearTween = TweenService:Create(Tool, SpearTweenInfo, {GripPos = Vector3.new(0, -4, 0)})
	wait(0.2)
	SpearTween:Play()
	wait(0.4)
	local Hit, Endpoint = RayCast(Humanoid.RootPart.CFrame.p, Humanoid.RootPart.CFrame.lookVector, SPEAR_LENGTH)
	if Hit then
		local ParentTo = Hit.Parent
		if ParentTo then
			if ParentTo:IsA("Accessory") or ParentTo:IsA("Tool") then
				ParentTo = ParentTo.Parent
			end
			
			local HitHumanoid = ParentTo:FindFirstChildOfClass("Humanoid")
			if HitHumanoid then
				HitHumanoid:TakeDamage(SPEAR_DAMAGE)
			end
		end
	end
	
	wait(RELOAD_TIME)
	Tool.Enabled = true
end)

Tool.Equipped:Connect(function()
	if ToolEquipped then return end	
	
	ToolEquipped = true
	
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end)

Tool.Unequipped:Connect(function()
	if not ToolEquipped then return end 	
	
	ToolEquipped = false
	Character = nil
	Player = nil
	Humanoid = nil
end)