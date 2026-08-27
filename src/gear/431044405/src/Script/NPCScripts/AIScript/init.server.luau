--Made by Luckymaxer

Figure = script.Parent
Humanoid = Figure:WaitForChild("Humanoid")
Torso = Figure:WaitForChild("Torso")

Players = game:GetService("Players")

Functions = require(script:WaitForChild("Functions"))

Creator = Figure:WaitForChild("Creator")
HitDelay = Figure:WaitForChild("HitDelay")
Damage = Figure:WaitForChild("Damage")

Rate = (1 / 60)

SpawnOrigin = Torso.Position

TouchDebounce = false

function CheckIfAlive()
	return (((Figure and Figure.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function GetCreatorPlayer()
	return (((Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function GetNearbyObjects(Region)
	local CreatorPlayer = GetCreatorPlayer()
	local IgnoreList = {Figure, ((CreatorPlayer and CreatorPlayer.Character) or nil)}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= CreatorPlayer and v.Character and v.Character.Parent and (CreatorPlayer and Functions.IsTeamMate(CreatorPlayer, v)) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return Functions.GetParts(Region, 500, IgnoreList)
end

function GetNearbyPlayers(Radius)
	local NearbyObjects = GetNearbyObjects(Radius)
	local Humanoids = {}
	for i, v in pairs(NearbyObjects) do
		local character = v.Parent
		if character then
			local creator = character:FindFirstChild("Creator")
			local humanoid = character:FindFirstChild("Humanoid")
			if (((creator and creator.Value ~= Creator.Value) or not creator) and (humanoid and not Functions.CheckTableForInstance(Humanoids, humanoid))) then
				table.insert(Humanoids, humanoid)
			end
		end
	end
	return Humanoids
end

function SecureJump()
	if not Humanoid or Humanoid.Jump or not Torso then
		return
	end
	local TargetPoint = Torso.Velocity.Unit
	local Blockage, BlockagePos = Functions.CastRay((Torso.CFrame + CFrame.new(Torso.Position, Vector3.new(TargetPoint.X, Torso.Position.Y, TargetPoint.Z)).lookVector * (Torso.Size.Z / 2)).p, Torso.CFrame.lookVector, (Torso.Size.Z * 2.5), {Figure, (((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Character) and Creator.Value.Character) or nil)}, false)
	local Jumpable = false
	if Blockage then
		Jumpable = true
		if Blockage:IsA("Terrain") then
			local CellPos = Blockage:WorldToCellPreferSolid((BlockagePos - Vector3.new(0, 2, 0)))
			local CellMaterial, CellShape, CellOrientation = Blockage:GetCell(CellPos.X, CellPos.Y, CellPos.Z)
			if CellMaterial == Enum.CellMaterial.Water then
				Jumpable = false
			end
		elseif Blockage.Parent:FindFirstChild("Humanoid") then
			Jumpable = false
		end
	end
	if Jumpable then
		Humanoid.Jump = true
	end
end

for i, v in pairs(Figure:GetChildren()) do
	if v:IsA("BasePart") then
		local TouchedConnection
		TouchedConnection = v.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent or TouchDebounce then
				return
			end
			local Connected = false
			local ConnectedParts = v:GetConnectedParts()
			if #ConnectedParts <= 1 then
				return
			end
			for i, v in pairs(ConnectedParts) do
				if v == Torso then
					Connected = true
				end
			end
			if not Connected then
				return
			end
			local character = Hit.Parent
			if character:IsA("Hat") then
				character = character.Parent
			end
			local player = Players:GetPlayerFromCharacter(character)
			local CreatorValue = Figure.Creator.Value
			if not CreatorValue then
				return
			end
			local CreatorPlayer = ((CreatorValue:IsA("Player") and CreatorValue) or Players:GetPlayerFromCharacter(CreatorValue))
			if player then
				if player == CreatorPlayer then
					return
				end
				if player and CreatorPlayer and Functions.IsTeamMate(CreatorPlayer, player) then
					return
				end
			end
			local creator = character:FindFirstChild("Creator")
			if creator and creator:IsA("ObjectValue") and creator.Value == CreatorValue then
				return
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if not humanoid or not humanoid:IsA("Humanoid") or humanoid.Health == 0 then
				return
			end
			TouchDebounce = true
			Functions.UntagHumanoid(humanoid)
			Functions.TagHumanoid(humanoid, CreatorPlayer)
			humanoid:TakeDamage(Damage.Value)
			wait(HitDelay.Value)
			TouchDebounce = false
		end)
	end
end

Walk = {Tick = 0, Delay = 0}

while CheckIfAlive() do
	local Now = tick()
	local WalkToPosition = nil
	if (Now - Walk.Tick) > Walk.Delay then
		local MaxDistance = 45
		local NearbyPlayers = GetNearbyPlayers(Region3.new((Torso.Position - Vector3.new(MaxDistance, (Torso.Size.Y * 2), MaxDistance)), (Torso.Position + Vector3.new(MaxDistance, MaxDistance, MaxDistance))))
		if #NearbyPlayers > 0 then
			local ClosestPlayer = {Distance = MaxDistance, Character = nil}
			for i, v in pairs(NearbyPlayers) do
				local humanoid = v
				local character = v.Parent
				if character and character.Parent then
					local humanoid = character:FindFirstChild("Humanoid")
					local torso = character:FindFirstChild("Torso")
					if humanoid and humanoid.Health > 0 and torso then
						local DistanceApart = (Torso.Position - torso.Position).Magnitude
						if DistanceApart < ClosestPlayer.Distance then
							ClosestPlayer.Distance = DistanceApart
							ClosestPlayer.Character = character
						end
					end
				end
			end
			local ClosestCharacter = ClosestPlayer.Character
			if ClosestCharacter and ClosestCharacter.Parent then
				local torso = ClosestCharacter:FindFirstChild("Torso")
				if torso then
					WalkToPosition = torso.Position
				end
			end
		else
			local WalkRadius = 10
			WalkToPosition = (Torso.Position + Vector3.new(math.random(-WalkRadius, WalkRadius), 0, math.random(-WalkRadius, WalkRadius)))
			Walk.Delay = (math.random(500, 3500) * 0.001)
			Walk.Tick = Now
		end
	end
	if WalkToPosition and (SpawnOrigin - WalkToPosition).Magnitude > 75 then
		WalkToPosition = Torso.Position
	end
	if WalkToPosition then
		SecureJump()
		Humanoid:MoveTo(WalkToPosition)
	end
	wait(Rate)
end