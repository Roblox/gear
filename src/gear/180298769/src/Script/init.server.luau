--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Animations = {
	ArmsOut = Tool:WaitForChild("ArmsOut"),
	R15ArmsOut = Tool:WaitForChild("R15ArmsOut")
}

Sounds = {
	Handle:WaitForChild("Squeak1"),
	Handle:WaitForChild("Squeak2"),
	Handle:WaitForChild("Squeak3")
}

BatManagement = script:WaitForChild("BatManagement")
DirectionsGui = script:WaitForChild("DirectionsGui")

Damage = 5
MaxEnemyDistance = 100

Special = {
	Duration = 15,
	ReloadTime = 15,
	Ready = true,
	Active = false,
}

Gravity = 196.20

Bats = {}
LastSoundPlayed = 0

BatTarget = nil
BatBoundaries = nil

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Handle.Transparency = 0

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and CheckIfAlive() --[[and BatsReady]] then
		if Mode == "MouseClick" and Value.Down and Value.Target and Value.Target.Parent and not Special.Active then
			local character = Value.Target.Parent
			if character:IsA("Accessory") or character:IsA("Tool") then
				character = character.Parent
			end
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				local head = character:FindFirstChild("Head")
				if humanoid and humanoid.Health > 0 and head and (head.Position - Head.Position).magnitude <= MaxEnemyDistance then
					SetTarget(head)
				elseif Head and Head.Parent then
					SetTarget(Head)
				end
			end
		elseif Mode == "KeyPress" and Value.Down and Value.Key == "q" and Special.Ready and not Special.Active then
			CurrentCharacter = Character
			CurrentPlayer = Player
			CurrentHumanoid = Humanoid
			CurrentHead = Head
			CurrentTorso = Torso
			CurrentHumanoid.WalkSpeed = 0
			Special.Ready = false
			Special.Active = true
			local Animation = Animations.ArmsOut
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				Animation = Animations.R15ArmsOut
			end
			InvokeClient("PlayAnimation", {Animation = Animation, FadeTime = 1, Weight = 1, Speed = 1})
			local TotalBatCount = #Bats
			local BatCount = 0
			local CurrentlyEquipped = true
			if UnequippedConnection then
				UnequippedConnection:disconnect()
			end
			UnequippedConnection = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
				if UnequippedConnection then
					UnequippedConnection:disconnect()
				end
			end)
			wait(2)
			if not CurrentlyEquipped then
				return
			end
			local CurrentPlayerGui = CurrentPlayer:FindFirstChild("PlayerGui")
			if CurrentPlayerGui then
				DirectionsGuiClone = DirectionsGui:Clone()
				Debris:AddItem(DirectionsGuiClone, (Special.Duration + 5))
				DirectionsGuiClone.Parent = CurrentPlayerGui
			end
			InvokeClient("SetCameraType", Enum.CameraType.Attach)
			RotationGyro = Instance.new("BodyGyro")
			RotationGyro.Name = "RotationGyro"
			RotationGyro.maxTorque = Vector3.new(0, math.huge, 0)
			for i = 1, 10 do
				if not CurrentlyEquipped then
					return
				end
				for ii, v in pairs(Bats) do
					if v.Bat and v.Bat.Parent then
						v.Bat.Transparency = (0.1 * i)
						if v.Bat.Transparency >= 1 then
							v.Bat:Destroy()
						end
					end
				end
				wait(0.1)
			end
			if CurrentlyEquipped then
				for i, v in pairs(Bats) do
					if v.Bat and v.Bat.Parent then
						v.Bat:Destroy()
					end
				end
				
				local LeftArm = CurrentCharacter:FindFirstChild("LeftUpperArm")
				local LeftShoulder = CurrentTorso:FindFirstChild("Left Shoulder") or (LeftArm and LeftArm:FindFirstChild("LeftShoulder"))
				if LeftShoulder and LeftShoulder.Part1 and LeftShoulder.Part1.Parent then
					LeftArm = LeftShoulder.Part1
				end
				local RightArm = CurrentCharacter:FindFirstChild("RightUpperArm")
				local RightShoulder = CurrentTorso:FindFirstChild("Right Shoulder") or (RightArm and RightArm:FindFirstChild("RightShoulder"))
				if RightShoulder and RightShoulder.Part1 and RightShoulder.Part1.Parent then
					RightArm = RightShoulder.Part1
				end
				if not LeftArm and not RightArm then
					return
				end
				RotationGyro.Parent = Torso
				local BeginTick = tick()
				local BatSpawnTick = 0
				local BatSpawnDelay = 0.025
				local LaunchedBats = {}
				Spawn(function()
					while Special.Active and CurrentlyEquipped do
						if #LaunchedBats > 0 then
							for i, v in pairs(LaunchedBats) do
								if type(v) ~= "table" then
									LaunchedBats[i] = {Bat = v, Angle = math.random(1, 2)}
									v = LaunchedBats[i]
								end
								if v.Bat and v.Bat.Parent then
									v.Bat.CFrame = v.Bat.CFrame * CFrame.Angles(0, 0, ((math.random(1, 5) * 0.5) * ((v.Angle == 1 and 1) or -1)))
								else
									table.remove(LaunchedBats, i)
								end
							end
						end
						wait()
					end
				end)
				while (tick() - BeginTick) <= Special.Duration and LeftShoulder and LeftShoulder.Parent and LeftArm and LeftArm.Parent and RightShoulder and RightShoulder.Parent and RightArm and RightArm.Parent and CurrentlyEquipped do
					local TargetPosition = InvokeClient("TargetPosition", nil)
					RotationGyro.cframe = CFrame.new(Torso.Position, TargetPosition)
					if (BatSpawnTick == 0 or (tick() - BatSpawnTick) >= BatSpawnDelay) then
						BatSpawnTick = tick()
						if LeftShoulder and LeftShoulder.Parent and LeftArm and LeftArm.Parent then
							local LeftBat = LaunchBat(LeftArm)
							table.insert(LaunchedBats, LeftBat)
						end
						if RightShoulder and RightShoulder.Parent and RightArm and RightArm.Parent then
							local RightBat = LaunchBat(RightArm)
							table.insert(LaunchedBats, RightBat)
						end
					end
					wait(0.1)
				end
				if CurrentlyEquipped then
					InvokeClient("SetCameraType", Enum.CameraType.Custom)
					local Animation = Animations.ArmsOut
					if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
						Animation = Animations.R15ArmsOut
					end
					InvokeClient("StopAnimation", Animation)
					for i, v in pairs({RotationGyro, DirectionsGuiClone}) do
						if v and v.Parent then
							v:Destroy()
						end
					end
					if CurrentHumanoid and CurrentHumanoid.Parent then
						CurrentHumanoid.WalkSpeed = 16
					end
					Delay(1, function()
						if CurrentlyEquipped then
							SetUpBats()
						end
					end)
				end
				Special.Active = false
				wait(Special.ReloadTime)
				Special.Ready = true
			end
		end
	end
