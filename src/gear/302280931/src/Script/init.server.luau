--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

FunctionsLibrary = script:WaitForChild("Functions")
Functions = require(FunctionsLibrary)

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

Animations = {
	CenterSwing = {Animation = Tool:WaitForChild("CenterSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	LeftSwing = {Animation = Tool:WaitForChild("LeftSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	RightSwing = {Animation = Tool:WaitForChild("RightSwing"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 1},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.65, Damage = {Min = 20, Max = 30}},
}

Damage = {
	Touch = {Min = 0, Max = 0},
	Hit = {Min = 10, Max = 15},
}

Sounds = {
	Woosh = Handle:WaitForChild("Woosh"),
	Smack = Handle:WaitForChild("Smack"),
	Spin = Handle:WaitForChild("Spin"),
}

BaseSpider = BasePart:Clone()
BaseSpider.Name = "BaseSpider"
BaseSpider.Friction = 2
BaseSpider.Elasticity = 1
BaseSpider.Size = Vector3.new(1.25, 0.6, 1.25)
BaseSpider.CanCollide = false
local BaseSpiderMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	Scale = Vector3.new(0.25, 0.25, 0.25),
	TextureId = (BaseUrl .. "297606548"),
	MeshId = (BaseUrl .. "297606481"),
	Offset = Vector3.new(0, 0, 0),
	VertexColor = Vector3.new(0, 0, 0),
	Parent = BaseSpider,
}

ReloadTime = 0.25

HitReady = false

Gravity = 196.20
Rate = (1 / 60)

MouseDown = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Enabled = true

function Blow(Part)
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not HitReady then
			return
		end
		local character = Hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player and (Functions.IsTeamMate(Player, player) or player == Player) then
			return
		end
		local RightArm = Character:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if character == Character or not humanoid or humanoid.Health == 0 then
			return
		end
		local DamageValue = Damage.Touch
		if CurrentAnimation then
			DamageValue = Damage.Hit
		end
		if not DamageValue then
			return
		end
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		if FinalizedDamage <= 0 then
			return
		end
		local EstimatedHealth = (humanoid.Health - FinalizedDamage)		
		humanoid:TakeDamage(FinalizedDamage)
	end)
	return TouchedConnection
end

