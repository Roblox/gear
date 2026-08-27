--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://wwww.roblox.com/asset/?id="

Animations = {
	Flying = {Animation = Tool:WaitForChild("Flying"), FadeTime = nil, Weight = nil, Speed = 0.5, Manual = true},
}

AnimationTracks = {}

Gravity = 196.20
JumpHeightPercentage = 0.25

Gliding = false
SpaceDown = false

LastTeleport = 0

BaseSpeed = 16
IncreasedSpeed = (BaseSpeed * 1.5)
FlightSpeed = (BaseSpeed * 3)

ToolEquipped = false

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function SetAnimation(mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local function StopAnimation(Animation)
		for i, v in pairs(AnimationTracks) do
			if v.Animation == Animation then
				v.AnimationTrack:Stop(value.EndFadeTime)
				if v.TrackStopped then
					v.TrackStopped:disconnect()
				end
				table.remove(AnimationTracks, i)
			end
		end
	end
	if mode == "PlayAnimation" then
		for i, v in pairs(AnimationTracks) do
			if v.Animation == value.Animation then
				if value.Speed then
					v.AnimationTrack:AdjustSpeed(value.Speed)
					return
				elseif value.Weight or value.FadeTime then
					v.AnimationTrack:AdjustWeight(value.Weight, value.FadeTime)
					return
				else
					StopAnimation(value.Animation, false)
				end
			end
		end
		local AnimationMonitor = Create("Model"){}
		local TrackEnded = Create("StringValue"){Name = "Ended"}
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		local TrackStopped
		if not value.Manual then
			TrackStopped = AnimationTrack.Stopped:connect(function()
				if TrackStopped then
					TrackStopped:disconnect()
				end
				StopAnimation(value.Animation, true)
				TrackEnded.Parent = AnimationMonitor
			end)
		end
		table.insert(AnimationTracks, {Animation = value.Animation, AnimationTrack = AnimationTrack, TrackStopped = TrackStopped})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
		if TrackStopped then
			AnimationMonitor:WaitForChild(TrackEnded.Name)
		end
		return TrackEnded.Name
	elseif mode == "StopAnimation" and value then
		StopAnimation(value.Animation)
	end
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

function SetGravityEffect(Table)
	local Table = (Table or {})
	local Multiplier = (Table.Multiplier or 1)
	if not GravityEffect or not GravityEffect.Parent then
		GravityEffect = Create(Table.Class or "BodyForce"){
			Name = "GravityCoilEffect",
		}
		for i, v in pairs(Table.Properties or {}) do
			pcall(function()
				GravityEffect[i] = v
			end)
		end
	end
	local TotalMass = 0
	local ConnectedParts = GetAllConnectedParts(Torso)
	for i, v in pairs(ConnectedParts) do
		if v:IsA("BasePart") then
			TotalMass = (TotalMass + v:GetMass())
		end
	end
	local TotalMass = ((TotalMass * Gravity) * Multiplier)
	if GravityEffect:IsA("BodyVelocity") then
		GravityEffect.maxForce = Vector3.new(0, TotalMass, 0)
	elseif GravityEffect:IsA("BodyForce") then
		GravityEffect.force = Vector3.new(0, TotalMass, 0)
	end
	GravityEffect.Parent = Torso
	return GravityEffect
end

function HandleGravityEffect(Enabled, Table)
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Torso:GetChildren()) do
		if v:IsA("BodyForce") or v:IsA("BodyVelocity") then
			Debris:AddItem(v, 0)
		end
	end
	for i, v in pairs({ToolUnequipped1, DescendantAdded, DescendantRemoving}) do
		if v then
			v:disconnect()
		end
	end
	if Enabled then
		CurrentlyEquipped = true
		ToolUnequipped1 = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		SetGravityEffect(Table)
		DescendantAdded = Character.DescendantAdded:connect(function()
			if not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			SetGravityEffect(Table)
		end)
		DescendantRemoving = Character.DescendantRemoving:connect(function()
			if not CurrentlyEquipped or not CheckIfAlive() then
				return
			end
			SetGravityEffect(Table)
		end)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local Time = tick()
	local Camera = game:GetService("Workspace").CurrentCamera
	if (Time - LastTeleport) > 2 then
		local Dir = Camera.CoordinateFrame.p - Torso.CFrame.p
		Dir = Vector3.new(Dir.X, 0, Dir.Z).unit
		local BodyPosition = Create("BodyPosition"){
			maxForce = Vector3.new(math.huge, 0, math.huge),
			position = (Torso.CFrame.p - Dir * 40),
		}
		Debris:AddItem(BodyPosition, 0.5)
		BodyPosition.Parent = Torso
		LastTeleport = Time
	end