end)

function SetTarget(Object)
	if not Object or not Object.Parent then
		return
	end
	if TargetRemoved then
		TargetRemoved:disconnect()
	end
	TargetRemoved = Object.Changed:connect(function(Property)
		if Property == "Parent" and not Object.Parent then
			if Head and Head.Parent then
				SetTarget(Head)
			end
		end
	end)
	BatTarget = Object
	BatBoundaries = ((BatTarget == Head and Ray.new(Vector3.new(-10, -2, -10), Vector3.new(10, 10, 10))) or Ray.new(Vector3.new(-10, -5, -10), Vector3.new(10, 5, 10)))
end

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
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

function PositionPart(Part, X, Y, Z)
	local PartClone = Part:Clone()
	local PartCloneY = PartClone:Clone()
	PartCloneY.CFrame = PartCloneY.CFrame * CFrame.Angles(-math.rad(90), 0, 0)		
	PartCloneY.CFrame = PartCloneY.CFrame - PartCloneY.CFrame.lookVector * Y
	local PartCloneZ = PartCloneY:Clone()
	PartCloneZ.CFrame = PartCloneZ.CFrame + PartClone.CFrame.lookVector * Z
	local PartCloneX = PartCloneZ:Clone()
	PartCloneX.CFrame = PartCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	PartCloneX.CFrame = PartCloneX.CFrame - PartCloneX.CFrame.lookVector * X
	return PartCloneX.CFrame
end

function IsFlipped(CFrame)
	local V1 = CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
	local V2 = Vector3.new(0, 1, 0)
	local Angle = math.acos(V1:Dot(V2))
	return (Angle > 2)
end

function CreateBat()
	local Bat = Handle:Clone()
	Bat.Name = "Bat"
	Bat.Transparency = 0
	Bat.Size = (Bat.Size / 2)
	Bat.Mesh.Scale = (Bat.Mesh.Scale / 2)
	Bat.CanCollide = false
	Bat.Anchored = true
	return Bat
end

function BatTouched(Part, HitDamage, MinimumTransparency)
	Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Part.Transparency > MinimumTransparency or not Equipped then
			return
		end
		local humanoid = Hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= Humanoid and humanoid.Health > 0 then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(HitDamage)
		end
	end)
end

function LaunchBat(SpawnPart)
	local Bat = CreateBat()
	Bat.Anchored = false
	local Mass = (Bat:GetMass() * Gravity) * 1.25
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(0, math.huge, 0)
	BodyGyro.Parent = Bat
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
	BodyVelocity.Parent = Bat
	Bat.CFrame = SpawnPart.CFrame
	local BatCFrame = PositionPart(Bat, 0, 0, ((Bat.Size.Y / 2) + (SpawnPart.Size.Z / 2))) * CFrame.Angles(0, -(math.pi / 2), 0)
	BodyGyro.cframe = BatCFrame
	BodyVelocity.velocity = BatCFrame.lookVector * 50
	Delay(1, function()
		for i = 1, 10 do
			if Bat and Bat.Parent then
				Bat.Transparency = (0.1 * i)
				if Bat.Transparency >= 1 then
					Bat:Destroy()
				end
			end
			wait(0.1)
		end
	end)
	BatTouched(Bat, Damage, 0.75)
	Debris:AddItem(Bat, 2)
	Bat.Parent = BatModel
	Bat.CFrame = BatCFrame
	Bat.Velocity = BodyVelocity.velocity
	return Bat
