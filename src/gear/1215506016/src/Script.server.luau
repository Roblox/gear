-- // Created by StarWars
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool.Handle

local Slash1 = Handle:WaitForChild("Slash1")

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local Remotes = Tool:WaitForChild("Remotes")
local AnimationsFolder = Tool:WaitForChild("Animations")
local ClientControls = Remotes:WaitForChild("ClientControls")

local Animations = {OverheadSwing = {Animation = AnimationsFolder:WaitForChild("R6"):WaitForChild("OverHeadSwing")}}

local MAX_SWING_DISTANCE = 6
local DAMAGE = 25
local BLEEDING_DAMAGE = 40
local FROZEN_TIME = 5

local function CreateIceBlock(target)
	-- Can't take frozen damage twice while being frozen
	if CollectionService:HasTag(target, "frozen_player") then return end 
	local DamagePerTick = BLEEDING_DAMAGE / 10
	local TargetHumanoid = target:FindFirstChildOfClass("Humanoid")	
	local TargetPlayer = Players:GetPlayerFromCharacter(target)
	
	if GearService:IsTeamMate(TargetPlayer, Gear.Player) then return end 	
	
	local CacheWalkSpeed = 16
	local CacheJumpPower = 50
	
	if TargetHumanoid then
		spawn(function()
			for i = 1, 10 do
				TargetHumanoid:TakeDamage(DamagePerTick)
				wait(0.3)
			end
		end)
		
		CacheWalkSpeed = TargetHumanoid.WalkSpeed
		CacheJumpPower = TargetHumanoid.JumpPower
		TargetHumanoid.WalkSpeed = 0
		TargetHumanoid.JumpPower = 0
	end
	
	local IcePart = Instance.new("Part")
	IcePart.Material = Enum.Material.Ice 
	IcePart.Size = target:GetExtentsSize() + Vector3.new(2, 2, 2)
	IcePart.Transparency = 0.5
	IcePart.Parent = target
	
	local Motor6D = Instance.new("Motor6D")
	Motor6D.C0 = CFrame.new(0, 0, 0)
	Motor6D.C1 = CFrame.new(0, 0, 0)
	Motor6D.Part0 = target:FindFirstChild("HumanoidRootPart")
	Motor6D.Part1 = IcePart
	Motor6D.Parent = IcePart 
	
	Debris:AddItem(IcePart, FROZEN_TIME)
	delay(FROZEN_TIME, function()
		if target and CollectionService:HasTag(target, "frozen_player") then
			CollectionService:RemoveTag(target, "frozen_player")
			if TargetHumanoid then
				TargetHumanoid.WalkSpeed = CacheWalkSpeed
				TargetHumanoid.JumpPower = CacheJumpPower
			end
		end
	end)
	
	CollectionService:AddTag(target, "frozen_player")
end

Gear:BindEquippedFunction("halberd_equipped", function()
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animations = {OverheadSwing = {Animation = AnimationsFolder:WaitForChild("R15"):WaitForChild("OverHeadSwing")}}	
	else
		Animations = {OverheadSwing = {Animation = AnimationsFolder:WaitForChild("R6"):WaitForChild("OverHeadSwing")}}	
	end
end)

Gear:BindActivateFunction("halberd_activate", function()
	pcall(function() ClientControls:InvokeClient(Gear.Player, "PlayAnimation", Animations.OverheadSwing) end)
	pcall(function() ClientControls:InvokeClient(Gear.Player, "PlaySound", Slash1) end)

	local Hit, Endpoint = GearService:CastRay(Gear.RootPart.Position, Gear.RootPart.CFrame.lookVector, MAX_SWING_DISTANCE, {Gear.Character})
	
	if Hit and Hit.Parent then
		local ParentTo = Hit.Parent
		if ParentTo:IsA("Accessory") then
			ParentTo = ParentTo.Parent
		end
		
		local HitHumanoid = ParentTo:FindFirstChildOfClass("Humanoid")
		if HitHumanoid then
			delay(0.2, function() HitHumanoid:TakeDamage(DAMAGE) end)
		end
		
		CreateIceBlock(ParentTo)
	end	
	
	wait(1)
end)