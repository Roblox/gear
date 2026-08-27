--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Figure = script.Parent
Humanoid = Figure:WaitForChild("Humanoid")
Torso = Figure:WaitForChild("Torso")

Creator = Figure:WaitForChild("Creator")

FollowingPath = false
WalkRadius = 25

Humanoid.Health = Humanoid.MaxHealth

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function MoveAround(TargetPoint)
	TargetPoint = ((not TargetPoint and (Torso.Position + Vector3.new(math.random(-WalkRadius, WalkRadius), 0, math.random(-WalkRadius, WalkRadius))) or TargetPoint))
	Humanoid:MoveTo(TargetPoint)
end

function SecureJump()
	if Humanoid.Jump then
		return
	end
	local TargetPoint = Humanoid.TargetPoint
	local CreatorValue = Creator.Value
	local CreatorCharacter = nil
	if CreatorValue and CreatorValue:IsA("Player") and CreatorValue.Character then
		CreatorCharacter = CreatorValue.Character
	end
	local Blockage, BlockagePos = RayCast((Torso.CFrame + CFrame.new(Torso.Position, Vector3.new(TargetPoint.X, Torso.Position.Y, TargetPoint.Z)).lookVector * (Torso.Size.Z / 2)).p, Torso.CFrame.lookVector, (Torso.Size.Z * 2.5), {Figure, CreatorCharacter})
	if not Humanoid.Jump and (Blockage and not Blockage.Parent:FindFirstChild("Humanoid")) then
		Humanoid.Jump = true
	end
end

repeat
	Spawn(function()
		local CreatorValue = Creator.Value
		local CreatorCharacter, CreatorHumanoid, CreatorTorso, TorsoPosition
		local WalkSpeed = 24
		if CreatorValue and CreatorValue:IsA("Player") and CreatorValue.Character then
			CreatorCharacter = CreatorValue.Character
			CreatorHumanoid = CreatorCharacter:FindFirstChild("Humanoid")
			CreatorTorso = CreatorCharacter:FindFirstChild("Torso") or CreatorCharacter:FindFirstChild("UpperTorso")
			if CreatorTorso then
				local TorsoCFrame = CreatorTorso.CFrame
				TorsoPosition = (TorsoCFrame + TorsoCFrame.lookVector * (CreatorTorso.Size.Z * -0.25))
				TorsoPosition = (TorsoPosition + (TorsoPosition * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (CreatorTorso.Size.X * 1.5))
				TorsoPosition = TorsoPosition.p
			end
			if CreatorHumanoid then
				WalkSpeed = (CreatorHumanoid.WalkSpeed * 1.5)
			end
		end
		Humanoid.WalkSpeed = WalkSpeed
		MoveAround((CreatorTorso and TorsoPosition) or nil)
	end)
	SecureJump()
	wait(0.1)
until false