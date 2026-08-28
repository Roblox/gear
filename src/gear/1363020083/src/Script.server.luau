-- // Created by StarWars
local Players = game:GetService("Players")

local GearService = require(1075123174)

local Tool = script.Parent

local Remotes = Tool.Remotes
local ClientControls = Remotes.ClientControls
local ServerControls = Remotes.ServerControls

local ToolEquipped = false

local Player = nil
local Character = nil
local Humanoid = nil
local RightHand = nil
local LeftHand = nil
local CacheWalkSpeed = nil

local BaseLeftClaw = Tool.LeftHand:Clone()
BaseLeftClaw.Anchored = false
BaseLeftClaw.CanCollide = false
BaseLeftClaw.Transparency = 0
BaseLeftClaw.Name = "LeftClaw"
local BaseRightClaw = Tool.Handle:Clone()
BaseRightClaw.Name = "RightClaw"
BaseRightClaw.Anchored = false
BaseRightClaw.CanCollide = false

Tool.Handle:Destroy()

local LeftClaw = nil
local RightClaw = nil

local RELOAD_TIME = 1.5
local CLAW_DAMAGE = 20
local CLAW_LENGTH = 4
local SPEED_BUFF_MODIFIER = 1.5

local Animations =
{
	Swing = {Animation = Tool.Animations.R6.Swing},
	R15Swing = {Animation = Tool.Animations.R15.Swing}
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
	
	local Animation = Animations.Swing
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Swing
	end
	InvokeClient("PlayAnimation", Animation)
	local Hit, Endpoint = RayCast(Humanoid.RootPart.CFrame.p, Humanoid.RootPart.CFrame.lookVector, CLAW_LENGTH)
	if Hit then
		local ParentTo = Hit.Parent
		if ParentTo then
			if ParentTo:IsA("Accessory") or ParentTo:IsA("Tool") then
				ParentTo = ParentTo.Parent
			end
			
			local HitHumanoid = ParentTo:FindFirstChildOfClass("Humanoid")
			if HitHumanoid then
				HitHumanoid:TakeDamage(CLAW_DAMAGE)
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
	RightHand = Character:FindFirstChild("RightHand")
	LeftHand = Character:FindFirstChild("LeftHand")
	
	if CheckIfAlive() then
		CacheWalkSpeed = Humanoid.WalkSpeed
		Humanoid.WalkSpeed = Humanoid.WalkSpeed * SPEED_BUFF_MODIFIER
	end
	
	RightClaw = BaseRightClaw:Clone()
	RightClaw.Parent = Character	
	
	if RightHand then
		RightHand.Transparency = 1
		GearService:WeldToAttachment(RightClaw.aRightWristRigAttachment, RightHand.RightWristRigAttachment)
	else
		local RightArm = Character:FindFirstChild("Right Arm")
		if RightArm then
			local RightGripAttachment = RightArm:FindFirstChild("RightGripAttachment")
			GearService:WeldToAttachment(RightClaw.aRightWristRigAttachment, RightGripAttachment)
		end
	end	

	LeftClaw = BaseLeftClaw:Clone()
	LeftClaw.Parent = Character	
	
	if LeftHand then
		LeftHand.Transparency = 1
		GearService:WeldToAttachment(LeftClaw.aLeftWristRigAttachment, LeftHand.LeftWristRigAttachment)
	else
		local LeftArm = Character:FindFirstChild("Left Arm")
		if LeftArm then
			local LeftGripAttachment = LeftArm:FindFirstChild("LeftGripAttachment")
			GearService:WeldToAttachment(LeftClaw.aLeftWristRigAttachment, LeftGripAttachment)
		end		
	end
end)

Tool.Unequipped:Connect(function()
	if not ToolEquipped then return end 
	ToolEquipped = false
	
	if LeftClaw then
		LeftClaw:Destroy()
	end
	
	if RightClaw then
		RightClaw:Destroy()
	end
	
	if LeftHand then
		LeftHand.Transparency = 0
	end
	
	if RightHand then
		RightHand.Transparency = 0
	end
	
	if CheckIfAlive() then
		Humanoid.WalkSpeed = CacheWalkSpeed		 
	end
	
	Player = nil
	Character = nil
	Humanoid = nil
end)