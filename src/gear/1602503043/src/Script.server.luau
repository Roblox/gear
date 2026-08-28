-- // Created by StarWars
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool.Handle

CollectionService:AddTag(Handle, "Gear_Shield")

local Gear = GearService:BindGear(Tool)
Gear:SetupLocalScript("MouseIcon")
Gear:SetupRemoteFunctions()

local DAMAGE = 25
local DEBOUNCE_TIMER = 1

local Animations = {
	Backhand = {Animation = Tool.Animations.R6.Backhand},
	R15Backhand = {Animation = Tool.Animations.R15.Backhand}		
}

Gear:BindActivateFunction("shield_activate", function()
	local Animation = Animations.Backhand
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Backhand
	end
	
	pcall(function()
		Gear.ClientControls:InvokeClient(Gear.PLayer, "PlayAnimation", Animation)
	end)
	
	local Hit, Endpoint = GearService:CastRay(Gear.RootPart.CFrame.p, Gear.RootPart.CFrame.lookVector, 8, {Gear.Character})
	if Hit and Hit.Parent then
		local ParentTo = Hit.Parent
		if ParentTo:IsA("Tool") or ParentTo:IsA("Accessory") then
			ParentTo = ParentTo.Parent
		end
		
		local HitHumanoid = ParentTo:FindFirstChildOfClass("Humanoid")
		local HitPlayer = Players:GetPlayerFromCharacter(ParentTo)
		local IsTeamMate = false
		if HitPlayer then
			IsTeamMate = GearService:IsTeamMate(Gear.Player, HitPlayer)
		end
		
		if not IsTeamMate and HitHumanoid and HitHumanoid.Health > 0 then
			HitHumanoid:TakeDamage(DAMAGE)
		end
	end
	
	wait(DEBOUNCE_TIMER)
end)