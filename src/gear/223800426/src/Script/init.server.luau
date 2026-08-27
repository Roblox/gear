--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

DeathEffect = script:WaitForChild("DeathEffect")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

ChainLink = BasePart:Clone()
ChainLink.Name = "ChainLink"
ChainLink.Size = Vector3.new(0.2, 0.2, 0.2)
ChainLink.CanCollide = false
ChainLinkMesh = Instance.new("SpecialMesh")
ChainLinkMesh.MeshType = Enum.MeshType.FileMesh
ChainLinkMesh.MeshId = (BaseUrl .. "223396475")
ChainLinkMesh.TextureId = (BaseUrl .. "223396535")
ChainLinkMesh.Scale = Vector3.new(0.5, 0.5, 0.5)
ChainLinkMesh.VertexColor = Vector3.new(1, 1, 1)
ChainLinkMesh.Offset = Vector3.new(0, 0, 0)
ChainLinkMesh.Parent = ChainLink

Grips = {
	Normal = {
		Grip = CFrame.new(0, 0, 1.925, 1, 0, 0, -0, 8.10005167e-006, 1, 0, -1, 8.10005167e-006),
		ChainData = {
			CFrame.new(0, 0.05, 2.575) * CFrame.Angles(-(math.pi / 4), 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 2)),
			CFrame.new(-0.1, 0, 0.1) * CFrame.Angles((math.pi / 6), (math.pi / 2.5), (math.pi / 2)),
			CFrame.new(0, 0, -0.2) * CFrame.Angles(0, 0, (math.pi / 2)),
			CFrame.new(0, 0, -0.175) * CFrame.Angles(-(math.pi / 1.25), (math.pi / 1.5), -(math.pi / 1.5)),
			CFrame.new(0, -0, -0.2) * CFrame.Angles(-(math.pi / 1), (math.pi / 0.5), -(math.pi / 1)),
			CFrame.new(0, -0.15, 0.1) * CFrame.Angles(-(math.pi / 1.5), (math.pi / 0.5), (math.pi / 1.25)),
			CFrame.new(0.15, 0.1, -0.1) * CFrame.Angles(-(math.pi / 1.25), (math.pi / 02.5), (math.pi / 1.25)),
			CFrame.new(0.1, 0, 0.15) * CFrame.Angles(-(math.pi / 1), (math.pi / 1.5), (math.pi / 1.5)),
			CFrame.new(-0.1, 0, 0.15) * CFrame.Angles(-(math.pi / 1), -(math.pi / 1.5), (math.pi / 4)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(-(math.pi / 1), -(math.pi / 1), (math.pi / 2)),
			CFrame.new(-0.025, 0, 0.2) * CFrame.Angles((math.pi / 1.125), (math.pi / 1), (math.pi / 2)),
			CFrame.new(-0.05, 0, 0.15) * CFrame.Angles(-(math.pi / 1), -(math.pi / 1.25), (math.pi / 4)),
		},
	},
	Spinning = {
		Grip = CFrame.new(0, 0, 4.25, 0, 1, -1.39293643e-008, -0.733760655, -9.46372225e-009, -0.679408014, -0.679408014, 1.02208206e-008, 0.733760655),
		ChainData = {
			CFrame.new(0, 0.05, 2.575) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(0, 0, (math.pi / 1.5)),
			CFrame.new(0, 0.1, 0.15) * CFrame.Angles(-(math.pi / 0.75), -(math.pi / 1.25), (math.pi / 4)),
			CFrame.new(0, 0, 0.2) * CFrame.Angles(-(math.pi / 1), -(math.pi / 1), (math.pi / 2)),
			CFrame.new(-0.025, 0, 0.2) * CFrame.Angles((math.pi / 1.125), (math.pi / 1), (math.pi / 2)),
			CFrame.new(-0.05, 0, 0.15) * CFrame.Angles(-(math.pi / 1), -(math.pi / 1.25), (math.pi / 4)),
		},
	},
}

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 1},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil, Damage = {Min = 10, Max = 10}},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 1, Damage = {Min = 10, Max = 20}},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 1, Damage = {Min = 10, Max = 20}},
	Stab1 = {Animation = Tool:WaitForChild("Stab1"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 1, Damage = {Min = 12, Max = 15}},
	Stab2 = {Animation = Tool:WaitForChild("Stab2"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 1, Damage = {Min = 12, Max = 15}},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Unsheath = Handle:WaitForChild("Unsheath"),
	Spin = Handle:WaitForChild("Spin"),
}

TouchDamage = {Min = 5, Max = 8}

ToolEquipped = false
Attacking = false
Spinning = false

ReloadTime = 0.75

Gravity = 196.20
Rate = (1 / 60)

SpinTick = 0

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

Tool.Grip = Grips.Normal.Grip
Tool.Enabled = true

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
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

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
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
	
	local character = Hit.Parent
	if character == Character then
		return
	end
	
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	DamageAmount = ((Tool:FindFirstChild("FirePart") and (DamageAmount * 2)) or DamageAmount)
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local HealthAfter = (humanoid.Health - DamageAmount)
	
	humanoid:TakeDamage(DamageAmount)
	
	if HealthAfter <= 0 then
		local Direction = CFrame.new(Torso.Position, Hit.Position).lookVector
		Direction = Vector3.new(Direction.X, 1, Direction.Z)
		local DeathEffectScript = DeathEffect:Clone()
		DeathEffectScript.WindDirection.Value = Direction
		DeathEffectScript.Force.Value = Vector3.new(12.5, 2.5, 10)
		DeathEffectScript.Disabled = false
		DeathEffectScript.Parent = character
	end
	
end

function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			local RandomSound = PossibleSounds[math.random(1, #PossibleSounds)]
			RandomSound:Play()
		end
		local SelectedAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		Delay(((SelectedAnimation.Delay and SelectedAnimation.Delay) or 0), (function()
			CurrentAnimation = SelectedAnimation
			InvokeClient("PlayAnimation", CurrentAnimation)
			if CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
				wait(CurrentAnimation.Duration)
				CurrentAnimation = nil
			end
		end))
	end
end

function CreateChain(ChainData)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	local ChainLinks = {}
	local LastLink
	for i, v in pairs(ChainData) do
		local Link = ChainLink:Clone()
		local LinkWeld = Instance.new("Weld")
		LinkWeld.Part0 = ((i == 1 and Handle) or LastLink)
		LinkWeld.Part1 = Link
		LinkWeld.C0 = v
		LinkWeld.C1 = CFrame.new()
		LinkWeld.Parent = Link
		Link.Parent = Tool
		LastLink = Link
		table.insert(ChainLinks, Link)
	end
	return ChainLinks
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or Spinning then
		return
	end
	Tool.Enabled = false
	Attacking = true
	local AttackSounds = {Sounds.Slash}
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.Stab1, Animations.Stab2}
	Attack(AttackAnims, AttackSounds)
	Attacking = false
	wait(ReloadTime)
	Tool.Enabled = true
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
	Tool.Grip = Grips.Normal.Grip
	Spawn(function()
		CreateChain(Grips.Normal.ChainData)
	end)
	Spawn(function()
		local LeftArm = Character:FindFirstChild("Left Arm")
		local RightArm = Character:FindFirstChild("Right Arm")
		for i, v in pairs({LeftArm, RightArm}) do
			if v and v.Parent then
				Spawn(function()
					InvokeClient("SetLocalTransparencyModifier", {Object = v, Transparency = 0, AutoUpdate = false})
				end)
			end
		end
	end)
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
	end)
	Spawn(function()
		Sounds.Unsheath:Play()
		local Animation = Animations.Equip
		Spawn(function()
			InvokeClient("PlayAnimation", Animation)
		end)
		wait(Animation.Duration)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if CurrentlyEquipped then
			ToolEquipped = true
		end
	end)
end

function Unequipped()
	Attacking = false
	Spinning = false
	Tool.Grip = Grips.Normal.Grip
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	if SpinForce and SpinForce.Parent then
		SpinForce:Destroy()
	end
	Spawn(function()
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("BasePart") and v ~= Handle then
				v:Destroy()
			end
		end
		for i, v in pairs(Sounds) do
			v:Stop()
		end
	end)
	if CheckIfAlive() then
		Humanoid.AutoRotate = true
	end
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
	elseif Mode == "KeyPress" then
		local Down = Value.Down
		local Key = Value.Key
		local ByteKey = string.byte(Key)
		if Key == "q" then
			if Down and not Spinning and (tick() - SpinTick) > 5 then
				SpinTick = tick()
				Spinning = true
				Spawn(function()
					InvokeClient("PlayAnimation", Animations.Spin)
				end)
				Tool.Grip = Grips.Spinning.Grip
				CreateChain(Grips.Spinning.ChainData)
				Humanoid.AutoRotate = false
				local Mass = 0
				local ConnectedParts = GetAllConnectedParts(Torso)
				for i, v in pairs(ConnectedParts) do
					Mass = (Mass + v:GetMass())
				end
				Mass = (Mass * Gravity ^ 2)
				if SpinForce and SpinForce.Parent then
					SpinForce:Destroy()
				end
				SpinForce = Instance.new("BodyAngularVelocity")
				SpinForce.P = 5000
				SpinForce.maxTorque = Vector3.new(0, Mass, 0)
				SpinForce.angularvelocity = Vector3.new(0, 15, 0)
				SpinForce.Parent = Torso
				CurrentAnimation = Animations.Spin
				Sounds.Spin:Play()
			elseif not Down then
				Spinning = false
				for i, v in pairs(Torso:GetChildren()) do
					if v:IsA("BodyAngularVelocity") then
						v:Destroy()
					end
				end
				if SpinForce and SpinForce.Parent then
					SpinForce:Destroy()
				end
				Spawn(function()
					InvokeClient("StopAnimation", Animations.Spin)
				end)
				Tool.Grip = Grips.Normal.Grip
				CreateChain(Grips.Normal.ChainData)
				Humanoid.AutoRotate = true
				Sounds.Spin:Stop()
				CurrentAnimation = nil
			end
		end
	end
end)

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)