function ConstructWeapon(MakeNew)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if not MakeNew then
		return
	end
	local GripPart = BasePart:Clone()
	GripPart.Name = "GripPart"
	GripPart.Size = Vector3.new(0.3, 0.3, 2.5)
	GripPart.CanCollide = false
	local GripPartMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(0.5, 0.5, 0.5),
		TextureId = (BaseUrl .. "297606548"),
		MeshId = (BaseUrl .. "297606432"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = GripPart,
	}
	local ChainLink = BasePart:Clone()
	ChainLink.Name = "ChainLink"
	ChainLink.Size = Vector3.new(0.25, 0.25, 0.25)
	ChainLink.CanCollide = false
	local ChainMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(0.5, 0.5, 0.5),
		TextureId = (BaseUrl .. "297606548"),
		MeshId = (BaseUrl .. "297606414"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = ChainLink,
	}
	local Links = {}
	local LastPart = GripPart
	for i = 1, 5 do
		local Link = ChainLink:Clone()
		local Motor = Create("Motor6D"){
			Part0 = LastPart,
			Part1 = Link,
			MaxVelocity = 0.1,
			DesiredAngle = -1.6,
			CurrentAngle = 0,
			Parent = Link
		}
		if i == 1 then
			FirstChainMotor = Motor
			Motor.DesiredAngle = 1
			Motor.C0 = (CFrame.new(0, -0.025, -1.2) * CFrame.Angles((math.pi / 2), -(math.pi / 2), 0))
			Motor.C1 = (CFrame.new(0, 0.05, 0.1) * CFrame.Angles((math.pi * 2), (math.pi / 2), 0))
		elseif (i % 2) == 0 then
			Motor.C0 = (CFrame.new(0,-0.0, -0.125) * CFrame.Angles((math.pi / 2), (math.pi / 2), -(math.pi / 2)))
			Motor.C1 = (CFrame.new(0, 0, 0.15) * CFrame.Angles((math.pi / 2), math.pi, math.pi))
		elseif (i % 2) == 1 then
			Motor.C0 = (CFrame.new(0, 0, -0.125) * CFrame.Angles((math.pi / 2), 0, 0))
			Motor.C1 = (CFrame.new(0, 0, 0.15) * CFrame.Angles(0, (math.pi / 2), 0))
		end
		table.insert(Links, {Link = Link, Motor = Motor})
		LastPart = Link
	end
	Weight = BasePart:Clone()
	Weight.Name = "Weight"
	Weight.Size = Vector3.new(0.75, 0.25, 2.375)
	Weight.CanCollide = false
	local WeightMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(0.5, 0.5, 0.5),
		TextureId = (BaseUrl .. "297606548"),
		MeshId = (BaseUrl .. "297606481"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = Weight,
	}
	GripMotor = Create("Motor6D"){
		Name = "GripMotor",
		Part0 = Handle,
		Part1 = GripPart,
		C0 = CFrame.new(0, 1.76, 0.27),
		C1 = CFrame.new(0, 0, 0),
		MaxVelocity = 0.2,
		Parent = GripPart,
	}
	WeightMotor = Create("Motor6D"){
		Name = "WeightMotor",
		Part0 = LastPart,
		Part1 = Weight,
		C0 = (CFrame.new(0, 0, -0.125) * CFrame.Angles(math.pi, -(math.pi / 2), 0)),
		C1 = (CFrame.new(0, -0.1375, 1.175) * CFrame.Angles((math.pi * 2), (math.pi / 2), 0)),
		MaxVelocity = 0.25,
		DesiredAngle = 0.5,
		CurrentAngle = 0,
		Parent = Weight,
	}
	Blow(Weight)
	for i, v in pairs(Links) do
		v.Link.Parent = Tool
		Blow(v.Link)
	end
	for i, v in pairs({GripPart, Weight}) do
		v.Parent = Tool
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or MouseDown or not CheckIfAlive() then
		return
	end
	MouseDown = true
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Spin)
	end)
	Sounds.Spin:Play()
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	FirstChainMotor.DesiredAngle = 0.25
	GripMotor.DesiredAngle = 999999999
	local Spiders = {Tick = tick(), Delay = (math.random(1000, 2500) * 0.001)}
	while ToolEquipped and CurrentlyEquipped and MouseDown and CheckIfAlive() do
		local Now = tick()
		local CreaturesNearby = {}
		local Humanoids = {}
		local Radius = 10
		for i, v in pairs(Players:GetPlayers()) do
			if v ~= Player and not Functions.IsTeamMate(Player, v) and v.Character then
				local character = v.Character
				local humanoid = character:FindFirstChild("Humanoid")
				local head = character:FindFirstChild("Head")
				if humanoid and humanoid.Health > 0 and head and not Functions.CheckTableForInstance(Humanoids, humanoid) then
					local Distance = (Weight.Position - head.Position).Magnitude
					if Distance <= Radius then
						table.insert(Humanoids, humanoid)
						table.insert(CreaturesNearby, {Character = character, Humanoid = humanoid, Head = head, Distance = Distance})
					end
				end
			end
		end
		table.sort(CreaturesNearby, (function(a, b)
			return (a.Distance < b.Distance)
		end))
		if #CreaturesNearby > 0 and (Now - Spiders.Tick) >= Spiders.Delay then
			for i, v in pairs(CreaturesNearby) do
				if i > 3 then
					break
				end
				Spiders.Tick = Now
				Spiders.Delay = (math.random(800, 2250) * 0.001)
				local Spider = BaseSpider:Clone()
				Spider.Name = "Projectile"
				Spider.CanCollide = false
				Delay(0.25, (function()
					Spider.CanCollide = true
				end))
				local BodyGyro = Create("BodyGyro"){
					Name = "BodyGyro",
					maxTorque = Vector3.new(math.huge, math.huge, math.huge),
					Parent = Spider,
				}
				local TargetPosition = v.Head.Position
				local ShotOffset = Vector3.new(0.5, 1, 0.5)
				ShotOffset = (ShotOffset * 1000)
				local Direction = (CFrame.new(Weight.Position, TargetPosition) + Vector3.new((math.random(-ShotOffset.X, ShotOffset.X) * 0.001), (math.random(-ShotOffset.Y, ShotOffset.Y) * 0.001), (math.random(-ShotOffset.Z, ShotOffset.Z) * 0.001))).lookVector
				local Force = (math.random(2500, 5000) * 0.01)
				local SpawnPosition = (CFrame.new(Weight.Position, (Weight.CFrame + Direction * 2).p) + Direction * (math.random(200, 250) * 0.01))
				SpawnPosition = CFrame.new(SpawnPosition.p, (SpawnPosition + (Direction * Vector3.new(1, 1, 1)) * 2).p)
				BodyGyro.cframe = SpawnPosition
				Spider.CFrame = SpawnPosition
				local Velocity = ((Direction * Force) + Vector3.new(0, math.random(-2.5, 15)*0, 0))
				Spider.Velocity = Velocity
				Debris:AddItem(Spider, 5)
				Spider.Parent = game:GetService("Workspace")
				local SpiderHit = false
				Spider.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent or SpiderHit then
						return
					end
					local character = Hit.Parent
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					local player = Players:GetPlayerFromCharacter(character)
					if player and (player == Player or Functions.IsTeamMate(Player, player)) then
						return
					end
					local Directions = {{Vector = Spider.CFrame.lookVector, Length = (Spider.Size.Z + 2)}, {Vector = Vector3.new(0, -1, 0), Length = (Spider.Size.Y * 1.25)}, ((Hit and {Vector = CFrame.new(Spider.Position, Hit.Position).lookVector, Length = (Spider.Size.Z + 2)}) or nil)}
					local ClosestRay = {DistanceApart = math.huge}
					for i, v in pairs(Directions) do
						if v then
							local Direction = CFrame.new(Spider.Position, (Spider.CFrame + v.Vector * 2).p).lookVector
							local RayHit, RayPos, RayNormal = Functions.CastRay((Spider.Position + Vector3.new(0, 0, 0)), Direction, v.Length, {Character, Spider}, false)
							if RayHit then
								local CharacterHit = RayHit.Parent
								if CharacterHit == character then
									local DistanceApart = (Spider.Position - RayPos).Magnitude
									if DistanceApart < ClosestRay.DistanceApart then
										ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
									end
								end
							end
						end
					end
					if ClosestRay and ClosestRay.Hit then
						SpiderHit = true
						local NewSpider = BaseSpider:Clone()
						NewSpider.Name = "Effect"
						NewSpider.Size = Vector3.new(0.2, 0.2, 0.2)
						NewSpider.CanCollide = false
						Spider:Destroy()
						local StickCFrame = CFrame.new(ClosestRay.Pos, (CFrame.new(ClosestRay.Pos) + ClosestRay.Normal * 2).p) * CFrame.Angles((math.pi / 2), 0, 0)
						StickCFrame = (StickCFrame * CFrame.new(0, -(NewSpider.Size.Y / 1.5), 0))
						StickCFrame = (StickCFrame * CFrame.Angles(math.pi, (math.random(-360, 360) * 0.01), 0))
						local Weld = Create("Motor6D"){
							Part0 = NewSpider,
							Part1 = ClosestRay.Hit,
							C0 = StickCFrame:inverse(),
							C1 = ClosestRay.Hit.CFrame:inverse(),
							Parent = NewSpider,
						}
						Debris:AddItem(NewSpider, 5)
						NewSpider.Parent = game:GetService("Workspace")
						Functions.UntagHumanoid(humanoid)
						Functions.TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(10)
					end
				end)
			end
		end
		wait(Rate)
	end
	local MouseData = InvokeClient("MouseData")
	if not MouseData or not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
		Tool.Enabled = true
		return
	end
	local TargetPos = MouseData.Hit.p
	local Angle = CFrame.new(Head.Position, Vector3.new(TargetPos.X, Head.Position.Y, TargetPos.Z)):toObjectSpace(Head.CFrame).lookVector.X
	local Direction = (math.abs(Angle) <= 0.45 and Enum.NormalId.Front or Angle > 0 and Enum.NormalId.Left or Angle < 0 and Enum.NormalId.Right)
	Spawn(function()
		InvokeClient("StopAnimation", Animations.Spin)
	end)
	local NewMotor = GripMotor:Clone()
	NewMotor.Part0 = GripMotor.Part0
	NewMotor.Part1 = GripMotor.Part1
	NewMotor.DesiredAngle = 0
	NewMotor.CurrentAngle = 0
	NewMotor.Parent = GripMotor.Parent
	GripMotor.Parent = nil
	GripMotor = NewMotor
	Sounds.Spin:Stop()
	FirstChainMotor.DesiredAngle = -1.6
	WeightMotor.DesiredAngle = -1.6
	Delay(0.25, (function()
		FirstChainMotor.DesiredAngle = 2
		WeightMotor.DesiredAngle = -1
		wait(0.25)
		FirstChainMotor.DesiredAngle = 0
		WeightMotor.DesiredAngle = -1
	end))
	Sounds.Woosh:Play()
	local Animation = ((Direction == Enum.NormalId.Left and Animations.LeftSwing) or (Direction == Enum.NormalId.Right and Animations.RightSwing) or Animations.CenterSwing)
	CurrentAnimation = Animation
	HitReady = true
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	FirstChainMotor.DesiredAngle = 1
	WeightMotor.DesiredAngle = 0.5
	HitReady = false
	CurrentAnimation = nil
	wait(ReloadTime)
	Tool.Enabled = true
	MouseDown = false
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Head = Character:FindFirstChild("Head")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = 1
	Spawn(function()
		ConstructWeapon(true)
		for i, v in pairs({"Right Arm"}) do
			local Limb = Character:FindFirstChild(v)
			if Limb then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Limb, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
	end)
	MouseDown = false
	ToolEquipped = true
end

function Unequipped()
	MouseDown = false
	ToolEquipped = false
	Handle.Transparency = 0
	Spawn(function()
		ConstructWeapon(false)
	end)
	if Torso and Torso.Parent then
		Handle.CFrame = (Torso.CFrame + Torso.CFrame.lookVector * (Torso.Size.Z * 2))
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
		if not Down and MouseDown then
			MouseDown = false
		end
	end
end

ConstructWeapon(false)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)