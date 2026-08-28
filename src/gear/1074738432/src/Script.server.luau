--Rescripted by TakeoHonorable
--Fixed Lag-switching issue


local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle",10)

local LeftWing = Tool.LeftWing:Clone()
local RightWing = Tool.RightWing:Clone()
LeftWing.Transparency = 0
RightWing.Transparency = 0

Tool.LeftWing:Destroy()
Tool.RightWing:Destroy()

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil 

local Flying = false

local WingInfo = {
	Right = {
		Flap = CFrame.new(-4.47034836e-08, -0.200000048, 0.300000012, 0.939692616, 0, -0.342020124, 0, 1, 0, 0.342020124, 0, 0.939692616),
		Default = CFrame.new(-5.96046448e-08, -0.200000048, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)		
	},
	Left = {
		Flap = CFrame.new(-4.47034836e-08, -0.200000048, 0.100000054, 0.866025388, 0, 0.5, 0, 1, 0, -0.5, 0, 0.866025388),
		Default = CFrame.new(-5.96046448e-08, -0.200000048, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1)		
	}	
}

local ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

local ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

function WeldAttachments(attachA, attachB)
	local Motor = Instance.new("Motor6D")
	
	Motor.Part0 = attachA.Parent
	Motor.Part1 = attachB.Parent
	
	Motor.C0 = attachA.CFrame 
	Motor.C1 = attachB.CFrame
	Motor.Parent = attachA.Parent
	
	return Motor
end

function OnEquipped()
	Handle.Transparency = 1
	PlayerLeftWing = LeftWing:Clone()
	PlayerRightWing = RightWing:Clone()
	
	local LeftAttachment = PlayerLeftWing.BodyBackAttachment 
	local RightAttachment = PlayerRightWing.BodyBackAttachment
	
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	
	PlayerLeftWing.Parent = Character
	PlayerRightWing.Parent = Character
	
	local BodyBackAttachment = Torso:FindFirstChild("BodyBackAttachment")
	if BodyBackAttachment then 
		LeftMotor = WeldAttachments(LeftAttachment, BodyBackAttachment)
		LeftMotor.Name = "LeftWing"
		LeftMotor.MaxVelocity = 1
		RightMotor = WeldAttachments(RightAttachment, BodyBackAttachment)
		RightMotor.Name = "RightWing"
		RightMotor.MaxVelocity = 1
	end
end

function OnUnequipped()
	Handle.Transparency = 0
	Player = nil
	Character = nil
	Humanoid = nil
	Torso = nil
	Flying = false
	for _, obj in next, {FlightHold, FlightPower, FlightSpin, LeftMotor, RightMotor, PlayerLeftWing, PlayerRightWing} do 
		if obj and obj.Parent then
			obj:Destroy()
		end
	end	 
end

function OnActivated()
	if not Tool.Enabled then return end 
	Tool.Enabled = false 
	Flying = not Flying
	
	if Flying then 
		FlightSpin = Instance.new("BodyGyro")
		FlightSpin.Name = "FlightSpin"
		FlightSpin.P = 1000000
		FlightSpin.MaxTorque = Vector3.new(FlightSpin.P, FlightSpin.P, FlightSpin.P)
		FlightSpin.CFrame = Torso.CFrame
		
		FlightPower = Instance.new("BodyVelocity")
		FlightPower.Name = "FlightPower"
		FlightPower.Velocity = Vector3.new(0, 0, 0)
		FlightPower.P = 1000000
		FlightPower.MaxForce = Vector3.new(FlightPower.P, FlightPower.P, FlightPower.P)
		FlightPower.P = 10000
		
		FlightHold = Instance.new("BodyPosition")
		FlightHold.Name = "FlightHold"
		FlightHold.P = 100000
		FlightHold.MaxForce = Vector3.new(0, 0, 0)
		FlightHold.Position = Torso.Position
		
		FlightSpin.Parent = Torso
		FlightPower.Parent = Torso
		FlightHold.Parent = Torso
		
		spawn(function()
			local function Animate()
				if LeftMotor and RightMotor and LeftMotor.Parent and RightMotor.Parent then 				
					local Info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
					
					local LeftFlapGoals = {C1 = WingInfo.Left.Flap}
					local RightFlapGoals = {C1 = WingInfo.Right.Flap}
					local DefaultGoals = {C1 = WingInfo.Right.Default}
					
					local LeftTween = TweenService:Create(LeftMotor, Info, LeftFlapGoals)
					local RightTween = TweenService:Create(RightMotor, Info, RightFlapGoals)
					
					local DefaultLeftTween = TweenService:Create(LeftMotor, Info, DefaultGoals)
					local DefaultRightTween = TweenService:Create(RightMotor, Info, DefaultGoals)
					
					LeftTween:Play()
					RightTween:Play()
					RightTween.Completed:wait()
					if LeftMotor and RightMotor and LeftMotor.Parent and RightMotor.Parent then  	
						DefaultLeftTween:Play()
						DefaultRightTween:Play()
						DefaultRightTween.Completed:wait()
					end 
				end 
			end
			
			while Flying do
				Animate()	
				RunService.Heartbeat:Wait()		
			end
		end)
		
	elseif not Flying then 
		Torso.Velocity = Vector3.new(0, 0, 0)
		Torso.RotVelocity = Vector3.new(0, 0, 0)
		
		for _, obj in next, {FlightHold, FlightPower, FlightSpin} do 
			if obj and obj.Parent then
				obj:Destroy()
			end
		end
	end 
	
	wait(2)
	Tool.Enabled = true 
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)
Tool.Activated:Connect(OnActivated)