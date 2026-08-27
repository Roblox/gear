--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

EggModule = require(225918694)

Creator = Part:WaitForChild("Creator").Value

Sounds = {
	Warp = script:WaitForChild("Warp"),
	Launch = script:WaitForChild("Launch")
}

BaseScale = Vector3.new(0.2, 1, 0.2) --Brick size 1x1x1
BaseSize = Vector3.new(1.5, 0.25, 1.5)
MaxSize = Vector3.new(3.75, 0.75, 3.75)

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

ProjectileNames = {"Water", "Arrow", "Projectile", "Effect", "Rail", "Laser", "Bullet", "Egg"}

Rate = (1 / 60)

Grounded = false

Part.Size = BaseSize

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	if Hit and Hit.Parent then
		if Hit.Transparency > 0.8 or not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name) or Hit.Parent:FindFirstChild("Humanoid") then
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

function IsFlipped(Object)
	local Vector1 = Object.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
	local Vector2 = Vector3.new(0, 1, 0)
	local Angle = math.acos(Vector1:Dot(Vector2))
	return (Angle > ((math.pi / 2) + 0.01))
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

function Stick(Hit)
	if Grounded then
		return
	end
	Grounded = true
	Part.Velocity = Vector3.new(0, 0, 0)
	Part.RotVelocity = Vector3.new(0, 0, 0)
	local Weld
	local WeldData = {}
	if Hit and Hit.Object and Hit.Object.Parent and Hit.RayData then
		local AngleX, AngleY, AngleZ = Part.CFrame:toEulerAnglesXYZ()
		local PartCFrame = CFrame.new(Hit.RayData.RayPos, (CFrame.new(Hit.RayData.RayPos) + Hit.RayData.RayNormal * 2).p) * CFrame.Angles(-(math.pi / 2), AngleY, 0)
		PartCFrame = (PartCFrame * CFrame.new(0, (Part.Size.Y / 1), 0))
		Weld = Instance.new("Motor")
		Weld.Name = "Weld"
		Weld.Part0 = Part
		Weld.Part1 = Hit.Object
		Weld.C0 = PartCFrame:inverse()
		Weld.C1 = Hit.Object.CFrame:inverse()
		Weld.Parent = Part
		WeldData = {
			C0 = Weld.C0,
			C1 = Weld.C1
		}
	end
	Part.Velocity = Vector3.new(0, 0, 0)
	Part.RotVelocity = Vector3.new(0, 0, 0)
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
			v:Destroy()
		end
	end
	local Frames = 10
	for i = 1, Frames do
		local Increase = (1 / Frames)
		local OriginalCFrame = Part.CFrame
		Part.Size = (Part.Size * (1 + Increase))
		Part.Mesh.Scale = (BaseScale * Part.Size)
		if Hit and Hit.Object and Hit.Object.Parent and Weld then
			Weld.Part0 = Part
			Weld.Part1 = Hit.Object
			Weld.C0 = (WeldData.C0 + Vector3.new(0, -Increase, 0))
			Weld.C1 = WeldData.C1
			Weld.Parent = Part
		end
		wait(Rate)
	end
	for i = 1, AvailableEggs do
		local EggData = GetFakeEgg({Player = Creator, Paused = "Default"})
		if EggData then
			local Egg = EggData.Egg
			local LastParent = Egg.Parent
			Egg.Parent = Part
			local BoundaryBox = EggData.BoundaryBox
			local EggScript = EggData.Script
			for ii, v in pairs(EggData.Parts) do
				if v and v.Parent then
					v.CanCollide = false
					v.Transparency = 1
				end
			end
			local ProtectEgg
			Spawn(function()
				ProtectEgg = BoundaryBox.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent then
						return
					end
					local character = Hit.Parent
					if character:IsA("Hat") then
						character = character.Parent
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					Hit.Velocity = (CFrame.new(BoundaryBox.Position, Hit.Position).lookVector * PushBack)
				end)
			end)
			local Direction = CFrame.new(Part.Position, (Part.CFrame * CFrame.new(0, 1, 0)).p).lookVector
			local Distance = ((Part.Size.Y / 2) + (Part.Size.Y * 3))
			local Ignore = {Part}
			local RayPositions = {
				(Part.CFrame * CFrame.new(0, 0, 0)).p, --Center
				(Part.CFrame * CFrame.new(-((Part.Size.X / 4) + 0), 0, 0)).p, --Center Left
				(Part.CFrame * CFrame.new(((Part.Size.X / 4) + 0), 0, 0)).p, --Center Right
				(Part.CFrame * CFrame.new(0, 0, ((Part.Size.Z / 4) + 0))).p, --Front Center
				(Part.CFrame * CFrame.new(0, 0, -((Part.Size.Z / 4) + 0))).p, --Back Center
				(Part.CFrame * CFrame.new(-((Part.Size.X / 4) + 0), 0, -((Part.Size.Z / 4) + 0))).p, --Back Left
				(Part.CFrame * CFrame.new(((Part.Size.X / 4) + 0), 0, -((Part.Size.Z / 4) + 0))).p, --Back Right
				(Part.CFrame * CFrame.new(-((Part.Size.X / 4) + 0), 0, ((Part.Size.Z / 4) + 0))).p, --Front Left
				(Part.CFrame * CFrame.new(((Part.Size.X / 4) + 0), 0, ((Part.Size.Z / 4) + 0))).p, --Front Right
			}
			local Blocked = false
			for i, v in pairs(RayPositions) do
				local RayHit, RayPos, RayNormal = CastRay(v, Direction, Distance, Ignore, true)
				if RayHit then
					Blocked = true
					break
				end
			end
			local RayHit, RayPos, RayNormal = CastRay(Part.Position, Direction, Distance, {Part}, false)
			if not IsFlipped(Part) and not Blocked then
				local SpawnCFrame = (Part.CFrame * CFrame.new(0, ((Part.Size.Y / 2) + (BoundaryBox.Size.Y / 2)), 0) * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0))
				local Weld = Instance.new("Weld")
				Weld.Part0 = Part
				Weld.Part1 = BoundaryBox
				Weld.C0 = Part.CFrame:inverse()
				Weld.C1 = SpawnCFrame:inverse()
				Weld.Parent = BoundaryBox
				Spawn(function()
					local Sound = Sounds.Warp:Clone()
					Debris:AddItem(Sound, (Sound.TimeLength + 1))
					Sound.Parent = Part
					Sound:Play()
					local FadeRate = 10
					for ii = 1, FadeRate do
						for iii, v in pairs(EggData.Parts) do
							if v and v.Parent then
								v.Transparency = (1 - (ii / FadeRate))
								if ii == FadeRate then
									v.CanCollide = true
								end
							end
						end
						wait(Rate)
					end
					if Weld and Weld.Parent then
						Weld:Destroy()
					end
					local Sound = Sounds.Launch:Clone()
					Sound.Pitch = (math.random(((Sound.Pitch - 0.1) * 1000), ((Sound.Pitch + 0.2) * 1000)) * 0.001)
					Debris:AddItem(Sound, (Sound.TimeLength + 1))
					Sound.Parent = Part
					Sound:Play()
					Egg.Parent = LastParent
					local FirePart = BasePart:Clone()
					FirePart.Name = "FirePart"
					FirePart.Transparency = 1
					FirePart.CanCollide = false
					local Fires = {}
					for i = 1, 6 do
						local Fire = Instance.new("Fire")
						Fire.Name = "Fire"
						Fire.Color = Color3.new((0 / 255), (85 / 255), (255 / 255))
						Fire.SecondaryColor = Color3.new((0 / 255), (0 / 255), (255 / 255))
						Fire.Heat = 15
						Fire.Size = 5
						Fire.Enabled = false
						table.insert(Fires, Fire)
						Fire.Parent = FirePart
					end
					Delay(0.05, (function()
						for i, v in pairs(Fires) do
							if v and v.Parent then
								v.Enabled = true
							end
						end
					end))
					local FireWeld = Instance.new("Weld")
					FireWeld.Part0 = BoundaryBox
					FireWeld.Part1 = FirePart
					FireWeld.C0 = ((BoundaryBox.CFrame * CFrame.new(0, (-(BoundaryBox.Size.Y / 2) - (FirePart.Size.Y / 2) + FirePart.Size.Y), 0)) * CFrame.Angles(math.pi, 0, 0)):inverse()
					FireWeld.C1 = SpawnCFrame:inverse()
					FireWeld.Parent = FirePart
					FirePart.Parent = BoundaryBox
					local BodyGyro = Instance.new("BodyGyro")
					BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
					BodyGyro.cframe = SpawnCFrame
					Delay((math.random(800, 1500) * 0.001), (function()
						for i, v in pairs(Fires) do
							if v and v.Parent then
								v.Enabled = false
							end
						end
					end))
					Delay(1.5, (function()
						if ProtectEgg then
							ProtectEgg:disconnect()
						end
					end))
					Debris:AddItem(BodyGyro, math.random(3, 5))
					BodyGyro.Parent = BoundaryBox
					Delay(1, function()
						if not BoundaryBox or not BoundaryBox.Parent then
							return
						end
						BoundaryBox.Touched:connect(function(Hit)
							if not Hit or not Hit.Parent or BoundaryBox.Velocity.magnitude > 5 then
								return
							end
							for i, v in pairs({FirePart, BodyGyro}) do
								if v and v.Parent then
									v:Destroy()
								end
							end
						end)
					end)
					local PossibleVelocity = EggData.Velocity
					local Direction = CFrame.new(Part.Position, BoundaryBox.Position)
					local Rotation = (Direction * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0))
					local Velocity = (Direction.lookVector * (math.random(PossibleVelocity.Up.Min, PossibleVelocity.Up.Max)))
					Velocity = (Velocity + Rotation.lookVector * math.random(PossibleVelocity.Out.Min, PossibleVelocity.Out.Max))
					BoundaryBox.Velocity = Velocity
				end)
			end
		end
		wait(FireRate)
	end
