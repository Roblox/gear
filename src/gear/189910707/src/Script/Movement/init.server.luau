--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Figure = script.Parent
Humanoid = Figure:WaitForChild("Humanoid")
Torso = Figure:WaitForChild("Torso")
Plow = Figure:WaitForChild("Plow")

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Debris = game:GetService("Debris")

SnowModel = Figure:WaitForChild("SnowModel")

Creator = Figure:WaitForChild("Creator")
Target = Figure:WaitForChild("Target")

NormalSurfaceModule = require(script:WaitForChild("NormalSurfaceModule"))

FollowingPath = false
WalkRadius = 25

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true

Humanoid.Health = Humanoid.MaxHealth

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function IsFlipped(Object)
	local Vector1 = Object.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
	local Vector2 = Vector3.new(0, 1, 0)
	local Angle = math.acos(Vector1:Dot(Vector2))
	return (Angle > 0.05)
end

function MoveAround(TargetPoint)
	TargetPoint = ((not TargetPoint and (Torso.Position + Vector3.new(math.random(-WalkRadius, WalkRadius), 0, math.random(-WalkRadius, WalkRadius))) or TargetPoint))
	Humanoid:MoveTo(TargetPoint)
end

function CreateSnow()
	local CurrentPlayers = {Figure}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v.Character then
			table.insert(CurrentPlayers, v.Character)
		end
	end
	local RayHit, RayPos = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size * 1.5), CurrentPlayers)
	if RayHit and not IsFlipped(Torso) and RayHit.Name ~= "Snow" then
		local Normal = NormalSurfaceModule(RayHit, RayPos)
		local Snow = BasePart:Clone()
		Snow.Size = Vector3.new(2, 0.2, 2)
		Snow.Name = "Snow"
		Snow.BrickColor = BrickColor.new("Institutional white")
		Snow.TopSurface = Enum.SurfaceType.SmoothNoOutlines
		Snow.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
		Snow.Anchored = true
		Snow.CanCollide = false
		Debris:AddItem(Snow, 1)
		Snow.Parent = SnowModel
		local StickCFrame = CFrame.new(RayPos, (RayPos + Normal)) * CFrame.Angles((math.pi / 2), 0, 0)
		Snow.CFrame = StickCFrame
	end
end

Plow.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
	if not Target or not Target.Value or character ~= Target.Value then
		return
	end
	if humanoid and humanoid.Health > 0 and torso then
		torso.Velocity = CFrame.new(Vector3.new(Plow.Position.X, torso.Position.Y, Plow.Position.Z), torso.Position).lookVector * 100
	end
end)

RunService.Heartbeat:connect(function()
	Spawn(function()
		
		if not Humanoid or Humanoid.Health == 0 then
			return
		end
		
		local CreatorValue = Creator.Value
		local CreatorCharacter, CreatorHumanoid, TorsoPosition, CreatorTorso, TargetTorso
		
		if CreatorValue and CreatorValue:IsA("Player") and CreatorValue.Character then
			CreatorCharacter = CreatorValue.Character
			CreatorHumanoid = CreatorCharacter:FindFirstChild("Humanoid")
			CreatorTorso = CreatorCharacter:FindFirstChild("Torso") or CreatorCharacter:FindFirstChild("UpperTorso")
		else
			return
		end

		local TargetAlive = false
		if Target and Target.Value then
			local character = Target.Value
			local humanoid = character:FindFirstChild("Humanoid")
			TargetTorso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if humanoid and humanoid.Health > 0 and TargetTorso then
				local Distance = (CreatorTorso.Position - TargetTorso.Position).magnitude
				if Distance >= 50 then
					Target.Value = nil
				end
				TargetAlive = true
			end
		end
		
		if not TargetAlive then
			if CreatorTorso then
				local TorsoCFrame = CreatorTorso.CFrame
				TorsoPosition = (TorsoCFrame + TorsoCFrame.lookVector * (CreatorTorso.Size.Z * -0.25))
				TorsoPosition = (TorsoPosition + (TorsoPosition * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (CreatorTorso.Size.X * 1.5))
				TorsoCFrame = TorsoPosition
				TorsoPosition = TorsoPosition.p
				if (CreatorTorso.Position - Torso.Position).magnitude >= 55 then
					Torso.CFrame = TorsoCFrame
				end
			end
		else
			local TorsoCFrame = TargetTorso.CFrame
			local Direction = TorsoCFrame.lookVector
			TorsoCFrame = TorsoCFrame + Direction * 1
			TorsoPosition = TorsoCFrame.p
		end
				
		CreateSnow()
		
		local WalkSpeed = 24
		if CreatorHumanoid and CreatorHumanoid.Parent then
			WalkSpeed = (CreatorHumanoid.WalkSpeed * 1.5)
		end
		Humanoid.WalkSpeed = WalkSpeed
		
		MoveAround(TorsoPosition)
	end)
end)