--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Creator = Model:WaitForChild("Creator")

SpiderConfiguration = {
	Name = "RobotSpider",
	ShootDistance = {Min = 0, Max = 25},
	FireRate = {Min = 1.5, Max = 6},
	Accuracy = {X = {Min = -2, Max = 2}, Y = {Min = -2, Max = 2}, Z = {Min = -2, Max = 2}},
	FadeDelay = 0.375,
	FadeRate = (1 / 60),
	Damage = 10,
	Color = BrickColor.new("Really red"),
}

for i, v in pairs(SpiderConfiguration.FireRate) do
	SpiderConfiguration.FireRate[i] = (v * 1000)
end
for i, v in pairs(SpiderConfiguration.Accuracy) do
	for ii, vv in pairs(v) do
		SpiderConfiguration.Accuracy[i][ii] = (vv * 1000)
	end
end

SpidersControlled = false
Spiders = {}

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
	Anchored = false,
}

function GetCreator()
	local CreatorValue = Creator.Value
	return (((CreatorValue and CreatorValue.Parent and CreatorValue:IsA("Player")) and CreatorValue) or nil)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function CheckUpsideDown(CFrame, Surface, MaxAngle)
	local Vector1 = CFrame:vectorToWorldSpace(Vector3.FromNormalId(Surface))
	local Vector2 = Vector3.new(0, 1, 0)
	local Angle = math.acos(Vector1:Dot(Vector2))
	return (Angle > MaxAngle)