end

function StickTouched(Part)
	local PartTouched
	PartTouched = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or Grounded then
			return
		end
		local character = Hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		local humanoid = character:FindFirstChild("Humanoid")
		if player or humanoid then
			return
		end
		local CanStick = false
		local ConnectedParts = GetAllConnectedParts(Hit)
		for i, v in pairs(ConnectedParts) do
			if v and v.Parent and v.Anchored then
				CanStick = true
			end
		end
		if not CanStick then
			return
		end
		local RayHit, RayPos, RayNormal = CastRay(Part.Position, CFrame.new(Part.Position, (Part.CFrame * CFrame.new(0, -1, 0)).p).lookVector, ((Part.Size.Y / 2) + 0.5), {Part}, false)
		if RayHit then
			Spawn(function()
				Stick({Object = Hit, RayData = {RayPos = RayPos, RayNormal = RayNormal}})
			end)
			if PartTouched then
				PartTouched:disconnect()
			end
		end
	end)
	wait(StickTime)
	if PartTouched then
		PartTouched:disconnect()
	end
	if not Grounded then
		Spawn(function()
			Stick()
		end)
	end
end

function GetVariables(Player)
	local Gear = EggModule.GetGear({Key = "FakeEggSpawner", Player = Player})
	GetFakeEgg = Gear.GetFakeEgg
	Duration = Gear.Duration
	StickTime = Gear.ChanceToStick
	FireRate = Gear.FireRate
	AvailableEggs = math.random(Gear.AvailableEggs.Min, Gear.AvailableEggs.Max)
	PushBack = Gear.PushBack
end

GetVariables(Creator)

if not Duration or not StickTime or not FireRate or not AvailableEggs then
	Debris:AddItem(Part, 1)
	return
end

StickTouched(Part)

Spawn(function()
	StickTick = tick()
	while (tick() - StickTick) < StickTime and not Grounded do
		wait(Rate)
	end
	Debris:AddItem(Part, Duration)
end)