--Made by Luckymaxer

Figure = script.Parent
Humanoid = Figure:WaitForChild("Humanoid")
Torso = Figure:WaitForChild("Torso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Animation = Figure:WaitForChild("Animation")
Standing = Animation:WaitForChild("Standing")

Creator = Figure:WaitForChild("Creator")

if Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player") then
	CreatorPlayer = Creator.Value
	CreatorCharacter = CreatorPlayer.Character
	if CreatorCharacter then
		CreatorHumanoid = CreatorCharacter:FindFirstChild("Humanoid")
		CreatorTorso = CreatorCharacter:FindFirstChild("HumanoidRootPart")
	end
end

if not CreatorPlayer or not CreatorCharacter or not CreatorHumanoid or not CreatorTorso then
	Creator = nil
else
	Creator = {
		Player = CreatorPlayer,
		Character = CreatorCharacter,
		Humanoid = CreatorHumanoid,
		Torso = CreatorTorso
	}
end

ScreamScript = script:WaitForChild("ScreamScript")

Motors = {}

FollowingPath = false
WalkRadius = 25

FollowRadius = 25
MaxDistanceFromTarget = 50
MaxDistanceFromCreator = 50

TargetPlayer = nil
ScareSuccess = false

Humanoid.Health = Humanoid.MaxHealth

for i, v in pairs(Torso:GetChildren()) do
	if v:IsA("Motor6D") then
		table.insert(Motors, {Parent = v.Parent, Name = v.Name, Part0 = v.Part0, Part1 = v.Part1, C0 = v.C0, C1 = v.C1})
	end
end

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
	local Blockage, BlockagePos = RayCast((Torso.CFrame + CFrame.new(Torso.Position, Vector3.new(TargetPoint.X, Torso.Position.Y, TargetPoint.Z)).lookVector * (Torso.Size.Z / 2)).p, Torso.CFrame.lookVector, (Torso.Size.Z * 2.5), {Figure, (((Creator and Creator.Character) and Creator.Character) or nil)})
	if not Humanoid.Jump and (Blockage and not Blockage.Parent:FindFirstChild("Humanoid")) then
		Humanoid.Jump = true
	end
end

function GetClosestPossiblePlayer()
	local ClosestPlayer = nil
	local PlayersNearby = {}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Creator.Player and v.Character then
			local character = v.Character
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and torso and not character:FindFirstChild(ScreamScript.Name) then
				local ToolsFound = {}
				for i, v in pairs(character:GetChildren()) do
					if v:IsA("Tool") and v.CanBeDropped and v:FindFirstChild("Handle") then
						table.insert(ToolsFound, v)
					end
				end
				if #ToolsFound > 0 then
					local DistanceApart = (torso.Position - Torso.Position).magnitude
					if DistanceApart <= FollowRadius then
						table.insert(PlayersNearby, {Player = v, Distance = DistanceApart, Tools = ToolsFound})
					end
				end
			end
		end
	end
	if #PlayersNearby > 0 then
		table.sort(PlayersNearby, (function(Player1, Player2)
			return Player1.Distance < Player2.Distance
		end))
		local ClosestPlayersNearby = {}
		for i, v in pairs(PlayersNearby) do
			if v.Distance <= PlayersNearby[1].Distance then
				table.insert(ClosestPlayersNearby, v)
			end
		end
		ClosestPlayer = ClosestPlayersNearby[math.random(1, #ClosestPlayersNearby)]
	end
	return ClosestPlayer
end

function ScareTarget()
	Standing.Value = true
	pcall(function()
		if not TargetPlayer or not TargetPlayer.Player.Parent or not TargetPlayer.Character.Parent or not TargetPlayer.Humanoid.Parent or TargetPlayer.Humanoid.Health == 0 or not TargetPlayer.Torso.Parent or not TargetPlayer.Tools then
			return
		end
		SetVertexColor(Vector3.new(255, 0, 0))
		Torso.CFrame = CFrame.new(Torso.Position, Vector3.new(TargetPlayer.Torso.Position.X, Torso.Position.Y, TargetPlayer.Torso.Position.Z))
		ScreamScriptClone = ScreamScript:Clone()
		ScreamScriptClone.Disabled = false
		ScreamScriptClone.Parent = TargetPlayer.Character
		local DropRadius = 10
		if #TargetPlayer.Tools > 0 then
			for i, v in pairs(TargetPlayer.Tools) do
				if v:IsA("Tool") then
					local handle = v:FindFirstChild("Handle")
					if handle then
						v.Parent = game:GetService("Workspace")
						handle.CFrame = TargetPlayer.Torso.CFrame + Vector3.new(math.random(-DropRadius, DropRadius), math.random(-0, (DropRadius / 2)), math.random(-DropRadius, DropRadius))
					end
				end
			end
		end
	end)
	ScareSuccess = true
	TargetPlayer = nil
	wait(2)
	if Humanoid and Humanoid.Health > 0 then
		SetVertexColor(Vector3.new(1, 1, 1))
		Standing.Value = false
	end
end

for i, v in pairs(Figure:GetChildren()) do
	if v:IsA("BasePart") then
		v.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			local humanoid = Hit.Parent:FindFirstChild("Humanoid")
			if not ScareSuccess and humanoid and humanoid.Health > 0 and humanoid ~= Humanoid and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character == Hit.Parent then
				ScareTarget()
			end
		end)
	end
end

function SetVertexColor(Color)
	for i, v in pairs(Figure:GetChildren()) do
		if v:IsA("BasePart") then
			for ii, vv in pairs(v:GetChildren()) do
				if vv:IsA("DataModelMesh") then
					vv.VertexColor = Color
				end
			end
		end
	end
end

Humanoid.Died:connect(function()
	SetVertexColor(Vector3.new(255, 0, 0))
	if Humanoid and Humanoid.Parent then
		Humanoid:Destroy()
	end
	for i, v in pairs(Figure:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = true
		end
	end
	for i, v in pairs(Motors) do
		local Motor = Instance.new("Motor6D")
		Motor.Name = v.Name
		Motor.Part0 = v.Part0
		Motor.Part1 = v.Part1
		Motor.C0 = v.C0
		Motor.C1 = v.C1
		Motor.Parent = v.Parent
	end
	Debris:AddItem(Figure, 3)
end)

repeat
	Spawn(function()
		if not TargetPlayer and not ScareSuccess then
			local ClosestPlayerInfo = GetClosestPossiblePlayer()
			if ClosestPlayerInfo then
				local ClosestPlayer = ClosestPlayerInfo.Player
				local PlayerCharacter = ClosestPlayer.Character
				local PlayerHumanoid = nil
				local PlayerTorso = nil
				if PlayerCharacter then
					PlayerHumanoid = PlayerCharacter:FindFirstChild("Humanoid")
					PlayerTorso = PlayerCharacter:FindFirstChild("HumanoidRootPart")
				end
				if PlayerHumanoid and PlayerHumanoid.Health > 0 and PlayerTorso then
					TargetPlayer = {
						Player = ClosestPlayer,
						Character = PlayerCharacter,
						Humanoid = PlayerHumanoid,
						Torso = PlayerTorso,
						Tools = ClosestPlayerInfo.Tools
					}
				end
			end
		end
		if not TargetPlayer or ScareSuccess then
			local TorsoPosition = nil
			if Creator and Creator.Character.Parent and Creator.Humanoid.Parent and Creator.Humanoid.Health > 0 and Creator.Torso.Parent then
				TorsoPosition = (Creator.Torso.CFrame + Creator.Torso.CFrame.lookVector * (((Creator.Torso.Size.Z / 2) + (Torso.Size.Z / 2)) + 0))
				TorsoPosition = (TorsoPosition - (TorsoPosition * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (Creator.Torso.Size.X * 1.5))
				TorsoPosition = (TorsoPosition - Vector3.new(0, (Creator.Torso.Size.Y / 2), 0)).p
				if ScareSuccess and (Torso.Position - Creator.Torso.Position).magnitude <= 6 then
					ScareSuccess = false
				end
			end
			MoveAround((TorsoPosition and TorsoPosition) or nil)
		else
			local DistanceFromTarget = nil
			local DistanceFromCreator = nil
			if TargetPlayer and TargetPlayer.Character.Parent and TargetPlayer.Humanoid.Parent and TargetPlayer.Humanoid.Health > 0 and TargetPlayer.Torso.Parent and Creator and Creator.Character.Parent and Creator.Humanoid.Parent and Creator.Humanoid.Health > 0 and Creator.Torso.Parent then
				DistanceFromTarget = (Torso.Position - TargetPlayer.Torso.Position).magnitude
				DistanceFromCreator = (Torso.Position - Creator.Torso.Position).magnitude
				local TargetTools = {}
				for i, v in pairs(TargetPlayer.Tools) do
					if v and v.Parent then
						table.insert(TargetTools, v)
					end
				end
				if #TargetTools > 0 and DistanceFromTarget <= MaxDistanceFromTarget and DistanceFromCreator <= MaxDistanceFromCreator then
					MoveAround((TargetPlayer.Torso.CFrame - CFrame.new(Torso.Position, TargetPlayer.Torso.Position).lookVector * 1).p)
				else
					ScareSuccess = true
					TargetPlayer = nil
				end
			else
				ScareSuccess = true
				TargetPlayer = nil
			end
		end
	end)
	SecureJump()
	wait(0.25)
until false