end

function CreateBats()
	for i = 1, 15 do
		local Bat = CreateBat()
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.Parent = Bat
		local Mass = (Bat:GetMass() * Gravity * 1.25)
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.D = 10000
		BodyPosition.P = 20000
		BodyPosition.maxForce = Vector3.new(Mass, Mass, Mass)
		BodyPosition.Parent = Bat
		BatTouched(Bat, Damage, 0)
		table.insert(Bats, {Bat = Bat, BodyGyro = BodyGyro, BodyPosition = BodyPosition, Origin = {CFrame = nil, Nearby = false, Traveling = false}, TargetPoint = nil})
	end
end

function PlaceBats()
	if BatModel and BatModel.Parent then
		BatModel:Destroy()
	end
	BatModel = Instance.new("Model")
	BatModel.Name = Player.Name .. "'s Bats"
	local BatManagementClone = BatManagement:Clone()
	local CreatorValue = Instance.new("ObjectValue")
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = BatManagementClone
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = BatManagementClone
	BatManagementClone.Disabled = false
	BatManagementClone.Parent = BatModel
	for i, v in pairs(Bats) do
		if v.Bat and v.BodyGyro and v.BodyPosition then
			PositionBats(BatTarget)
			v.Bat.Transparency = 1
			v.Bat.Parent = BatModel
		end
	end
	BatModel.Parent = game:GetService("Workspace")
	for i, v in pairs(Bats) do
		--v.Bat.CFrame = v.Origin.CFrame --Enables bats to appear flying around already when you equip this tool
		v.Bat.Anchored = false
	end
	BatsReady = false
	Spawn(function()
		for i = 1, 10 do
			for ii, v in pairs(Bats) do
				if v.Bat and v.Bat.Parent then
					v.Bat.Transparency = (1 - (0.1 * i))
				end
			end
			wait(0.1)
		end
		BatsReady = true
	end)
end

function PositionBats(Origin)
	for i, v in pairs(Bats) do
		if (not v.Origin.Nearby and not v.Traveling) or not v.Origin.CFrame then
			v.Origin.Traveling = true
			local TargetPoint = PositionPart(Origin, math.random(BatBoundaries.Origin.X, BatBoundaries.Direction.X), math.random(BatBoundaries.Origin.Y, BatBoundaries.Direction.Y), math.random(BatBoundaries.Origin.Z, BatBoundaries.Direction.Z)) * CFrame.Angles(math.random(-math.pi, math.pi), math.random(-math.pi, math.pi), math.random(-math.pi, math.pi))
			TargetPoint = TargetPoint * CFrame.Angles(((IsFlipped(TargetPoint) and math.pi) or 0), 0, 0)
			v.Origin.CFrame = TargetPoint
			v.BodyGyro.cframe = CFrame.new(v.Bat.Position, TargetPoint.p)
			v.BodyPosition.position = TargetPoint.p
			if v.Origin.CFrame and (v.Bat.Position - v.Origin.CFrame.p).magnitude <= 6 then
				v.Traveling = false
				v.Origin.Nearby = true
			end
		else
			v.Origin.Nearby = false
		end
	end
end

function FunctionBats()
	while BatModel and BatModel.Parent do
		if not BatTarget then
			SetTarget(Head)
		elseif BatTarget ~= Head then
			local humanoid = BatTarget.Parent:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health == 0 then
				SetTarget(Head)
			end
		end
		PositionBats(BatTarget)
		if (LastSoundPlayed == 0 or (tick() - LastSoundPlayed) >= 1) then
			local PlaySound = math.random(1, 5)
			if PlaySound == 5 then
				LastSoundPlayed = tick()
				Sounds[math.random(1, #Sounds)]:Play()
			end
		end
		wait(0.25)
	end
end

function SetUpBats()
	Spawn(function()
		if BatModel and BatModel.Parent then
			BatModel:Destroy()
		end
		for i, v in pairs(Bats) do
			if v.Bat and v.Bat.Parent then
				v.Bat:Destroy()
			end
		end
		Bats = {}
		SetTarget(Head)
		CreateBats()
		PlaceBats()
		FunctionBats()
	end)
end

function CheckIfAlive(Current)
	return (Character and Character.Parent and Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Spawn(function()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Equipped = true
	Handle.Transparency = 1
	SetUpBats()
	end)
end

function Unequipped()
	Equipped = false
	for i, v in pairs({BatModel, RotationGyro, DirectionsGuiClone}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Bats = {}
	BatTarget = nil
	BatBoundaries = nil
	BatsReady = false
	Special.Active = false
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	local Animation = Animations.ArmsOut
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Animations.R15ArmsOut
	end	
	Spawn(function()
		InvokeClient("SetCameraType", Enum.CameraType.Custom)
		InvokeClient("StopAnimation", Animation)
	end)
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)