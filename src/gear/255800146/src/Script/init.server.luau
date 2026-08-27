--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

StunScript = script:WaitForChild("StunScript")

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
	Normal = CFrame.new(0, 0.75, 0.5, 1, 0, 0, 0, 1, -0, -0, 0, 1),
	Swinging = CFrame.new(0, 0.75, 0.5, -1, 0, 0, 0, -1, 0, 0, 0, 1)
}

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil, Manual = true},
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 6, Duration = nil, Manual = true},
	Release = {Animation = Tool:WaitForChild("Release"), FadeTime = nil, Weight = nil, Speed = 3, Manual = false, EndFadeTime = 0.25, Damage = {Min = 20, Max = 30}},
}

Damage = {
	Touch = {Min = 0, Max = 0},
	Scythe = {Min = 20, Max = 30},
}

Sounds = {
	Woosh = Handle:WaitForChild("Woosh"),
	Smack = Handle:WaitForChild("Smack"),
	Spin = Handle:WaitForChild("Spin"),
}

ReloadTime = 0.25

HitReady = false

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
Tool.Grip = Grips.Normal
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

function GetAngle(Direction)
    local Angle = math.acos(Direction:Dot(Vector3.new(1, 0, 0)))
    local Modifier = math.acos(Direction:Dot(Vector3.new(0, 0, -1)))
    return (Angle * (Modifier > (math.pi / 2) and -1 or 1))
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
		
		if Part.Name == "Weight" or Part.Name == "Chain" then
			
			if not HitReady then
				return
			end
			
			if object and object:IsA("Tool") and object ~= Tool then
				local handle = object:FindFirstChild("Handle")
				if handle then
					local FakeHandle = handle:Clone()
					humanoid:UnequipTools()
					object:Destroy()
					Debris:AddItem(object, 0)
					for i, v in pairs(FakeHandle:GetChildren()) do
						if not v:IsA("DataModelMesh") then
							v:Destroy()
						end
					end
					FakeHandle.Name = "Effect"
					FakeHandle.CanCollide = false
					FakeHandle.Velocity = (CFrame.new(Part.Position, Hit.Position).lookVector * 50)
					Debris:AddItem(FakeHandle, 10)
					FakeHandle.Parent = game:GetService("Workspace")
					return
				end
			end
			
			if CurrentAnimation and CurrentAnimation.Damage then
				DamageValue = CurrentAnimation.Damage
			end
		
			HitReady = false
			Sounds.Smack:Play()
		elseif Part.Name == "Scythe" and CurrentAnimation then
			DamageValue = Damage.Scythe
		end
		
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		
		if FinalizedDamage <= 0 then
			return
		end
		
		local EstimatedHealth = (humanoid.Health - FinalizedDamage)
		
		humanoid:TakeDamage(FinalizedDamage)
		
		if EstimatedHealth > 0 then
			local StunChance = math.random(1, 4)
			if StunChance == 1 and player then
				local torso = character:FindFirstChild("Torso")
				if torso then
					torso.Velocity = (CFrame.new(Torso.Position, torso.Position).lookVector * -50)
				end
				local StunScriptClone = StunScript:Clone()
				local Duration = Instance.new("NumberValue")
				Duration.Name = "Duration"
				Duration.Value = 1.5
				Duration.Parent = StunScriptClone
				StunScriptClone.Disabled = false
				Debris:AddItem(StunScriptClone, 3)
				StunScriptClone.Parent = character
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
	Scythe = BasePart:Clone()
	Scythe.Name = "Scythe"
	Scythe.Size = Vector3.new(0.25, 2.5, 1)
	Scythe.CanCollide = false
	local ScytheMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(1.25, 1.25, 1.25),
		TextureId = (BaseUrl .. "250279755"),
		MeshId = (BaseUrl .. "250279651"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = Scythe,
	}
	Chain = BasePart:Clone()
	Chain.Name = "Chain"
	Chain.Size = Vector3.new(0.2, 1.5, 0.2)
	Chain.CanCollide = false
	local ChainMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(1.25, 1.25, 1.25),
		TextureId = (BaseUrl .. "250279755"),
		MeshId = (BaseUrl .. "250279611"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = Chain,
	}
	Weight = BasePart:Clone()
	Weight.Name = "Weight"
	Weight.Size = Vector3.new(0.25, 0.5, 0.25)
	Weight.CanCollide = false
	local WeightMesh = Create("SpecialMesh"){
		MeshType = Enum.MeshType.FileMesh,
		Scale = Vector3.new(1.25, 1.25, 1.25),
		TextureId = (BaseUrl .. "250279755"),
		MeshId = (BaseUrl .. "250279713"),
		Offset = Vector3.new(0, 0, 0),
		VertexColor = Vector3.new(1, 1, 1),
		Parent = Weight,
	}
	ChainPart = BasePart:Clone()
	ChainPart.Name = "ChainPart"
	ChainPart.Transparency = 1
	ChainPart.CanCollide = false
	ScytheMotor = Create("Motor6D"){
		Name = "ScytheMotor",
		Part0 = Handle,
		Part1 = Scythe,
		C0 = (CFrame.new(0.005, 0.5275, 0) * CFrame.Angles(0, 0, 0)),
		C1 = (CFrame.new(-0.005, -0.5275, 0) * CFrame.Angles(0, 0, 0)),
		MaxVelocity = 0.25,
		Parent = Scythe,
	}
	ChainMotor = Create("Motor6D"){
		Name = "ChainMotor",
		Part0 = ChainPart,
		Part1 = Chain,
		C0 = (CFrame.new(0, -0.25, 0) * CFrame.Angles(0, (math.pi / 2), 0)),
		C1 = (CFrame.new(0, 0.625, 0) * CFrame.Angles(0, (math.pi / 2), 0)),
		MaxVelocity = 0.25,
		Parent = Chain,
	}
	WeightMotor = Create("Motor6D"){
		Name = "ChainMotor",
		Part0 = Chain,
		Part1 = Weight,
		C0 = (CFrame.new(0, -0.68, 0) * CFrame.Angles(0, (math.pi / 2), 0)),
		C1 = (CFrame.new(0, 0.395, 0) * CFrame.Angles(0, (math.pi / 2), 0)),
		MaxVelocity = 0.25,
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
	Blow(Weight)
	Blow(Scythe)
	for i, v in pairs({Scythe, Chain, Weight, ChainPart}) do
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
	LastChain = Chain
	local ExtendedChains = {}
	for i = 1, 8 do
		local ExtendedChain = Chain:Clone()
		local ExtendedChainMotor = ExtendedChain.ChainMotor
		ExtendedChainMotor.Part0 = LastChain
		ExtendedChainMotor.Part1 = ExtendedChain
		ExtendedChainMotor.DesiredAngle = ((i == 0 and 0) or -(math.random(-250, 500) * 0.001))
		ExtendedChainMotor.CurrentAngle = ExtendedChainMotor.DesiredAngle
		table.insert(ExtendedChains, ExtendedChain)
		ExtendedChain.Parent = Tool
		LastChain = ExtendedChain
	end
	for i = 1, 4 do
		local Chain = ExtendedChains[(#ExtendedChains - (i - 1))]
		if Chain then
			Blow(Chain)
		end
	end
	WeightMotor.Part0 = LastChain
	local Direction = CFrame.new(ChainPartMotor.Part1.Position, Vector3.new(TargetPosition.X, ChainMotor.Part1.Position.Y, TargetPosition.Z)):toObjectSpace(Handle.CFrame).lookVector
	ChainMotor.DesiredAngle = Clamp((math.abs(GetAngle(Direction)) * -3), -3, 3)
	ChainPartMotor.DesiredAngle = Clamp((math.abs(GetAngle(Direction)) * -1), -9, 9)
	ChainMotor.CurrentAngle = 0
	ChainPartMotor.CurrentAngle = 0
	if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
		InvokeClient("StopAnimation", Animations.Swing)
		Sounds.Woosh:Play()
		local Animation = Animations.Release
		CurrentAnimation = Animation
		HitReady = true
		InvokeClient("PlayAnimation", Animation)
		WeightMotor.Part0 = Chain
		for i, v in pairs(ExtendedChains) do
			if v and v.Parent then
				v:Destroy()
			end
		end
		for i, v in pairs({ChainPartMotor, ChainMotor}) do
			v.DesiredAngle = 0
			v.CurrentAngle = 0
		end
		Tool.Grip = Grips.Normal
		HitReady = false
		CurrentAnimation = nil
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
		InvokeClient("PlayAnimation", Animations.Hold)
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
	if Torso and Torso.Parent then
		Handle.CFrame = (Torso.CFrame + Torso.CFrame.lookVector * (Torso.Size.Z * 2))
	end
	Tool.Grip = Grips.Normal
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