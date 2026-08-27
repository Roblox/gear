local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local Sounds = {
	Laser = Handle:WaitForChild("LaserSound"),
	SpeedBoost = Handle:WaitForChild("SpeedBoostSound")
}

local ObjectsBin = Handle:WaitForChild("ObjectsBin")

local Anim = ObjectsBin:WaitForChild("FlyAnimation")
local SkullMesh = ObjectsBin:WaitForChild("SkullMesh")

local Speed = {
	CurrentSpeed = 2,
	MaxSpeed = 50
}

local Speeds = {
	NormalSpeed = Speed.MaxSpeed,
	SpeedBoost = (Speed.MaxSpeed + 25)
}

local Laser = {
	ReloadTime = 3,
	Damage = 15,
	Duration = 0.5,
	MaxDistance = 100
}

local SpeedBoost = {
	Debounce = false,
	Duration = 15,
	ReloadTime = 10,
}

local Jumping = {
	JumpTick = 0,
	Jumps = 0,
	JumpTime = 0.25,
	JumpsRequired = 2
}

local Controls = {
	Forward = {
		Number = 0,
		Numbers = {
			On = -1,
			Off = 0
		},
		Keys = {"W", 17}
	},
	Backward = {
		Number = 0,
		Numbers = {
			On = 1,
			Off = 0
		},
		Keys = {"S", 18}
	},
	Left = {
		Number = 0,
		Numbers = {
			On = -1,
			Off = 0
		},
		Keys = {"A", 20}
	},
	Right = {
		Number = 0,
		Numbers = {
			On = 1,
			Off = 0
		},
		Keys = {"D", 19}
	}
}

local FlyRate = (1 / 30)

local Debounce = Instance.new("BoolValue")
Debounce.Value = false

local Debris = game:GetService("Debris")

local Fires = {}
local NeckChangedConnections = {}
local IgnoreHeadChange = false
local Flying = false
local FlyAnim
local DebounceChanged
local Cape

local Player
local Humanoid
local Head
local HumanoidDied
local Torso
local Neck
local NeckOrigin

function DisconnectConnections(Connections)
	for i, v in pairs(Connections) do
		if v and string.lower(tostring(v)) == string.lower("Connection") and string.lower(type(v)) == string.lower("Userdata") and v.connected then
			v:disconnect()
		end
	end
end

function RemoveFlyStuff()
	
	if Player and Torso then
		for i, v in pairs(Torso:GetChildren()) do
			if v and v.Name == "FlightGyro" or v.Name == "FlightVelocity" then
				v:Destroy()
			end
		end
	end
	
	if FlyAnim then
		FlyAnim:Stop()
	end
	
end

function Fly()
	
	if Flying and Player and Torso and Humanoid and Humanoid.Health > 0 then
		
		local Gyro = Instance.new("BodyGyro")
		Gyro.Name = "FlightGyro"
		Gyro.P = (10 ^ 6)
		Gyro.maxTorque = Vector3.new(Gyro.P, Gyro.P, Gyro.P)
		Gyro.cframe = Torso.CFrame
		Gyro.Parent = Torso
		
		local Velocity = Instance.new("BodyVelocity")
		Velocity.Name = "FlightVelocity"
		Velocity.velocity = Vector3.new(0, 0, 0)
		Velocity.P = (10 ^ 4)
		Velocity.maxForce = Vector3.new(1, 1, 1) * (10 ^ 6)
		Velocity.Parent = Torso
		
		if FlyAnim then
			FlyAnim:Stop()
		end
		
		FlyAnim = Humanoid:LoadAnimation(Anim)
		FlyAnim:Play()
		
		local Momentum = Vector3.new(0, 0, 0)
		local LastMomentum = Vector3.new(0, 0, 0)
		local LastTilt = 0
		local CurrentSpeed = Speed.MaxSpeed
		local Inertia = (1 - (Speed.CurrentSpeed / CurrentSpeed))
		
		while Flying and Torso and Humanoid and Humanoid.Health > 0 do
			
			if CurrentSpeed ~= Speed.MaxSpeed then
				CurrentSpeed = Speed.MaxSpeed
				Inertia = (1 - (Speed.CurrentSpeed / CurrentSpeed))
			end
			
			local Direction = game:GetService("Workspace").CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(Controls.Left.Number + Controls.Right.Number, math.abs(Controls.Forward.Number) * 0.2, Controls.Forward.Number + Controls.Backward.Number))
			local Movement = Direction * Speed.CurrentSpeed
			
			Momentum = (Momentum * Inertia) + Movement
			
			local TotalMomentum = Momentum.magnitude
			
			if TotalMomentum > CurrentSpeed then
				TotalMomentum = CurrentSpeed
			end
			
			local Tilt = ((Momentum * Vector3.new(1, 0, 1)).unit:Cross(((LastMomentum * Vector3.new(1, 0, 1)).unit))).y
			local StringTilt = tostring(Tilt)
			
			if StringTilt == "-1.#IND" or StringTilt == "1.#IND" or Tilt == math.huge or Tilt == -math.huge or StringTilt == tostring(0 / 0) then
				Tilt = 0
			end
			
			local AbsoluteTilt = math.abs(Tilt)
			
			if AbsoluteTilt > 0.06 or AbsoluteTilt < 0.0001 then
				if math.abs(LastTilt) > 0.0001 then
					Tilt = (LastTilt * 0.9)
				else
					Tilt = 0
				end
			else
				Tilt = ((LastTilt * 0.77) + (Tilt * 0.25))
			end
			
			LastTilt = Tilt

			if TotalMomentum < 0.5 then
				Momentum = Vector3.new(0, 0, 0)
				TotalMomentum = 0
				Gyro.cframe = game:GetService("Workspace").CurrentCamera.CoordinateFrame
			else
				Gyro.cframe = CFrame.new(Vector3.new(0, 0, 0), Momentum) * CFrame.Angles(0, 0, (Tilt * -20)) * CFrame.Angles((math.pi * -0.5 * (TotalMomentum / CurrentSpeed)), 0, 0)
			end
			
			Velocity.velocity = Momentum
			LastMomentum = Momentum
			Wait(FlyRate)
			
		end
		
		RemoveFlyStuff()
		
	end
