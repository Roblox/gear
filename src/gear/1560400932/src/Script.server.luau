-- // Created by StarWars
local TweenService = game:GetService("TweenService")

local GearService = require(1075123174)

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")
local BaconSound = Handle:FindFirstChild("BaconSound")

local Gear = GearService:BindGear(Tool)
Gear:SetupRemoteFunctions()
Gear:SetupLocalScript("MouseIcon")

local RandomFlip = Random.new()

local ToolEquipped = false

local CurrentTweens = {}

local DefaultMotors = {}
for _, Motor in next, Handle:GetChildren() do
	if Motor:IsA("Motor6D") and Motor.Name == "BaconMotor" then
		DefaultMotors[Motor] = {C0 = Motor.C0, C1 = Motor.C1}
	end
end

local function MoveRightArm(Character)
	if Character then
		local RightUpperArm = Character:FindFirstChild("RightUpperArm")
		local RightLowerArm = Character:FindFirstChild("RightLowerArm")
		local RightHand = Character:FindFirstChild("RightHand")
		if RightUpperArm and RightLowerArm and RightHand then
			local RightShoulder = RightUpperArm:FindFirstChild("RightShoulder")
			local RightElbow = RightLowerArm:FindFirstChild("RightElbow")
			local RightWrist = RightHand:FindFirstChild("RightWrist")
			
			if RightShoulder and RightElbow and RightWrist then
				RightShoulder.Transform = CFrame.Angles(math.rad(45), 0, 0)
				RightElbow.Transform = CFrame.new()
				RightWrist.Transform = CFrame.new()
			end
		end
	end
end

Gear:BindEquippedFunction("frying_pan_equip", function()
	ToolEquipped = true
	if BaconSound then
		BaconSound:Play()
	end	
end)

Gear:BindUnequippedFunction("frying_pan_unequip", function()
	ToolEquipped = false
	if BaconSound then
		BaconSound:Stop()
	end	
	
	for _, Tween in next, CurrentTweens do
		Tween:Cancel()
	end
	
	for Motor, Data in next, DefaultMotors do
		Motor.C0 = Data.C0
		Motor.C1 = Data.C1
	end
	
	CurrentTweens = {}
end)

Gear:BindActivateFunction("frying_pan_activate", function()
	local Animation = Tool.Animations.Toss
	if Gear.Humanoid and Gear.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Tool.Animations.R15Toss
	end
	
	pcall(function()
		Gear.ClientControls:InvokeClient(Gear.Player, "PlayAnimation", {Animation = Animation})
	end)
		
	for _, Motor in next, Handle:GetChildren() do
		if Motor:IsA("Motor6D") and Motor.Name == "BaconMotor" then
			local NewTween = TweenService:Create(Motor, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {C0 = Motor.C0 * CFrame.new(0, 2, 0)})
			local NewIndex = #CurrentTweens + 1
			
			NewTween.Completed:Connect(function(PlaybackState)
				if PlaybackState == Enum.PlaybackState.Completed then
					table.remove(CurrentTweens, NewIndex)
				end
			end)			
			delay(RandomFlip:NextNumber(0.1, 0.5), function()		
				NewTween:Play()
			end)
			table.insert(CurrentTweens, NewTween)
		end
	end
	
	wait(2)
end)