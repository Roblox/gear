--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

SwooshSound = Handle:WaitForChild("Swoosh")
ExplosionSound = Handle:WaitForChild("Explosion")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

KeyControl = (Tool:FindFirstChild("KeyControls") or Instance.new("RemoteFunction"))
KeyControl.Name = "KeyControls"
KeyControl.Parent = Tool

CameraControl = (Tool:FindFirstChild("CameraControl") or Instance.new("RemoteFunction"))
CameraControl.Name = "CameraControl"
CameraControl.Parent = Tool

Part = Instance.new("Part")
Part.Material = Enum.Material.Plastic
Part.Shape = Enum.PartType.Block
Part.TopSurface = Enum.SurfaceType.Smooth
Part.BottomSurface = Enum.SurfaceType.Smooth
Part.FormFactor = Enum.FormFactor.Custom
Part.CanCollide = true
Part.Locked = true

Rocket = Part:Clone()
Rocket.Name = "Rocket"
Rocket.Size = Vector3.new(1.25, 0.8, 4.75)
Rocket.CanCollide = false
RocketMesh = Instance.new("SpecialMesh")
RocketMesh.MeshType = Enum.MeshType.FileMesh
RocketMesh.MeshId = "http://www.roblox.com/asset?id=169308422"
RocketMesh.TextureId = "http://www.roblox.com/asset?id=169293310"
RocketMesh.Scale = Vector3.new(1, 1, 1)
RocketMesh.Parent = Rocket

SmokePart = Part:Clone()
SmokePart.Name = "SmokePart"
SmokePart.Size = Vector3.new(0.2, 0.2, 0.2)
SmokePart.Transparency = 1
SmokePart.CanCollide = false
Smoke = Instance.new("Smoke")
Smoke.Color = Color3.new((100 / 255), (100 / 255), (100 / 255))
Smoke.Opacity = 0.4
Smoke.RiseVelocity = 0.1
Smoke.Size = 0.1
Smoke.Enabled = false
Smoke.Parent = SmokePart

ChairMeshes = {
	Chair = "http://www.roblox.com/asset?id=169308373",
	ChairWithRockets = "http://www.roblox.com/asset?id=169293184"
}

CamSpeed = {
	X = {Normal = 40, Boost = 80},
	Z = {Normal = 50, Boost = 100},
}

Controls = {
	Forward = false,
	Backward = false,
	Left = false,
	Right = false
}

ReloadTime = 5
ExplosionDamage = 50

Gravity = 196.20
LastSpace = 0

SpeedBoostEnabled = true
SpeedBoostInUse = false
SpeedBoostDuration = 10
SpeedBoostReloadTime = 10

SpeedFire = {}

Equipped = false

Mesh.MeshId = ChairMeshes.ChairWithRockets

