--Made by Luckymaxer
local Display = script.Parent:FindFirstChild("Display")
if Display then
	Display:Destroy()
end

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")


Players = game:GetService("Players")
Debris = game:GetService("Debris")

Assets = require(Tool:WaitForChild("Assets"))
Data = Assets.Data

BaseUrl = Assets.BaseUrl

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Anchored = false
BasePart.CanCollide = true
BasePart.Locked = true

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil},
	R15Hold = {Animation = Tool:WaitForChild("R15Hold"), FadeTime = nil, Weight = nil, Speed = nil}
}

Sounds = {
	Honk = Handle:WaitForChild("Honk"),
	Engine = Handle:WaitForChild("Running")
}

Controls = {
	Forward = {Key = "w", ByteKey = 17, Mode = false},
	Backward = {Key = "s", ByteKey = 18, Mode = false},
	Left = {Key = "a", ByteKey = 20, Mode = false},
	Right = {Key = "d", ByteKey = 19, Mode = false}
}
	
Rate = (1 / 60)
	
Gravity = 196.20
	
PoseOffset = CFrame.new(0.1, -2.95, -0.25) * CFrame.Angles(0, 0, 0) --The offset your character is from the center of the vehicle.

SpeedBoost = {
	Allowed = false,
	Active = false,
	Enabled = true,
	Duration = 10,
	ReloadTime = 30
}

Special = {
	Allowed = false,
	Enabled = true,
	Active = false,
	Duration = 0,
	ReloadTime = 60
}

Speed = {
	Acceleration = {
		Normal = 20,
		Boost = 35
	},
	Deceleration = {
		Normal = 20,
		Boost = 35
	},
	MovementSpeed = {
		Normal = {Min = 20, Max = 70},
		Boost = {Min = 35, Max = 100}
	},
	TurnSpeed = {
		Speed = {Min = 5, Max = 5},
		TurnAlpha = 0.30,
		AlphaDampening = 0.2
	},
}

MaxSpeed = { --Maximum speed which the vehicle can move and turn at.
	Movement = Speed.MovementSpeed.Normal,
	Turn = Speed.TurnSpeed.Speed,
	Acceleration = Speed.Acceleration.Normal,
	Deceleration = Speed.Deceleration.Normal
}

CurrentSpeed = { --The speed which the vehicle is moving and turning at.
	Movement = 0,
	Turn = 0
}

Honk = {
	Honking = false,
	LastHonk = 0,
	ReloadTime = 1
}

Jump = {
	Jumping = false,
	LastJump = 0,
	ReloadTime = 1.9,
	JumpForce = 30
}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function EnableFirstPersonView()
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	local Limbs = {"Left Arm", "Right Arm", "LeftHand", "LeftUpperArm", "LeftLowerArm", "RightHand", "RightUpperArm", "RightLowerArm"}
	for i, v in pairs(Limbs) do
		local Limb = Character:FindFirstChild(v)
		if Limb and Limb:IsA("BasePart") then
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = Limb, Transparency = 0, AutoUpdate = false})
			end)
		end
	end
end

function WeldAttachment(attach1, attach2)
	local Weld = Instance.new("Weld")
	Weld.Part0 = attach1.Parent
	Weld.Part1 = attach2.Parent
	Weld.C0 = attach1.CFrame
	Weld.C1 = attach2.CFrame 
	Weld.Parent = attach1.Parent 

	return Weld 
end 