end

function CastLaser(StartPosition, Direction, MaxDistance, Ignore)
	
	local function RayCast(Pos, Dir, Max, IgnoreList)
		return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Pos, Dir.unit * (Max or 999.999)), IgnoreList) 
	end
		
	local Hit, EndPosition = RayCast(StartPosition, Direction, MaxDistance, Ignore)
	local Distance = (StartPosition - EndPosition).magnitude
	local LaserPart = Instance.new("Part")
	LaserPart.Name = "Laser"
	LaserPart.BrickColor = BrickColor.new("Bright red")
	LaserPart.Transparency = 0.5
	LaserPart.FormFactor = "Custom" 
	LaserPart.CanCollide = false
	LaserPart.Anchored = true
	LaserPart.Locked = true
	LaserPart.Size = Vector3.new(0.2, 0.2, Distance)
	LaserPart.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, (-Distance / 2))
	Debris:AddItem(LaserPart, Laser.Duration)
	LaserPart.Parent = Player
	
	return Hit, EndPosition
	
end

function SetMouseIcon(Mouse)
	Mouse.Icon = ((not Debounce.Value and "rbxasset://textures\\GunCursor.png") or (Debounce.Value and "rbxasset://textures\\GunWaitCursor.png"))
end

function ResetStuff()
	
	DisconnectConnections({HumanoidDied})
	
	if Flying then
		RemoveFlyStuff()
	end
	
	for i, v in pairs(Fires) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	
	for i, v in pairs(Controls) do
		v.Number = 0
	end
	
	Speed.MaxSpeed = Speeds.NormalSpeed
	Flying = false
	Neck.C1 = NeckOrigin
	
	if Cape and Cape.Parent then
		Cape:Destroy()
		Cape = nil
	end

	local StopSound = Instance.new("StringValue")
	StopSound.Name = "Stop"
	StopSound.Parent = Sounds.SpeedBoost
	
	DisconnectConnections({DebounceChanged})
	Handle.Transparency = 0
	
end