end

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
		if ((not Hit.CanCollide or Hit.Parent:IsA("Hat") or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
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

function SplatGui(Player)
	local Images = {297810825, 297810888, 297810987}
	if not Player or not Player:IsA("Player") then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if not PlayerGui then
		return
	end
	local SplatGui = Create("ScreenGui"){
		Name = "SplatGui",
	}
	for i = 1, math.random(1, 3) do
		local Size = math.random(700, 1200)
		local Image = Create("ImageLabel"){
			Name = "Ink",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, Size, 0, Size),
			Position = UDim2.new((math.random(-400, 450) * 0.001), 0, (math.random(-350, 400) * 0.001), 0),
			Image = (BaseUrl .. Images[math.random(1, #Images)]),
			Rotation = math.random(0, 360),
			Parent = SplatGui,
		}
	end
	Debris:AddItem(SplatGui, 5)
	SplatGui.Parent = PlayerGui
end

function ControlSpiders()
	if SpidersControlled or #Spiders == 0 then
		return
	end
	SpidersControlled = true
	while #Spiders > 0 do
		local CreatorPlayer = GetCreator()
		if CreatorPlayer then
			local Now = tick()
			for i, v in pairs(Spiders) do
				if v and v.Spider and v.Spider.Parent and v.Humanoid and v.Humanoid.Health > 0 and v.Torso and v.Torso.Parent then
					if (Now - v.CobWebs.Tick) >= v.CobWebs.Delay and not CheckUpsideDown(v.Torso.CFrame, Enum.NormalId.Top, (math.pi / 3)) then
						v.CobWebs.Tick = Now
						v.CobWebs.Delay = (math.random(SpiderConfiguration.FireRate.Min, SpiderConfiguration.FireRate.Max) * 0.001)
						if v.Target.Value then
							local TargetPlayer = nil
							local character = v.Target.Value
							if character and character.Parent then
								local player = Players:GetPlayerFromCharacter(character)
								if not player or (player and player ~= CreatorPlayer and not IsTeamMate(CreatorPlayer, player)) then
									local humanoid = character:FindFirstChild("Humanoid")
									local head = character:FindFirstChild("Head")
									if humanoid and humanoid.Health > 0 and head then
										local DistanceApart = (v.Torso.Position - head.Position).Magnitude
										if --[[DistanceApart >= SpiderConfiguration.ShootDistance.Min and]] DistanceApart <= SpiderConfiguration.ShootDistance.Max then
											TargetPlayer = {Player = player, Character = character, Humanoid = humanoid, Head = head, Distance = DistanceApart}
										end
									end
								end
							end
							if TargetPlayer then
								local SpawnPos = (v.Torso.CFrame * CFrame.new(0, -0.1, (-(v.Torso.Size.Z / 2) + 0.05))).p
								local TargetPos = TargetPlayer.Head.Position
								local Accuracy = SpiderConfiguration.Accuracy
								Accuracy = Vector3.new((math.random(Accuracy.X.Min, Accuracy.X.Max) * 0.001), (math.random(Accuracy.Y.Min, Accuracy.Y.Max) * 0.001), (math.random(Accuracy.Z.Min, Accuracy.Z.Max) * 0.001))
								TargetPos = (TargetPos + Accuracy)
								local Direction = CFrame.new(SpawnPos, TargetPos)
								local Distance = (SpawnPos - TargetPos).Magnitude
								local RayHit, RayPos, RayNormal = CastRay(SpawnPos, Direction.lookVector, (Distance + 5), {v.Spider, CreatorPlayer.Character}, false)
								local RayDistance = (SpawnPos - RayPos).Magnitude
								local CobString = BasePart:Clone()
								CobString.Name = "Effect"
								CobString.BrickColor = SpiderConfiguration.Color
								CobString.Size = Vector3.new(1, 1, 1)
								CobString.CanCollide = false
								CobString.Anchored = true
								local Mesh = Create("CylinderMesh"){
									Parent = CobString,
								}
								Debris:AddItem(CobString, 3)
								CobString.Parent = game:GetService("Workspace")
								CobString.CFrame = ((Direction + Direction.lookVector * (RayDistance / 2)) * CFrame.Angles((math.pi / 2), 0, 0))
								Mesh.Scale = Vector3.new(0.1, RayDistance, 0.1)
								Spawn(function()
									local Frames = math.floor(SpiderConfiguration.FadeDelay / SpiderConfiguration.FadeRate)
									for Frame = 1, Frames do
										wait(SpiderConfiguration.FadeRate)
										local Percent = (Frame / Frames)
										CobString.Transparency = Percent
									end
								end)
								if RayHit then
									local character = RayHit.Parent
									if character:IsA("Hat") then
										character = character.Parent
									end
									local player = Players:GetPlayerFromCharacter(character)
									local humanoid = character:FindFirstChild("Humanoid")
									local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
									if character == TargetPlayer.Character and humanoid and humanoid.Health > 0 and torso then
										local player = Players:GetPlayerFromCharacter(character)
										if player then
											SplatGui(TargetPlayer.Player)
										end
										UntagHumanoid(TargetPlayer.Humanoid)
										TagHumanoid(TargetPlayer.Humanoid, CreatorPlayer)
										TargetPlayer.Humanoid:TakeDamage(SpiderConfiguration.Damage)
										if TargetPlayer.Humanoid.Health <= 0 then
											local AshColors = {"Really black", "Black", "Dark stone grey", "White"}
											for i = 1, math.random(25, 50) do
												local Ashes = BasePart:Clone()
												Ashes.Name = "Ashes"
												Ashes.BrickColor = BrickColor.new(AshColors[math.random(1, #AshColors)])
												Ashes.Material = Enum.Material.Granite
												Ashes.Size = Vector3.new(0.5, 0.2, 0.5)
												Ashes.CFrame = (CFrame.new(torso.Position) * CFrame.new((math.random(-2000, 2000) * 0.001), (math.random(-2000, 2000) * 0.001), (math.random(-2000, 2000) * 0.001)) * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0))
												Debris:AddItem(Ashes, math.random(3, 5))
												Ashes.Parent = game:GetService("Workspace")
											end
											for i, v in pairs(character:GetChildren()) do
												if v:IsA("BasePart") or v:IsA("Hat") then
													v:Destroy()
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		wait(1.5)
	end
	SpidersControlled = false
end

function FunctionSpider(Child)
	if not Child:IsA("Model") or not string.find(string.lower(Child.Name), string.lower(SpiderConfiguration.Name)) then
		return
	end
	for i, v in pairs(Spiders) do
		if v and v.Spider and v.Spider == Child then
			return
		end
	end
	local Spider = Child
	local Humanoid = Spider:FindFirstChild("Humanoid")
	local Torso = Spider:FindFirstChild("Torso")
	local Target = Spider:WaitForChild("Target")
	if not Humanoid or Humanoid.Health == 0 or not Torso or not Target then
		return
	end
	local CobWebDelay = (math.random(SpiderConfiguration.FireRate.Min, SpiderConfiguration.FireRate.Max) * 0.001)
	local Table = {
		Spider = Child,
		Humanoid = Humanoid,
		Torso = Torso,
		Target = Target,
		CobWebs = {Tick = tick(), Delay = CobWebDelay},
	}
	table.insert(Spiders, Table)
	ControlSpiders()
end

for i, v in pairs(Model:GetChildren()) do
	FunctionSpider(v)
end

Model.ChildAdded:connect(function(Child)
	FunctionSpider(Child)
end)

Model.ChildRemoved:connect(function(Child)
	for i, v in pairs(Spiders) do
		if v and v.Spider and v.Spider == Child then
			table.remove(Spiders, i)
			break
		end
	end
end)

ControlSpiders()