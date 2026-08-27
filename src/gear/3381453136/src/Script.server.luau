--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

VehicleModule = require(Tool:WaitForChild("VehicleModule"))

Controls = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false,
	Up = false,
	Down = false
}

LastSpace = 0

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Hold = {Animation = Tool:WaitForChild("R15Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	--EngineSound = Handle:WaitForChild("Running"),
	Bell = Handle:WaitForChild("Bell")
}

BasePercentageIncrease = 1 --Determins the percentage difference from the base speed

Accelerations = {
	Acceleration = {
		Normal = (10 * BasePercentageIncrease),
		Boost = (30 * BasePercentageIncrease),
	},
	Deceleration = {
		Normal = (10 * BasePercentageIncrease),
		Boost = (30 * BasePercentageIncrease)
	}
}

MaxSpeed = {
	Normal = (100 * BasePercentageIncrease),
}

CurrentMaxSpeed = MaxSpeed.Normal

Acceleration = Accelerations.Acceleration.Normal
Deceleration = Accelerations.Deceleration.Normal

TurnAlpha = (0.30 * BasePercentageIncrease)
AlphaDampening = (0.2 * BasePercentageIncrease)
CurrentSpeed = 0
TurnSpeed = 0

Gravity = 196.20

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

ServerControl.OnServerInvoke = (function(Player, Mode, Value)
	if Mode == "KeyPress" and Value then
		local Key = string.lower(Value.Key)
		local ByteKey = string.byte(Key)
		local Down = Value.Down
		if Key == "w" or ByteKey == 17 then
			Controls.Forward = Down
			while Controls.Forward and ToolEquipped do
				CurrentSpeed = math.min(CurrentMaxSpeed, (CurrentSpeed + (Acceleration * (1 / 30))))
				wait(1 / 30)
			end
		elseif Key == "a" or ByteKey == 20 then
			Controls.Left = Down
			while Controls.Left and ToolEquipped do
				TurnSpeed = math.min(5, (TurnSpeed + (TurnAlpha)))
				wait(1 / 30)
			end
		elseif Key == "s" or ByteKey == 18 then
			Controls.Backward = Down
			while Controls.Backward and ToolEquipped do
				if CurrentSpeed > 0 then
					CurrentSpeed = math.max(-20, (CurrentSpeed - (Deceleration * 2.8 * (1 / 30))))
				else
					CurrentSpeed = math.max(-20, (CurrentSpeed - (Deceleration * (1 / 30))))
				end
				wait(1 / 30)
			end
		elseif Key == "d" or ByteKey == 19 then
			Controls.Right = Down
			while Controls.Right and ToolEquipped do
				TurnSpeed = math.max(-5, (TurnSpeed - (TurnAlpha)))
				wait(1 / 30)
			end
		elseif Key == " " and Down then
			if (LastSpace == 0 or (tick() - LastSpace) > 1.9) then
				LastSpace = tick()
				local BodyForce = Instance.new("BodyForce")
				BodyForce.force = Vector3.new(0, (((GetTotalMass(Character) * Gravity) * 4) * 4), 0)
				Debris:AddItem(BodyForce, 0.1)
				BodyForce.Parent = FakeHandle
			end
		elseif Key == "h" and Down then
			Sounds.Bell:Play()
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function GetTotalMass(Parent)
	local TotalMass = 0
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			TotalMass = TotalMass + v:GetMass()
		end
		GetTotalMass(v)
	end
	return TotalMass
end

function ThrustUpdater()
	--Sounds.EngineSound:Play()
	while ToolEquipped and FakeHandle and FakeHandle.Parent do
		local Direction = Torso.CFrame.lookVector
		Direction = Vector3.new(Direction.x, 0, Direction.z).unit
		ThrustForce.velocity = (Direction * CurrentSpeed)
		--Sounds.EngineSound.Pitch = (1 + (math.abs(CurrentSpeed / 50) * 1))
		
		local DesiredAngle = (999999999 * (-CurrentSpeed / math.abs(CurrentSpeed)))
		local MaxVelocity = (CurrentSpeed / 250)
		if FrontMotor and FrontMotor.Parent then
			FrontMotor.DesiredAngle = DesiredAngle
			FrontMotor.MaxVelocity = MaxVelocity
		end
		if BackMotor and BackMotor.Parent then 
			BackMotor.DesiredAngle = DesiredAngle
			BackMotor.MaxVelocity = MaxVelocity
		end
		
		RotationForce.angularvelocity = Vector3.new(0, TurnSpeed, 0)
		if math.abs(TurnSpeed) > AlphaDampening	 then
			TurnSpeed = (TurnSpeed - (AlphaDampening * (math.abs(TurnSpeed) / TurnSpeed)))
		else 
			TurnSpeed = 0		
		end
		local LeanAmount = (-TurnSpeed * (math.pi / 6) / 4)
		
		if not Controls.Forward or Controls.Backward then
			CurrentSpeed = (CurrentSpeed * 0.99)		
		end
		
		local XZAngle = math.atan2(Torso.CFrame.lookVector.z, 0, Torso.CFrame.lookVector.x)
--		TurnGyro.cframe = CFrame.Angles((LeanAmount * Direction.x), 0, (LeanAmount * Direction.z))
		if LastPosition then
			local NPos = Vector3.new(Torso.CFrame.p.x, 0, Torso.CFrame.p.z)
			local MySpeed = Vector3.new(FakeHandle.Velocity.X, 0, FakeHandle.Velocity.Z).magnitude
			local VelocityDifference = math.abs((MySpeed - (ThrustForce.velocity.magnitude)))
			if MySpeed > 3 and ThrustForce.velocity.magnitude > 3 and VelocityDifference > (0.7 * ThrustForce.velocity.magnitude) then
				CurrentSpeed = (CurrentSpeed * 0.9)
			end
		end
		LastPosition = Vector3.new(Torso.CFrame.p.x, 0, Torso.CFrame.p.z)
		wait(1 / 60)
	end
end

function CheckIfAlive()
	return (Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped()
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		ToolUnequipped:disconnect()
	end)
	wait(0.3)
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	if not CurrentlyEquipped then
		return
	end
	ToolEquipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	
	Spawn(function()
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			InvokeClient("PlayAnimation", Animations.R15Hold)
		else
			InvokeClient("PlayAnimation", Animations.Hold)
		end
		
		Handle.Velocity = Vector3.new(0, 0, 0)
		
		Torso.Velocity = Vector3.new(0, 0, 0)
		
		local Hit, EndPosition = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
		if Hit then
			Torso.CFrame = Torso.CFrame + Vector3.new(0, ((Torso.Size.Y * 2) + Handle.Size.Y), 0)
		end
		
		if FakeHandle and FakeHandle.Parent then
			FakeHandle:Destroy()
		end
		
		Handle.Transparency = 1
		
		FakeHandle = VehicleModule:Clone()
		FrontMotor = FakeHandle:FindFirstChild("FrontMotor")
		BackMotor = FakeHandle:FindFirstChild("BackMotor")
		
		Handle.CFrame = Torso.CFrame
		Humanoid.WalkSpeed = 0
		Humanoid.PlatformStand = true
		
		RotationForce = Instance.new("BodyAngularVelocity")
		RotationForce.maxTorque = Vector3.new(0, math.huge, 0)
		RotationForce.angularvelocity = Vector3.new(0, 0, 0)
		RotationForce.Parent = FakeHandle
		
		ThrustForce = Instance.new("BodyVelocity")
		ThrustForce.maxForce = Vector3.new(math.huge, 0, math.huge)
		ThrustForce.velocity = Vector3.new(0, 0, 0)
		ThrustForce.P = 100
		ThrustForce.Parent = FakeHandle
		
		TurnGyro = Instance.new("BodyGyro")
		TurnGyro.maxTorque = Vector3.new(5000, 0, 5000)
		TurnGyro.P = 300
		TurnGyro.D = 100
		TurnGyro.Parent = FakeHandle
		
		Spawn(function()
			ThrustUpdater()
		end)
			
		LastSpace = tick()
		
		Spawn(function()
			if FakeHandle then
				TorsoWeld = Instance.new("Weld")
				TorsoWeld.C0 = CFrame.new(0, -1.75, -1.55)-- * CFrame.Angles((math.pi / 6), 0, 0)
				TorsoWeld.Part0 = Torso
				TorsoWeld.Part1 = FakeHandle
				TorsoWeld.Parent = FakeHandle
				FakeHandle.CanCollide = true
			end
		end)
		
		if CurrentlyEquipped then
			Torso.CFrame = Torso.CFrame + Vector3.new(0, 1, 0) * (Torso.Size.Y * 2)
			FakeHandle.Parent = Tool
			FakeHandle = Tool:FindFirstChild(FakeHandle.Name)
			for i, v in pairs({"FrontWheel", "BackWheel"}) do
				local Object = FakeHandle:FindFirstChild(v)
				if Object and Object:IsA("BasePart") then
					InvokeClient("SetLocalTransparencyModifier", {Object = Object, Transparency = 0, AutoUpdate = true})
				end
			end
			
			local Limbs = {"Left Arm", "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand", "LeftHand", "LeftLowerArm", "LeftUpperArm"}
			for i, v in pairs(Limbs) do
				local Object = Character:FindFirstChild(v)
				if Object and Object:IsA("BasePart") then
					InvokeClient("SetLocalTransparencyModifier", {Object = Object, Transparency = 0, AutoUpdate = false})
				end
			end
		end
		
	end)
	
end

function Unequipped()
	local CurrentlyEquipped = ToolEquipped
	ToolEquipped = false
	CurrentSpeed = 0
	TurnSpeed = 0
	for i, v in pairs(Controls) do
		Controls[i] = false
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	for i, v in pairs(Sounds) do
		v:Stop()
		InvokeClient("StopSound", v)
	end
	Handle.Transparency = 0
	Handle.Velocity = Vector3.new(0, 0, 0)
	Handle.RotVelocity = Vector3.new(0, 0, 0)
	if Torso then
		Torso.Velocity = Vector3.new(0, -10, 0)
	end
	if Humanoid and Humanoid.Parent and CurrentlyEquipped then
		Humanoid.WalkSpeed = 16
		Humanoid.PlatformStand = false
		Humanoid.Jump = true
	end
end

Tool.Unequipped:connect(Unequipped)
Tool.Equipped:connect(Equipped)