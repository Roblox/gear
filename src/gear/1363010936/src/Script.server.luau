-- // Created by StarWars
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local BeamInfo = TweenInfo.new(0.5)

local Tool = script.Parent
Tool.RequiresHandle = false
local Handle = Tool.Handle
Handle.Name = "Right Gaunlet"

local Remotes = Tool.Remotes
local ClientControls = Remotes.ClientControls
local ServerControls = Remotes.ServerControls

local BASE_GAUNLET = Handle:Clone()
Handle:Destroy()

local Player = nil
local Character = nil
local Humanoid = nil
local LeftGaunlet = nil
local RightGaunlet = nil

local ToolEquipped = false

local RELOAD_TIME = 1
local MAX_LENGTH = 5000
local DAMAGE = 30

local LeftOrRight = 0

local BEAM_COLOR = Color3.fromRGB(98, 239, 243)

local Animations =
{
	R15LeftFire = {Animation = Tool.Animations.R15.LeftFire},
	R15RightFire = {Animation = Tool.Animations.R15.RightFire},
	
	LeftFire = {Animation = Tool.Animations.R6.LeftFire},
	RightFire = {Animation = Tool.Animations.R6.RightFire}	
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

function FireBeam(Start, Endpoint)
	local NewPart = Instance.new("Part")
	NewPart.Material = Enum.Material.Neon
	NewPart.Color = BEAM_COLOR
	local Distance = (Start - Endpoint).Magnitude
	NewPart.Size = Vector3.new(0.2, 0.2, Distance)
	NewPart.CFrame = CFrame.new(Start, Endpoint) * CFrame.new(0, 0, -Distance * 0.5)
	NewPart.Anchored = true
	NewPart.CanCollide = false
	NewPart.Parent = workspace
	
	local FadeAwayTween = TweenService:Create(NewPart, BeamInfo, {Transparency = 1})
	FadeAwayTween:Play()
	
	pcall(function() Debris:AddItem(NewPart, 1) end)

	return NewPart
end

function CheckIfAlive()
	return Player and Character and Humanoid and Humanoid.RootPart and Humanoid.Health > 0
end

function WeldToAttachment(Attach1, Attach2)
	if not Attach1 or not Attach2 then return end
	
	local Motor = Instance.new("Motor6D")
	Motor.Part0 = Attach1.Parent
	Motor.Part1 = Attach2.Parent
	Motor.C0 = Attach1.CFrame
	Motor.C1 = Attach2.CFrame
	
	Motor.Parent = Attach1.Parent	
	
	return Motor
end

Tool.Activated:Connect(function()
	if not Tool.Enabled or not CheckIfAlive() or not RightGaunlet then return end	
	
	Tool.Enabled = false
	
	LeftOrRight = (LeftOrRight + 1) % 2
	
	local BeamAttachment = RightGaunlet:FindFirstChild("BeamAttachment")
	local BeamPosition = RightGaunlet.CFrame.p
	local Animation = Animations.RightFire
	if LeftOrRight == 0 then
		-- left
		BeamAttachment = LeftGaunlet and LeftGaunlet:FindFirstChild("BeamAttachment")
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15LeftFire
		else
			Animation = Animations.LeftFire
		end
	else
		-- right
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15RightFire
		end
	end

	InvokeClient("PlayAnimation", Animation)
	wait(0.1)
	if BeamAttachment then
		BeamPosition = BeamAttachment.WorldPosition
	else
		BeamPosition = RightGaunlet.CFrame.p
	end		
	
	local MouseData = InvokeClient("GetMouseData")
	if MouseData then
		local Hit, Endpoint = RayCast(Humanoid.RootPart.CFrame.p, CFrame.new(Humanoid.RootPart.CFrame.p, MouseData.Position).lookVector, MAX_LENGTH)
		FireBeam(BeamPosition, Endpoint)
		if Hit then
			local ParentTo = Hit.Parent
			if ParentTo then
				if ParentTo:IsA("Accessory") or ParentTo:IsA("Tool") then
					ParentTo = ParentTo.Parent
				end
				
				local HitHumanoid = ParentTo:FindFirstChildOfClass("Humanoid")
				if HitHumanoid then
					HitHumanoid:TakeDamage(DAMAGE)
				end
			end
		end
		
		wait(RELOAD_TIME)
	end
	Tool.Enabled = true
end)

Tool.Equipped:Connect(function()
	if ToolEquipped then return end	
	
	ToolEquipped = true
	
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	local LeftHand = Character:FindFirstChild("LeftHand") or Character:FindFirstChild("Left Arm")
	local RightHand = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")
	
	if LeftHand then
		LeftGaunlet = BASE_GAUNLET:Clone()
		LeftGaunlet.Name = "Left Gaunlet"
		LeftGaunlet.Parent = Tool
		local GripAttachment = LeftGaunlet:FindFirstChild("RightGripAttachment")
		if GripAttachment then
			GripAttachment.Name = "LeftGripAttachment"
		end
		
		WeldToAttachment(GripAttachment, LeftHand:FindFirstChild("LeftGripAttachment"))
	end
	
	if RightHand then
		RightGaunlet = BASE_GAUNLET:Clone()
		RightGaunlet.Parent = Tool
		local GripAttachment = RightGaunlet:FindFirstChild("RightGripAttachment")
		
		WeldToAttachment(GripAttachment, RightHand:FindFirstChild("RightGripAttachment"))
	end
end)

Tool.Unequipped:Connect(function()
	if not ToolEquipped then return end 
	
	ToolEquipped = false
	Character = nil
	Player = nil
	Humanoid = nil
	
	if LeftGaunlet then
		LeftGaunlet:Destroy()
	end
	
	if RightGaunlet then
		RightGaunlet:Destroy()
	end
	
	RightGaunlet = nil
	LeftGaunlet = nil
end)