KeyControl.OnServerInvoke = (function(Player, Key, Value)
	local OriginalKey = Key
	local Key = Key:lower()
	if OriginalKey == "Button1Down" then
		Button1Down(Value)
	elseif Key == "w" or Key == "" then
		Controls.Forward = Value
	elseif Key == "a" or Key == "" then
		Controls.Left = Value
	elseif Key == "s" or Key == "" then
		Controls.Backward = Value
	elseif Key == "d" or Key == "" then
		Controls.Right = Value
	elseif Key == " " and (LastSpace == 0 or (tick() - LastSpace) > 1.9) and Chair and Chair.Parent then
		local Hit, Position = RayCast(Chair.Position, Vector3.new(0, -1, 0), Chair.Size.Y, {Character})
		if Hit then
			LastSpace = tick()
			local BodyForce = Instance.new("BodyForce")
			BodyForce.force = Vector3.new(0, (((GetTotalMass(Character) * Gravity) * 4) * 1.125), 0)
			Debris:AddItem(BodyForce, 0.1)
			BodyForce.Parent = Chair
		end
	elseif Key == "q" then
		if SpeedBoostEnabled and not SpeedBoostInUse and LeftRocket and LeftRocket.Parent and LeftRocketWeld and LeftRocketWeld.Parent and RightRocket and RightRocket.Parent and RightRocketWeld and RightRocketWeld.Parent then
			SpeedBoostEnabled = false
			SpeedBoostInUse = true
			for i, v in pairs({LeftRocket, RightRocket}) do
				if v and v.Parent then
					local Fire = Instance.new("Fire")
					Fire.Color = Color3.new((255 / 255), (127 / 255), (0 / 255))
					Fire.SecondaryColor = Color3.new((255 / 255), (0 / 255), (0 / 255))
					Fire.Heat = 5
					Fire.Size = 5
					Fire.Enabled = true
					table.insert(SpeedFire, Fire)
					Fire.Parent = v
				end
			end
			wait(SpeedBoostDuration)
			SpeedBoostInUse = false
			for i, v in pairs(SpeedFire) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			SpeedFire = {}
			wait(SpeedBoostReloadTime)
			SpeedBoostEnabled = true
		end
	end	
end)

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

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function HandleMovement(CoordinateFrame)
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	local CoordinateFrame
	local CameraReady = pcall(function()
		CoordinateFrame = CameraControl:InvokeClient(Player)
	end)
	if not CoordinateFrame then
		return
	end
	if (Chair.Position - CoordinateFrame.p).magnitude < 5 then
		FlightPower.velocity = Vector3.new(0, 0, 0)
		FlightSpin.cframe = Chair.CFrame
		return
	end
	if BurnSmoke and BurnSmoke.Parent then
		if Controls.Forward or Controls.Backward or Controls.Left or Controls.Right then
			BurnSmoke.Enabled = true
		else
			BurnSmoke.Enabled = false
		end
	end
	local NewPush = Vector3.new(0, 0, 0)
	local ForwardVector = CoordinateFrame:vectorToWorldSpace(Vector3.new(0, 0, -1))
	
	if Controls.Forward and not Controls.Backward then
		NewPush = (ForwardVector * (((SpeedBoostInUse and CamSpeed.Z.Boost) or CamSpeed.Z.Normal) * 1))
	end
	if Controls.Backward and not Controls.Forward then
		NewPush = (NewPush + ForwardVector * (((SpeedBoostInUse and CamSpeed.Z.Boost) or CamSpeed.Z.Normal) * -1))
	end
	if Controls.Left and not Controls.Right then
		NewPush = (NewPush + CoordinateFrame:vectorToWorldSpace(Vector3.new(-1, 0, 0)) * (((SpeedBoostInUse and CamSpeed.X.Boost) or CamSpeed.X.Normal) * 1))
	end
	if Controls.Right and not Controls.Left then
		NewPush = (NewPush + CoordinateFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)) * (((SpeedBoostInUse and CamSpeed.X.Boost) or CamSpeed.X.Normal) * 1))
	end

	if NewPush.magnitude < 1 then
		FlightPower.maxForce = Vector3.new(0, 0, 0)
	else
		FlightPower.maxForce = Vector3.new((FlightPower.P * 100), 0, (FlightPower.P * 100))
	end
	
	FlightSpin.cframe = CFrame.new(Chair.Position, Vector3.new(CoordinateFrame.p.X, Chair.Position.Y, CoordinateFrame.p.Z)) * CFrame.Angles(0, math.pi, 0)
	
	FlightPower.velocity = NewPush
	
end

