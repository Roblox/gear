--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

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

Grips = {
	Normal = CFrame.new(0, 0.75, 0.5, -1, 0, 0, 0, -1, 0, 0, 0, 1),
	Swinging = CFrame.new(0, 0.75, 0.5, -1, 0, 0, 0, -1, 0, 0, 0, 1),
	Unequipped = CFrame.new(0, -0.75, 1.375, 0.999999583, 3.63901798e-009, -0.000890471681, 0, 1, 4.08661936e-006, 0.000890471565, -4.08661708e-006, 0.999999702),
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil, Manual = true},
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 6, Duration = nil, Manual = true},
	Release = {Animation = Tool:WaitForChild("Release"), FadeTime = nil, Weight = nil, Speed = 2, Manual = false, Duration = 0.65, Damage = {Min = 20, Max = 30}},
}

Damage = {
	Touch = {Min = 0, Max = 0},
	Hit = {Min = 20, Max = 30},
}

Sounds = {
	Woosh = Handle:WaitForChild("Woosh"),
	Smack = Handle:WaitForChild("Smack"),
	Spin = Handle:WaitForChild("Spin"),
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
Tool.Grip = Grips.Unequipped
Tool.Enabled = true

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

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function Blow(Part)
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() then
			return
		end
		
		local object
		local character = Hit.Parent
		if character:IsA("Hat") or character:IsA("Tool") then
			object = Hit.Parent
			character = character.Parent
		end
		
		local player = Players:GetPlayerFromCharacter(character)
		if player and (IsTeamMate(Player, player) or player == Player) then
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
		
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("ForceField") then
				return
			end
		end
		
		local DamageValue = Damage.Touch
		if (Part.Name == "Chain" or (Part.Name == "Weight" and Part.Transparency < 1)) and CurrentAnimation then
			DamageValue = Damage.Hit
		elseif Part.Name == "Projectile" then
			DamageValue = {Min = 25, Max = 25}
		end
		
		if not DamageValue then
			return
		end
		
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		
		if FinalizedDamage <= 0 then
			return
		end
		
		local EstimatedHealth = (humanoid.Health - FinalizedDamage)
		
		humanoid:TakeDamage(FinalizedDamage)
		
		if EstimatedHealth > 0 and Part.Name == "Weight" and Part.Transparency < 1 then
			local StickChance = math.random(1, 4)
			if StickChance == 1 then
				Part.Transparency = 1
				local Leaf = BasePart:Clone()
				Leaf.Name = "Projectile"
				Leaf.Size = Vector3.new(0.25, 0.5, 0.25)
				Leaf.CanCollide = false
				local LeafMesh = Create("SpecialMesh"){
					MeshType = Enum.MeshType.FileMesh,
					Scale = Vector3.new(1, 1, 1),
					TextureId = (BaseUrl .. "272518759"),
					MeshId = (BaseUrl .. "272525319"),
					Offset = Vector3.new(0, 0, 0),
					VertexColor = Vector3.new(1, 1, 1),
					Parent = Leaf,
				}
				for i = 1, math.random(15, 25) do
					local LeafCopy = Leaf:Clone()
					LeafCopy.CFrame = Weight.CFrame
					local Direction = (LeafCopy.CFrame * CFrame.Angles((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01)))
					local Force = 50
					local Velocity = (Direction.lookVector * Force)
					local Mass = (LeafCopy:GetMass() * Gravity)
					local BodyVelocity = Create("BodyVelocity"){
						maxForce = Vector3.new(Mass, Mass, Mass),
						velocity = Velocity,
						Parent = LeafCopy,
					}
					LeafCopy.Velocity = Velocity
					Blow(LeafCopy)
					Debris:AddItem(LeafCopy, 2)
					LeafCopy.Parent = game:GetService("Workspace")
				end
				wait(5)
				Part.Transparency = 0
			end
		end
		
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
	HandlePart = BasePart:Clone()
	HandlePart.Name = "HandlePart"
	HandlePart.Size = Vector3.new(0.25, 4, 0.25)
	HandlePart.CanCollide = false
	local HandlePartMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(1, 1, 1),
		TextureId = (BaseUrl .. "272518759"),
		MeshId = (BaseUrl .. "272518648"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = HandlePart,
	}
	Chain = BasePart:Clone()
	Chain.Name = "Chain"
	Chain.Size = Vector3.new(0.2, 1.5, 0.2)
	Chain.CanCollide = false
	local ChainMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(1, 1, 1),
		TextureId = (BaseUrl .. "272518759"),
		MeshId = (BaseUrl .. "272518609"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = Chain,
	}
	Weight = BasePart:Clone()
	Weight.Name = "Weight"
	Weight.Size = Vector3.new(1.5, 1.5, 1.5)
	Weight.CanCollide = false
	local WeightMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(1, 1, 1),
		TextureId = (BaseUrl .. "272518759"),
		MeshId = (BaseUrl .. "272518509"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = Weight,
	}
	ChainPart = BasePart:Clone()
	ChainPart.Name = "ChainPart"
	ChainPart.Transparency = 1
	ChainPart.CanCollide = false
	HandlePartMotor = Create("Motor6D"){
		Name = "HandlePartMotor",
		Part0 = Handle,
		Part1 = HandlePart,
		C0 = (CFrame.new(0, -0.2, 0.425) * CFrame.Angles((math.pi / 2), 0, 0)),
		C1 = (CFrame.new(0, 0.25, 0) * CFrame.Angles(-(math.pi / 2), 0, 0)),
		MaxVelocity = 0.25,
		Parent = HandlePart,
	}
	ChainMotor = Create("Motor6D"){
		Name = "ChainMotor",
		Part0 = ChainPart,
		Part1 = Chain,
		C0 = (CFrame.new(0, -1.9, -0.05) * CFrame.Angles(0, (math.pi / 2), 0)),
		C1 = (CFrame.new(0, 0.685, -0.025) * CFrame.Angles(0, (math.pi / 2), 0)),
		MaxVelocity = 0.1,
		DesiredAngle = 2.5,
		CurrentAngle = 2.5,
		Parent = Chain,
	}
	WeightMotor = Create("Motor6D"){
		Name = "WeightMotor",
		Part0 = Chain,
		Part1 = Weight,
		C0 = (CFrame.new(0, -0.75, 0.05) * CFrame.Angles(math.pi, (math.pi / 2), 0)),
		C1 = (CFrame.new(0, -0.55, -0.05) * CFrame.Angles(0, (math.pi / 2), 0)),
		MaxVelocity = 0.25,
		DesiredAngle = 0.5,
		CurrentAngle = 0.5,
		Parent = Weight,
	}
	ChainPartMotor = Create("Motor6D"){
		Name = "ChainPartMotor",
		Part0 = Handle,
		Part1 = ChainPart,
		C0 = (CFrame.new(-0.025, -0.15, 0.4750) * CFrame.Angles((math.pi / 2), 0, 0)),
		C1 = (CFrame.new(-0.025, -0.15, -0.0) * CFrame.Angles((math.pi / 2), 0, 0)),
		MaxVelocity = 0.2,
		Parent = ChainPart,
	}
	for i, v in pairs({Chain, Weight}) do
		Blow(v)
	end
	for i, v in pairs({HandlePart, Chain, Weight, ChainPart}) do
		v.Parent = Tool
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or MouseDown or not CheckIfAlive() then
		return
	end
	MouseDown = true
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Swing)
	end)
	Tool.Grip = Grips.Swinging
	ChainMotor.DesiredAngle = -1.35
	ChainPartMotor.DesiredAngle = 9999999
	WeightMotor.DesiredAngle = 0
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
	while ToolEquipped and CurrentlyEquipped and MouseDown and CheckIfAlive() do
		wait(Rate)
	end
	local TargetPosition = InvokeClient("MousePosition")
	if not TargetPosition or not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
		Tool.Enabled = true
		return
	end
	TargetPosition = TargetPosition.Position
	Sounds.Spin:Stop()
	for i, v in pairs({{Motor = ChainPartMotor, Angle = 0, Reset = true}, {Motor = ChainMotor, Angle = 0}, {Motor = WeightMotor, Angle = 0.5}}) do
		v.Motor.DesiredAngle = v.Angle
		if v.Reset then
			v.Motor.CurrentAngle = v.Angle
		end
	end
	if ToolEquipped and CurrentlyEquipped then
		wait(0.375)
		for i, v in pairs({{Motor = ChainPartMotor, Angle = 0, Reset = true}, {Motor = ChainMotor, Angle = 2.75}, {Motor = WeightMotor, Angle = 0.5}}) do
			v.Motor.DesiredAngle = v.Angle
			if v.Reset then
				v.Motor.CurrentAngle = v.Angle
			end
		end
		wait(0.25)
		if ToolEquipped and CurrentlyEquipped then
			for i, v in pairs({{Motor = ChainPartMotor, Angle = 0, Reset = true}, {Motor = ChainMotor, Angle = 2.5}, {Motor = WeightMotor, Angle = 0.5}}) do
				v.Motor.DesiredAngle = v.Angle
				if v.Reset then
					v.Motor.CurrentAngle = v.Angle
				end
			end
			wait(0.25)
			if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
				Spawn(function()
					InvokeClient("StopAnimation", Animations.Swing)
				end)
				Sounds.Woosh:Play()
				local Animation = Animations.Release
				CurrentAnimation = Animation
				HitReady = true
				Spawn(function()
					InvokeClient("PlayAnimation", Animation)
				end)
				wait(Animation.Duration)
				WeightMotor.Part0 = Chain
				for i, v in pairs({{Motor = ChainPartMotor, Angle = 0, Reset = true}, {Motor = ChainMotor, Angle = 2.5, Reset = true}, {Motor = WeightMotor, Angle = 0.5, Reset = true}}) do
					v.Motor.DesiredAngle = v.Angle
					if v.Reset then
						v.Motor.CurrentAngle = v.Angle
					end
				end
				Tool.Grip = Grips.Normal
				HitReady = false
				CurrentAnimation = nil
			end
		end
	end
	wait(ReloadTime)
	Tool.Enabled = true
	MouseDown = false
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Handle.Transparency = 1
	Spawn(function()
--		InvokeClient("PlayAnimation", Animations.Hold)
	end)
	Spawn(function()
		ConstructWeapon(true)
		for i, v in pairs({"Left Arm", "Right Arm"}) do
			local Limb = Character:FindFirstChild(v)
			if Limb then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = Limb, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
	end)
	Tool.Grip = Grips.Normal
	ToolEquipped = true
end

function Unequipped()
	MouseDown = false
	ToolEquipped = false
	Handle.Transparency = 0
	Spawn(function()
		ConstructWeapon(false)
	end)
	Tool.Grip = Grips.Unequipped
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

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
		if not Down and MouseDown then
			MouseDown = false
		end
	end
end)

ConstructWeapon(false)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)