Tool.Equipped:connect(function(Mouse)

	SetMouseIcon(Mouse)
	
	Player = Tool.Parent
	Humanoid = Player:WaitForChild("Humanoid")
	Head = Player:WaitForChild("Head")
	Torso = Player:WaitForChild("Torso")
	Neck = Torso:WaitForChild("Neck")
	NeckOrigin = Neck.C1
	
	HumanoidDied = Humanoid.Died:connect(function()
		ResetStuff()
		Mouse:Destroy()
		Mouse = nil
	end)
	
	Handle.Transparency = 1
	
	if not Cape or not Cape.Parent then
		Cape = Handle:Clone()
		Cape.Name = "Cape"
		Cape.Transparency = 0
		local Weld = Instance.new("Weld")
		Weld.Name = "CapeWeld"
		Weld.Part0 = Torso
		Weld.Part1 = Cape
		Weld.C0 = CFrame.Angles(-0.07, 0.01, 0) + Vector3.new(0, -0.15, 0.5)
		Weld.Parent = Cape
		Cape.Parent = Tool.Parent
	end
	
	DebounceChangedConnection = Debounce.Changed:connect(function()
		SetMouseIcon(Mouse)
	end)
	
	Mouse.Button1Down:connect(function()
		if Humanoid.Health > 0 then
			IgnoreHeadChange = true
			local LastHeadRotation = Neck.C1
			Neck.C1 = NeckOrigin
			local HeadOrigin = Head:Clone()
			local Base = Neck.Part0.Position + (Neck.C0.p * 1)
			local YVector = (Mouse.Hit.p + Mouse.Hit.lookVector)
			local Set = CFrame.new(Base, YVector)
			local Offset = Set:toObjectSpace(Torso.CFrame * Neck.C0)
			local PosX, PosY, PosZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Offset:components()
			Neck.C1 = CFrame.new(NeckOrigin.p.x, NeckOrigin.p.y, NeckOrigin.p.z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
			local HeadClone = Head:Clone()
			local HeadCloneY = HeadClone:Clone()
			HeadCloneY.CFrame = HeadCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
			HeadCloneY.CFrame = HeadCloneY.CFrame + HeadCloneY.CFrame.lookVector * 0.2
			local HeadCloneZ = HeadCloneY:Clone()
			HeadCloneZ.CFrame = HeadCloneZ.CFrame + HeadClone.CFrame.lookVector * (HeadClone.Size.z / 2)
			local HeadRotationCheck = false
			if math.abs((Head.Position - Torso.Position).magnitude) >= 1.25 then
				HeadRotationCheck = true
			else
				Neck.C1 = LastHeadRotation
			end
			IgnoreHeadChange = false
			if HeadRotationCheck and not Debounce.Value and (math.acos((Mouse.Hit.p - HeadOrigin.Position).unit:Dot(HeadOrigin.CFrame.lookVector)) <= (math.pi / 2)) then
				DisconnectConnections(NeckChangedConnections)
				NeckChangedConnections = {}
				Debounce.Value = true
				local PlaySound = Instance.new("StringValue")
				PlaySound.Name = "Play"
				PlaySound.Parent = Sounds.Laser
				for i = 1, 2 do
					local HeadCloneX = HeadCloneZ:Clone()
					HeadCloneX.CFrame = HeadCloneZ.CFrame * CFrame.Angles(0, math.rad(((i == 1 and 90) or (i == 2 and -90))), 0)
					HeadCloneX.CFrame = HeadCloneX.CFrame + HeadCloneX.CFrame.lookVector * 0.2
					local Hit, Position = CastLaser(HeadCloneX.Position, (Mouse.Hit.p - HeadCloneX.Position), Laser.MaxDistance, {Player})
					Hit = (((Hit and Hit.Parent and (Hit.Parent:IsA("Hat") or Hit.Parent:IsA("Tool"))) and Hit.Parent) or Hit)
					if Hit and Hit.Parent then
						for i, v in pairs(Hit.Parent:GetChildren()) do
							if v:IsA("Humanoid") and v.Health > 0 then
								local CreatorTag = Instance.new("ObjectValue")
								CreatorTag.Value = game:GetService("Players"):GetPlayerFromCharacter(Player)
								CreatorTag.Name = "creator"
								Debris:AddItem(CreatorTag, 1)
								CreatorTag.Parent = v
								v:TakeDamage(Laser.Damage)
								if Hit and Hit.Parent and v and v.Health <= 0 then
									for ii, vv in pairs(Hit.Parent:GetChildren()) do
										if vv:IsA("BasePart") then
											if vv.Name ~= "Head" then
												for iii = 1, 2 do
													local Ashes = Instance.new("Part")
													Ashes.Name = "Ashes"
													Ashes.Locked = true
													Ashes.CanCollide = true
													Ashes.Anchored = false
													Ashes.FormFactor = Enum.FormFactor.Custom
													Ashes.TopSurface = Enum.SurfaceType.Smooth
													Ashes.BottomSurface = Enum.SurfaceType.Smooth
													Ashes.Size = Vector3.new(1, 0.4, 1)
													Ashes.Material = Enum.Material.Concrete
													Ashes.BrickColor = BrickColor.new("Really black")
													game:GetService("Debris"):AddItem(Ashes, 5)
													Ashes.Parent = game:GetService("Workspace")
													Ashes.CFrame = vv.CFrame + Vector3.new(0, (iii * Ashes.Size.y), 0)
												end
											else
												local HeadClone = vv:Clone()
												for iii, vvv in pairs(HeadClone:GetChildren()) do
													vvv:Destroy()
												end
												local Skull = SkullMesh:Clone()
												Skull.Parent = HeadClone
												game:GetService("Debris"):AddItem(HeadClone, 5)
												HeadClone.Parent = game:GetService("Workspace")
											end
											vv:Destroy()
										end
									end
								end
							end
						end
					end
				end
				local NeckChanged
				NeckChanged = Neck.Changed:connect(function(Property)
					if Property == "C0" or Property == "C1" and not IgnoreHeadChange then
						DisconnectConnections({NeckChanged})
					end
				end)
				table.insert(NeckChangedConnections, NeckChanged)
				Delay((Laser.Duration * 2), function()
					local StopSound = Instance.new("StringValue")
					StopSound.Name = "Stop"
					StopSound.Parent = Sounds.Laser
					if NeckChanged.connected then
						Neck.C1 = NeckOrigin
					end
				end)
				Wait(Laser.ReloadTime)
				Debounce.Value = false
				SetMouseIcon(Mouse)
			else
				IgnoreHeadChange = true
				Neck.C1 = LastHeadRotation
				IgnoreHeadChange = false
			end
		end
	end)
	
	Mouse.KeyDown:connect(function(Key)
		if Humanoid.Health > 0 then
			local Key = string.lower(Key)
			local ByteKey = string.byte(Key)
			if ByteKey == string.byte(" ") then
				if Flying then
					Flying = false
					RemoveFlyStuff()
				elseif not Flying then
					if (tick() - Jumping.JumpTick) <= Jumping.JumpTime or Jumping.JumpTick == 0 then
						Jumping.JumpTick = tick()
						Jumping.Jumps = Jumping.Jumps + 1
						if Jumping.Jumps >= Jumping.JumpsRequired then
							Jumping.JumpTick = 0
							Jumping.Jumps = 0
							Flying = true
							Fly()
						end
					else
						Jumping.JumpTick = tick()
						Jumping.Jumps = 1
					end
				end
			elseif Key == string.lower("E") and not SpeedBoost.Debounce then
				SpeedBoost.Debounce = true
				Speed.MaxSpeed = Speeds.SpeedBoost
				Fires = {}
				for i = 1, 2 do
					local Fire = Instance.new("Fire")
					Fire.Heat = -25
					Fire.Parent = ((((i == 1 and Player:FindFirstChild("Right Leg")) and Player:FindFirstChild("Right Leg")) or ((i == 2 and Player:FindFirstChild("Left Leg")) and Player:FindFirstChild("Left Leg"))) or nil)
					table.insert(Fires, Fire)
				end
				local PlaySound = Instance.new("StringValue")
				PlaySound.Name = "Play"
				PlaySound.Parent = Sounds.SpeedBoost
				Wait(SpeedBoost.Duration)
				for i, v in pairs(Fires) do
					if v and v.Parent then
						v:Destroy()
					end
				end
				local StopSound = Instance.new("StringValue")
				StopSound.Name = "Stop"
				StopSound.Parent = Sounds.SpeedBoost
				Speed.MaxSpeed = Speeds.NormalSpeed
				Wait(SpeedBoost.ReloadTime)
				SpeedBoost.Debounce = false
			end
		end
		for i, v in pairs(Controls) do
			for ii, vv in pairs(v.Keys) do
				v.Number = ((((string.lower(type(vv)) == string.lower("String") and Key == string.lower(vv)) or (string.lower(type(vv)) == string.lower("Number") and ByteKey == vv)) and v.Numbers.On) or v.Number)
			end
		end
	end)
	
	Mouse.KeyUp:connect(function(Key)
		if Humanoid.Health > 0 then
			local Key = string.lower(Key)
			local ByteKey = string.byte(Key)
			for i, v in pairs(Controls) do
				for ii, vv in pairs(v.Keys) do
					v.Number = ((((string.lower(type(vv)) == string.lower("String") and Key == string.lower(vv)) or (string.lower(type(vv)) == string.lower("Number") and ByteKey == vv)) and v.Numbers.Off) or v.Number)
				end
			end
		end
	end)
	
end)

Tool.Unequipped:connect(function()	
	ResetStuff()
end)