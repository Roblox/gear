--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

StunScript = script:WaitForChild("StunScript")
CoverScreen = script:WaitForChild("CoverScreen")

Creator = Model:WaitForChild("Creator")

SpiderConfiguration = {
	Name = "Tarantula",
	ShootDistance = {Min = 0, Max = 25},
	FireRate = {Min = 2, Max = 5},
	Accuracy = {X = {Min = -1.5, Max = 1.5}, Y = {Min = -1.5, Max = 1.5}, Z = {Min = -1.5, Max = 1.5}},
	FadeDelay = 0.5,
	FadeRate = (1 / 60),
	Damage = 25,
	Color = BrickColor.new("Institutional white"),
}

for i, v in pairs(SpiderConfiguration.FireRate) do
	SpiderConfiguration.FireRate[i] = (v * 1000)
end
for i, v in pairs(SpiderConfiguration.Accuracy) do
	for ii, vv in pairs(v) do
		SpiderConfiguration.Accuracy[i][ii] = (vv * 1000)
	end
end

StunTag = "TarantulaStun"
StunDuration = 8
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

BaseWeb = BasePart:Clone()
BaseWeb.Name = "Effect"
BaseWeb.Size = Vector3.new(0.2, 0.2, 0.2)
BaseWeb.CanCollide = false
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.FileMesh,
	MeshId = (BaseUrl .. "299832836"),
	TextureId = (BaseUrl .. "299832567"),
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseWeb,
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
	if not Player or not Player:IsA("Player") then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if not PlayerGui then
		return
	end
	local Gui = CoverScreen:Clone()
	Debris:AddItem(Gui, StunDuration)
	Gui.Parent = PlayerGui
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
				local TargetPlayer = nil
				if v and v.Spider and v.Spider.Parent and v.Humanoid and v.Humanoid.Health > 0 and v.Torso and v.Torso.Parent then
					if v.TargetPlayer ~= v.Target.Value then
						v.ChaseRange.Value = v.OriginalChaseRange
					elseif v.Target.Value and v.Target.Value.Parent then
						local TarantulaStun = v.Target.Value:FindFirstChild(StunTag)
						v.ChaseRange.Value = ((not TarantulaStun and 8) or 0)
					else
						v.ChaseRange.Value = v.OriginalChaseRange
					end
					if (Now - v.CobWebs.Tick) >= v.CobWebs.Delay and not CheckUpsideDown(v.Torso.CFrame, Enum.NormalId.Top, (math.pi / 3)) then
						v.CobWebs.Tick = Now
						v.CobWebs.Delay = (math.random(SpiderConfiguration.FireRate.Min, SpiderConfiguration.FireRate.Max) * 0.001)
						if v.Target.Value then
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
								local TarantulaStun = character:FindFirstChild(StunTag)
								if not TarantulaStun then
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
									CobString.Material = Enum.Material.Sand
									CobString.BrickColor = SpiderConfiguration.Color
									CobString.Size = Vector3.new(1, 1, 1)
									CobString.CanCollide = false
									CobString.Anchored = true
									for i, v in pairs({"Top", "Bottom", "Left", "Right", "Front", "Back"}) do
										CobString[(v .. "Surface")] = Enum.SurfaceType.SmoothNoOutlines
									end
									local Mesh = Create("CylinderMesh"){
										Parent = CobString,
									}
									Debris:AddItem(CobString, 3)
									CobString.Parent = game:GetService("Workspace")
									CobString.CFrame = ((Direction + Direction.lookVector * (RayDistance / 2)) * CFrame.Angles((math.pi / 2), 0, 0))
									Mesh.Scale = Vector3.new(0.15, RayDistance, 0.15)
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
										local head = character:FindFirstChild("Head")
										local torso = character:FindFirstChild("Torso")
										if character == TargetPlayer.Character and humanoid and humanoid.Health > 0 and head and torso then
											v.TargetPlayer = character
											local StunScriptCopy = StunScript:Clone()
											local Duration = Create("NumberValue"){
												Name = "Duration",
												Value = StunDuration,
												Parent = StunScriptCopy,
											}
											StunScriptCopy.Disabled = false
											StunScriptCopy.Parent = character
											local player = Players:GetPlayerFromCharacter(character)
											if player then
												SplatGui(TargetPlayer.Player)
											end
											TarantulaStun = Create("BoolValue"){
												Name = StunTag,
												Value = true,
											}
											Debris:AddItem(TarantulaStun, StunDuration)
											TarantulaStun.Parent = character
											UntagHumanoid(TargetPlayer.Humanoid)
											TagHumanoid(TargetPlayer.Humanoid, CreatorPlayer)
											TargetPlayer.Humanoid:TakeDamage(SpiderConfiguration.Damage)
											local Web = BaseWeb:Clone()
											Web.Mesh.Scale = (Vector3.new(math.random(750, 1200), math.random(750, 1250), math.random(750, 2000)) * 0.001)
											local WebOffset = Vector3.new(math.random(0, 500), math.random(-250, 250), ((((head.Size.Z / 2) + (Web.Size.Z / 2)) * -1) * 1000))
											WebOffset = (WebOffset * 0.001)
											local Weld = Create("Weld"){
												Part0 = head,
												Part1 = Web,
												C0 = CFrame.new(WebOffset),
												Parent = Web,
											}
											Debris:AddItem(Web, StunDuration)
											Web.Parent = character
											if TargetPlayer.Humanoid.Health <= 0 then
											end
										end
									end
								end
							end
						end
					end
				end
				if not TargetPlayer and not v.Target.Value then
					v.ChaseRange.Value = v.OriginalChaseRange
				end
			end
		end
		wait()
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
	local ChaseRange = Spider:WaitForChild("ChaseRange")
	if not Humanoid or Humanoid.Health == 0 or not Torso or not Target or not ChaseRange then
		return
	end
	local CobWebDelay = (math.random(SpiderConfiguration.FireRate.Min, SpiderConfiguration.FireRate.Max) * 0.001)
	local Table = {
		Spider = Child,
		Humanoid = Humanoid,
		Torso = Torso,
		Target = Target,
		ChaseRange = ChaseRange,
		OriginalChaseRange = ChaseRange.Value,
		TargetPlayer = nil,
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