function ThrustUpdater()
	
	for i, v in pairs(CurrentSpeed) do
		CurrentSpeed[i] = 0
	end
	for i, v in pairs(Controls) do
		Controls[i].Mode = false
	end
	
	local SmallHoverNumber = 0
	local TurnAngle = 0
	local TurnRate = 0.025
	local MaxTurnAngle = 0.125

	while ToolEquipped and Body and Body.Parent and CheckIfAlive() and RotationForce and RotationForce.Parent and ThrustForce and ThrustForce.Parent and TurnGyro and TurnGyro.Parent do
		
		RotationForce.angularvelocity = Vector3.new(0, CurrentSpeed.Turn, 0)
		if math.abs(CurrentSpeed.Turn) > Speed.TurnSpeed.AlphaDampening then
			CurrentSpeed.Turn = (CurrentSpeed.Turn - (Speed.TurnSpeed.AlphaDampening * (math.abs(CurrentSpeed.Turn) / CurrentSpeed.Turn)))
		else 
			CurrentSpeed.Turn = 0		
		end
				
		if not Controls.Forward.Mode or Controls.Backward.Mode then --Slow down if not controlling.
			CurrentSpeed.Movement = (CurrentSpeed.Movement * 0.99)
		end
		
		local MySpeed = Vector3.new(Body.Velocity.X, 0, Body.Velocity.Z).magnitude
		local VelocityDifference = math.abs((MySpeed - (ThrustForce.velocity.magnitude)))
		if MySpeed > 3 and ThrustForce.velocity.magnitude > 3 and VelocityDifference > (0.7 * ThrustForce.velocity.magnitude) then
			CurrentSpeed.Movement = (CurrentSpeed.Movement * 0.9)
		end
		
		if Controls.Forward.Mode then --Handle acceleration
			CurrentSpeed.Movement = math.min(MaxSpeed.Movement.Max, (CurrentSpeed.Movement + (MaxSpeed.Acceleration * Rate)))
		end
		if Controls.Backward.Mode then --Handle deceleration, if speed is more than 0, decrease quicker.
			CurrentSpeed.Movement = math.max(-MaxSpeed.Movement.Min, (CurrentSpeed.Movement - (MaxSpeed.Deceleration * ((CurrentSpeed.Movement > 0 and 2.8) or 1) * Rate)))
		end
		
		if Controls.Left.Mode then --Handle left turn speed
			CurrentSpeed.Turn = math.min(Speed.TurnSpeed.Speed.Max, (CurrentSpeed.Turn + (Speed.TurnSpeed.TurnAlpha)))
		end
		if Controls.Right.Mode then --Handle right turn speed
			CurrentSpeed.Turn = math.max(-Speed.TurnSpeed.Speed.Min, (CurrentSpeed.Turn - (Speed.TurnSpeed.TurnAlpha)))
		end
		
		local Direction = Torso.CFrame.lookVector
		Direction = Vector3.new(Direction.x, 0, Direction.z).unit
		
		local Velocity = (Direction * CurrentSpeed.Movement) --The thrust force which you move.
		ThrustForce.velocity = Vector3.new(Velocity.X, ThrustForce.velocity.Y, Velocity.Z)
		
		local LeanAmount = (-CurrentSpeed.Turn * (math.pi / 6) / 4) --Amount your character leans over.
		local XZAngle = math.atan2(Torso.CFrame.lookVector.z, 0, Torso.CFrame.lookVector.x) --Handle rotation
		TurnGyro.cframe = CFrame.Angles((LeanAmount * Direction.x), 0, (LeanAmount * Direction.z))
		
		--Wheel animation
		local DesiredAngle = (999999999 * (-CurrentSpeed.Movement / math.abs(CurrentSpeed.Movement)))
		local MaxVelocity = (CurrentSpeed.Movement / 250)
		for i, v in pairs({FrontMotor, BackMotor}) do
			if v and v.Parent then
				v.DesiredAngle = DesiredAngle
				v.MaxVelocity = MaxVelocity
			end
		end
		
		--Animate hover effects
		SmallHoverNumber = (SmallHoverNumber >= 24 and 1 or (SmallHoverNumber + 1))		
		
		for i, v in pairs(HoverParts) do
			if v:IsA("BasePart") then
				local Weld = v:FindFirstChild("Weld")
				if Weld then
					if string.find(v.Name, "SmallHoverPiece") then
						local Multiplier = tonumber(string.sub(v.Name, (string.len("SmallHoverPiece") + 1), string.len(v.Name)))
						Weld.C0 = (Weld.C0 + Vector3.new(0, (((SmallHoverNumber <= 12 and -0.0025) or 0.0025) * ((Multiplier * 2 * -1) + 1) * 1), 0))
					elseif string.find(v.Name, "TopHoverPiece") then
						local Multiplier = tonumber(string.sub(v.Name, (string.len("TopHoverPiece") + 1), string.len(v.Name)))
						Weld.C0 = (Weld.C0 + Vector3.new(0, (((SmallHoverNumber <= 12 and -0.0025) or 0.0025) * ((Multiplier * 2 * -1) + 1.25) * 1), 0))
					elseif string.find(v.Name, "BottomHoverPiece") then
						local Multiplier = tonumber(string.sub(v.Name, (string.len("BottomHoverPiece") + 1), string.len(v.Name)))
						Weld.C0 = (Weld.C0 + Vector3.new(0, (((SmallHoverNumber <= 12 and -0.0025) or 0.0025) * ((Multiplier * 2 * -1) + 1.25) * -1), 0))
					end
				end
			end
		end
		
		if Controls.Left.Mode or Controls.Right.Mode then
			TurnAngle = (TurnAngle + (((Controls.Left.Mode and not Controls.Right.Mode) and TurnRate) or ((not Controls.Left.Mode and Controls.Right.Mode) and -TurnRate) or (Controls.Left.Mode and Controls.Right.Mode) and 0))
		else
			if math.abs(TurnAngle) < TurnRate then
				TurnAngle = 0
			else
				TurnAngle = (TurnAngle + (TurnRate * ((TurnAngle > 0 and -1) or 1)))
			end
		end
		TurnAngle = ((TurnAngle > MaxTurnAngle and MaxTurnAngle) or (TurnAngle < -MaxTurnAngle and -MaxTurnAngle) or TurnAngle)
		--HandleBarsWeld.C0 = CFrame.new(HandleBarsWeld.C0.p) * CFrame.Angles(0, TurnAngle, 0)
		
		--Smoke exhaust from vehicle running.
		for i, v in pairs(ExhaustSmoke) do
			if v and v.Parent then
				v.Opacity = ((math.min(math.abs(CurrentSpeed.Movement), 10) / 10) * 0.5)
			end
		end
		
		--Engine running sound which pitch changes while in motion.
		Sounds.Engine.Pitch = (1 + (math.abs(CurrentSpeed.Movement / MaxSpeed.Movement.Max) * 1.8)) --Thanks to Europeancow2 for the perfect hoverboard sound effect!!!
		
		wait(Rate)
		
	end