end

function IsFreeFalling()
	return (CheckIfAlive() and Humanoid:GetState() == Enum.HumanoidStateType.Freefall)
end

function KeyPressed(Key, Down)
	if Key == " " then
		SpaceDown = Down
		local CurrentState = Humanoid:GetState().Name
		local RayHit, RayPos, RayNormal = CastRay(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size.Y * 2 + 0.2), {Character}, false)
		if SpaceDown and not Gliding and RayHit and CurrentState ~= "None" and CurrentState ~= "Freefall" and CurrentState ~= "FallingDown" and CurrentState ~= "GettingUp" then
			if BodyForce and BodyForce.Parent then
				Debris:AddItem(GravityEffect, 0)
			end
			BodyForce = SetGravityEffect({Multiplier = 4})
			Debris:AddItem(BodyForce, 0.2)
		elseif SpaceDown and not Gliding and IsFreeFalling() then
			Gliding = true
			HandleGravityEffect(true, {Class = "BodyVelocity", Properties = {P = 500, velocity = Vector3.new(0, -5, 0)}})
			for i, v in pairs({BodyForce, BodyGyro}) do
				if v and v.Parent then
					Debris:AddItem(v, 0)
				end
			end
			Torso.Velocity = Vector3.new(0, 0, 0)
			Torso.RotVelocity = Vector3.new(0, 0, 0)
			Humanoid.WalkSpeed = FlightSpeed
			Humanoid.AutoRotate = false
			BodyGyro = Create("BodyGyro"){
				maxTorque = Vector3.new(math.huge, math.huge, math.huge),
				P = (10 ^ 5),
				Parent = Torso,
			}
			SetAnimation("PlayAnimation", Animations.Flying)
			while IsFreeFalling() and SpaceDown and Gliding and ToolEquipped do
				local Camera = game:GetService("Workspace").CurrentCamera
				local Velocity = Torso.Velocity
				Velocity = Vector3.new(Velocity.X, 0, Velocity.Z)
				local FlightDirection = Camera.CoordinateFrame.lookVector
				if Velocity.Magnitude > 10 then
					FlightDirection = Velocity.Unit
				end
				FlightDirection = (FlightDirection * Vector3.new(1, 0, 1))
				local FlightCFrame = (CFrame.new(Torso.Position, (Torso.CFrame + FlightDirection * 2).p) * CFrame.Angles(-(math.pi / 2), (math.pi * 2), 0))
				if tostring(FlightCFrame.p.X) ~= "-1.#IND" and FlightCFrame.p.Y ~= "-1.#IND" and FlightCFrame.p.Z ~= "-1.#IND" then
					BodyGyro.cframe = FlightCFrame
				end
				wait()
			end
			SetAnimation("StopAnimation", Animations.Flying)
			Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			Humanoid.AutoRotate = true
			if CheckIfAlive() then
				Humanoid.WalkSpeed = ((ToolEquipped and IncreasedSpeed) or BaseSpeed)
			end
			Gliding = false
			HandleGravityEffect(false)
			Debris:AddItem(BodyGyro, 0)
		end
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		Humanoid.WalkSpeed = IncreasedSpeed
		Mouse.KeyDown:connect(function(Key)
			KeyPressed(Key, true)
		end)
		Mouse.KeyUp:connect(function(Key)
			KeyPressed(Key, false)
		end)
		for i, v in pairs({HumanoidDied}) do
			if v then
				v:disconnect()
			end
		end
		HumanoidDied = Humanoid.Died:connect(function()
			if GravityEffect and GravityEffect.Parent then
				Debris:AddItem(GravityEffect, 0)
			end
		end)
		local CurrentlyEquipped = true
		if ToolUnequipped2 then
			ToolUnequipped2:disconnect()
		end
		ToolUnequipped2 = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
	end)
	ToolEquipped = true
end

function Unequipped()
	SpaceDown = false
	if CheckIfAlive() then
		Humanoid.WalkSpeed = BaseSpeed
		Humanoid.AutoRotate = true
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	for i, v in pairs(AnimationTracks) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({HumanoidDied, ToolUnequipped2, BodyForce, BodyGyro, ToolUnequipped1, DescendantAdded, DescendantRemoving}) do
		if tostring(v) == "Connection" then
			v:disconnect()
		elseif type(v) == "userdata" and v and v.Parent then
			Debris:AddItem(v, 0)
		end
	end
	HandleGravityEffect(false)
	ToolEquipped = false
end

--Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)