function CheckTable(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function CreateChair()
	if Chair and Chair.Parent then
		Chair:Destroy()
	end
	Chair = Handle:Clone()
	Chair.Name = "Chair"
	Chair.Size = Vector3.new(3, 6.5, 4.5)
	Chair.Transparency = 0
	Chair.CanCollide = true
	ChairWeld = Instance.new("Weld")
	ChairWeld.Part0 = Torso
	ChairWeld.Part1 = Chair
	ChairWeld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
	ChairWeld.C1 = CFrame.new(0, 0.4, -0.75) * CFrame.Angles((-math.pi / 2), 0, 0)
	ChairWeld.Parent = Chair
	Chair.Parent = Character
	
	SmokePartClone = SmokePart:Clone()
	SmokePartWeld = Instance.new("Weld")
	SmokePartWeld.Part0 = SmokePartClone
	SmokePartWeld.Part1 = Chair
	SmokePartWeld.C1 = CFrame.new(0, -2.75, 0)
	SmokePartWeld.Parent = SmokePartClone
	SmokePartClone.Parent = Chair
	BurnSmoke = SmokePartClone:FindFirstChild("Smoke")
	
	FlightPower = Instance.new("BodyVelocity")
	FlightPower.Name = "FlightPower"
	FlightPower.velocity = Vector3.new(0, 0, 0)
	FlightPower.P = 1000000
	FlightPower.maxForce = Vector3.new(FlightPower.P, FlightPower.P, FlightPower.P)
	FlightPower.P = 10000
	FlightPower.Parent = Chair
	
	FlightSpin = Instance.new("BodyGyro")
	FlightSpin.Name = "FlightSpin"
	FlightSpin.P = 1000000
	FlightSpin.maxTorque = Vector3.new(FlightSpin.P, FlightSpin.P, FlightSpin.P)
	FlightSpin.cframe = Chair.CFrame
	FlightSpin.Parent = Chair
	
end

function RefuelRockets()
	if SpeedBoostInUse then
		return
	end
	for i, v in pairs({LeftRocket, RightRocket}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if Chair and Chair.Parent then
		LeftRocket = Rocket:Clone()
		LeftRocket.Name = "LeftRocket"
		LeftRocketWeld = Instance.new("Weld")
		LeftRocketWeld.Part0 = LeftRocket
		LeftRocketWeld.Part1 = Chair
		LeftRocketWeld.C1 = CFrame.new(-0.75, -0.925, 0)
		LeftRocketWeld.Parent = LeftRocket
		RightRocket = Rocket:Clone()
		RightRocket.Name = "RightRocket"
		RightRocketWeld = Instance.new("Weld")
		RightRocketWeld.Part0 = RightRocket
		RightRocketWeld.Part1 = Chair
		RightRocketWeld.C1 = CFrame.new(0.75, -0.925, 0)
		RightRocketWeld.Parent = RightRocket
		LeftRocket.Parent = Chair
		RightRocket.Parent = Chair
	end
end

function Reload()
	Tool.Enabled = false
	local ToolEnabled = false
	local ToolChanged
	ToolChanged = Tool.Changed:connect(function(Property)
		if Property == "Enabled" and Tool.Enabled then
			ToolEnabled = true
			ToolChanged:disconnect()
		end
	end)
	wait(ReloadTime)
	if not ToolEnabled then
		RefuelRockets()
		Tool.Enabled = true
	end
end

function Button1Down(TargetPoint)
	if not Tool.Enabled or SpeedBoostInUse then
		return
	end
	local SelectedWeld
	local SelectedRocket
	local OutOfFieldOfView = (math.acos((TargetPoint - Torso.Position).unit:Dot(Chair.CFrame.lookVector)) > 1.25)
	if OutOfFieldOfView then
		return
	end
	if LeftRocket and LeftRocket.Parent and LeftRocketWeld and LeftRocketWeld.Parent then
		SelectedWeld = LeftRocketWeld
		SelectedRocket = LeftRocket
		LeftRocket = nil
	elseif RightRocket and RightRocket.Parent and RightRocketWeld and RightRocketWeld.Parent then
		SelectedWeld = RightRocketWeld
		SelectedRocket = RightRocket
		RightRocket = nil
	end
	if SelectedRocket and SelectedWeld then
		SelectedRocket.CanCollide = true
		local RocketSwoosh = SwooshSound:Clone()
		RocketSwoosh.Parent = SelectedRocket
		local RocketExplosion = ExplosionSound:Clone()
		RocketExplosion.Parent = SelectedRocket
		local BodyForce = Instance.new("BodyForce")
		local Force = (SelectedRocket:GetMass() * Gravity)
		BodyForce.force = Vector3.new(0, Force, 0)
		BodyForce.Parent = SelectedRocket
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new((Force ^ 2), (Force ^ 2), (Force ^ 2))
		BodyGyro.Parent = SelectedRocket
		local Fire = Instance.new("Fire")
		Fire.Color = Color3.new((255 / 255), (127 / 255), (0 / 255))
		Fire.SecondaryColor = Color3.new((255 / 255), (0 / 255), (0 / 255))
		Fire.Heat = 5
		Fire.Size = 2.5
		Fire.Enabled = true
		Fire.Parent = SelectedRocket
		local Smoke = Instance.new("Smoke")
		Smoke.Color = Color3.new((100 / 255), (100 / 255), (100 / 255))
		Smoke.Opacity = 0.5
		Smoke.RiseVelocity = 0.25
		Smoke.Size = 0.1
		Smoke.Enabled = true
		Smoke.Parent = SelectedRocket
		RocketSwoosh:Play()
		Debris:AddItem(SelectedRocket, 3)
		SelectedWeld:Destroy()
		SelectedRocket.Touched:connect(function(Hit)
			if Hit and Hit.Parent then
				local character = FindCharacterAncestor(Hit)
				if (not character or (character and character ~= Character)) then
					RocketSwoosh:Stop()
					RocketExplosion:Play()
					local Explosion = Instance.new("Explosion")
					Explosion.ExplosionType = Enum.ExplosionType.NoCraters
					Explosion.BlastPressure = 0
					Explosion.BlastRadius = 15
					Explosion.Position = SelectedRocket.Position
					local HumanoidsHit = {}
					Explosion.Hit:connect(function(Hit2)
						if Hit2 and Hit2.Parent then
							local character2 = FindCharacterAncestor(Hit2)
							if (not character2 or (character2 and character2 ~= Character)) then
								local HitParent = Hit2.Parent
								if HitParent:IsA("Hat") or HitParent:IsA("Handle") then
									HitParent = HitParent.Parent
								end
								local humanoid = HitParent:FindFirstChild("Humanoid")
								if humanoid and humanoid.Health > 0 and not CheckTable(HumanoidsHit, humanoid) then
									table.insert(HumanoidsHit, humanoid)
									UntagHumanoid(humanoid)
									TagHumanoid(humanoid, Player)
									if (Hit2.Position - Explosion.Position).magnitude <= (Explosion.BlastRadius / 2) then
										humanoid:TakeDamage(humanoid.MaxHealth)
									else
										humanoid:TakeDamage(ExplosionDamage)
									end
								end
								if not character2 then
									Hit2:BreakJoints()
									Hit2.Velocity = CFrame.new(Explosion.Position, Hit2.Position).lookVector * 100
								end
							end
						end
					end)
					Explosion.Parent = game:GetService("Workspace")
					if SelectedRocket and SelectedRocket.Parent then
						SelectedRocket:Destroy()
					end
				end
			end
		end)
		SelectedRocket.Parent = game:GetService("Workspace")
		SelectedRocket.CFrame = SelectedRocket.CFrame + SelectedRocket.CFrame.lookVector * (SelectedRocket.Size.Z * 1.05)
		SelectedRocket.Velocity = CFrame.new(SelectedRocket.Position, TargetPoint).lookVector * 150
		BodyGyro.cframe = CFrame.new(SelectedRocket.Position, TargetPoint)
	end
	if ((not LeftRocketWeld and not RightRocketWeld) or (not LeftRocketWeld.Parent and not RightRocketWeld.Parent)) then
		Reload()
	end
end

function Equipped()

	Unequipped = false
	local UnequippedConnection
	UnequippedConnection = Tool.Unequipped:connect(function()
		Unequipped = true
		UnequippedConnection:disconnect()
	end)

	wait(0.3)
	
	if Unequipped then
		return
	else
		UnequippedConnection:disconnect()
	end
	
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end	
	
	Mesh.MeshId = ChairMeshes.Chair
	
	if not Equipped then
		return
	end
	
	Humanoid.PlatformStand = true
	
	Handle.Transparency = 1	
	
	CreateChair()
	
	local Hit, Position = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2), {Character})
	if Hit then
		Torso.CFrame = Torso.CFrame + Vector3.new(0, (Torso.Size.Y + Chair.Size.Y), 0)
	end

	Spawn(function()
		if not Tool.Enabled then
			Reload()
		else
			RefuelRockets()
		end
	end)
	
	Spawn(function()
		while Equipped and Chair.Parent and FlightPower.Parent and FlightSpin.Parent do
			HandleMovement()
			wait(0.0001)
		end
	end)
	
end

function Unequipped()
	if not Equipped then
		return
	end
	Equipped = false
	SpeedBoostInUse = false
	Mesh.MeshId = ChairMeshes.ChairWithRockets
	if Humanoid and Humanoid.Parent then
		Humanoid.PlatformStand = false
	end
	if Torso and Torso.Parent then
		Torso.Velocity = Vector3.new(0, 0, 0)
	end
	for i, v in pairs(Controls) do
		Controls[i] = false
	end
	if Chair and Chair.Parent then
		Chair:Destroy()
	end
	SpeedFire = {}
	if not LeftRocket or not RightRocket then
		Tool.Enabled = false
	end
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)