end

function SpawnVehicle()
	
	Handle.Transparency = 1
	local Animation = Animations.Hold
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15Hold
	end
	Spawn(function()
		InvokeClient("PlaySound", Sounds.Engine)
		InvokeClient("PlayAnimation", Animation)
	end)	
	
	Humanoid.PlatformStand = true
	
	local VehicleData = Assets.CreateVehicle()
	Body = VehicleData.Vehicle
	local ParticleTable = VehicleData.Tables
	
	--FrontMotor = Body.FrontMotor
	--BackMotor = Body.BackMotor
	
--	HandleBars = Body.HandleBars
--	HandleBarsWeld = HandleBars.Weld
	
	ExhaustSmoke = ParticleTable.ExhaustSmoke
	Lights = ParticleTable.Lights
	Sparkles = ParticleTable.Sparkles
	HoverParts = ParticleTable.HoverParts
	
	for i, v in pairs(Body:GetChildren()) do
		if v:IsA("BasePart") and v.Transparency < 1 then
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = v, Transparency = v.Transparency, AutoUpdate = true})
			end)
		end
	end
	
	for i, v in pairs(Lights) do
		if v and v.Parent then
			v.Enabled = true
		end
	end
	
	if SpeedBoost.Active then
		for i, v in pairs(Sparkles) do
			if v and v.Parent then
				v.Enabled = true
			end
		end
	end
	
	Body.CanCollide = true

	RotationForce = Instance.new("BodyAngularVelocity")
	RotationForce.maxTorque = Vector3.new(0, math.huge, 0)
	RotationForce.angularvelocity = Vector3.new(0, 0, 0)
	RotationForce.Parent = Torso
	
	ThrustForce = Instance.new("BodyVelocity")
	ThrustForce.maxForce = Vector3.new(math.huge, 0, math.huge)
	ThrustForce.velocity = Vector3.new(0, 0, 0)
	ThrustForce.P = 100
	ThrustForce.Parent = Torso
	
	TurnGyro = Instance.new("BodyGyro")
	TurnGyro.maxTorque = Vector3.new(5000, 0, 5000)
	TurnGyro.P = 300
	TurnGyro.D = 100
	TurnGyro.Parent = Torso
	
	Body.Parent = Tool
	
	--[[
	local RayHit, RayPos, RayNormal = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
	if RayHit then
		Torso.CFrame = Torso.CFrame + Vector3.new(0, ((Character:GetModelSize().Y / 2) + 1.5), 0)
	end
	]]
	
	local LowerTorso = Character:FindFirstChild("LowerTorso") or Character:FindFirstChild("HumanoidRootPart")
	if LowerTorso then 
		local TorsoAttachment = LowerTorso:FindFirstChild("RootRigAttachment")
		local BodyAttachment = Body:FindFirstChild("RootRigAttachment")
		if BodyAttachment then 
			if TorsoAttachment then 
				WeldAttachment(TorsoAttachment, Body.RootRigAttachment)
			else
				local NewWeld = Instance.new("Weld")
				NewWeld.Part0 = LowerTorso
				NewWeld.Part1 = Body 
				NewWeld.C0 = CFrame.new()
				NewWeld.C1 = BodyAttachment.CFrame 
				NewWeld.Parent = Body 
			end
		end
	end
	
	Spawn(ThrustUpdater)
	
end

function FreezePlayer()
	if CheckIfAlive() then
		local FreezePart = BasePart:Clone()
		FreezePart.Name = "FreezePart"
		FreezePart.Transparency = 1
		FreezePart.Anchored = true
		FreezePart.CanCollide = false
		local FreezeWeld = Instance.new("Weld")
		FreezeWeld.Part0 = Torso
		FreezeWeld.Part1 = FreezePart
		FreezeWeld.Parent = FreezePart
		Debris:AddItem(FreezePart, 0.125)
		FreezePart.Parent = Character
		Torso.Velocity = Vector3.new(0, -25, 0)
		Torso.RotVelocity = Vector3.new(0, 0, 0)
	end
end

function CleanUp()
	Handle.Velocity = Vector3.new(0, 0, 0)
	Handle.RotVelocity = Vector3.new(0, 0, 0)
	for i, v in pairs({Body, RotationForce, ThrustForce, TurnGyro}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	Spawn(CleanUp)
	Spawn(EnableFirstPersonView)
	Spawn(SpawnVehicle)
	ToolEquipped = true
end

function Unequipped()
	Spawn(CleanUp)
	Spawn(FreezePlayer)
	for i, v in pairs(Sounds) do
		v:Stop()
		Spawn(function()
			InvokeClient("StopSound", v)
		end)
	end
	if CheckIfAlive() then
		Humanoid.PlatformStand = false
	end
	Handle.Transparency = 0
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
		if mode == "KeyPress" then
			local Down = value.Down
			local Key = value.Key
			local ByteKey = string.byte(Key)
			for i, v in pairs(Controls) do
				if Key == v.Key or ByteKey == v.ByteKey then
					Controls[i].Mode = Down
				end
			end
			if Key == " " and Down then --Jump controller
				if math.abs(tick() - Jump.LastJump) > Jump.ReloadTime and not Jump.Jumping and ThrustForce and ThrustForce.Parent then
					Jump.Jumping = true
					local Parts = GetAllConnectedParts(Body)
					local Mass = 0
					for i, v in pairs(Parts) do
						Mass = (Mass + v:GetMass())
					end
					ThrustForce.maxForce = Vector3.new(ThrustForce.maxForce.X, ((Mass * Gravity) * 100), ThrustForce.maxForce.Z)
					ThrustForce.velocity = (Vector3.new(0, 1, 0) * Jump.JumpForce) + Vector3.new(ThrustForce.velocity.X, 0, ThrustForce.velocity.Z)
					wait(0.1)
					ThrustForce.maxForce = Vector3.new(ThrustForce.maxForce.X, 0, ThrustForce.maxForce.Z)
					ThrustForce.velocity = Vector3.new(ThrustForce.velocity.X, 0, ThrustForce.velocity.Z)
					Jump.LastJump = tick()
					Jump.Jumping = false
				end
			--[[elseif Key == "x" and Down then --Toggle light(s) on/off.
				for i, v in pairs(Lights) do
					if v and v.Parent then
						v.Enabled = not v.Enabled
					end
				end]]
			elseif Key == "h" and Down then --Play honk sound.
				local Sound = Sounds.Honk
				if (tick() - Honk.LastHonk) >= (Sound.TimeLength + Honk.ReloadTime) and not Honk.Honking then
					Honk.Honking = true
					local TempSound = Sound:Clone()
					Debris:AddItem(TempSound, Sound.TimeLength)
					TempSound.Parent = Body
					TempSound:Play()
					Honk.LastHonk = tick()
					Honk.Honking = false
				end
			elseif Key == "q" and Down then --Activate special.
				if not Special.Allowed or not Special.Enabled or Special.Active then
					return
				end
				Special.Enabled = false
				Special.Active = true
				wait(Special.Duration)
				Special.Active = false
				wait(Special.ReloadTime)
				Special.Enabled = true
			elseif ByteKey == 48 and Down then --Activate speed boost.
				if not SpeedBoost.Allowed or not SpeedBoost.Enabled or SpeedBoost.Active then
					return
				end
				SpeedBoost.Enabled = false
				SpeedBoost.Active = true
				for i, v in pairs(Sparkles) do
					if v and v.Parent then
						v.Enabled = true
					end
				end
				MaxSpeed.Acceleration = Speed.Acceleration.Boost
				MaxSpeed.Deceleration = Speed.Deceleration.Boost
				MaxSpeed.Movement = Speed.MovementSpeed.Boost
				wait(SpeedBoost.Duration)
				MaxSpeed.Acceleration = Speed.Acceleration.Normal
				MaxSpeed.Deceleration = Speed.Deceleration.Normal
				MaxSpeed.Movement = Speed.MovementSpeed.Normal
				for i, v in pairs(Sparkles) do
					if v and v.Parent then
						v.Enabled = false
					end
				end
				SpeedBoost.Active = false
				wait(SpeedBoost.ReloadTime)
				SpeedBoost.Enabled = true
			end
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

Spawn(CleanUp)

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
workspace:GetPropertyChangedSignal("Gravity"):Connect(function()
	Gravity = workspace.Gravity
end)