--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

BaseShield = BasePart:Clone()
BaseShield.Name = "Shield"
BaseShield.Size = Vector3.new(2.25, 2.625, 0.5625)
ShieldMesh = Instance.new("SpecialMesh")
ShieldMesh.MeshType = Enum.MeshType.FileMesh
ShieldMesh.MeshId = (BaseUrl .. "232461882")
ShieldMesh.TextureId = (BaseUrl .. "232461492")
ShieldMesh.Scale = Vector3.new(0.65, 0.65, 0.65)
ShieldMesh.VertexColor = Vector3.new(1, 1, 1)
ShieldMesh.Offset = Vector3.new(0, 0, 0)
ShieldMesh.Parent = BaseShield

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Block = {Animation = Tool:WaitForChild("Block"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	ShieldBash = {Animation = Tool:WaitForChild("ShieldBash"), FadeTime = nil, Weight = nil, Speed = 3, Delay = 0.25, Duration = 1, Damage = {Min = 30, Max = 45}},
	ShieldSlash = {Animation = Tool:WaitForChild("ShieldSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 1, Damage = {Min = 8, Max = 22}},
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = 0.1, Weight = 1, Speed = 4, Delay = 0.25, Duration = 1, Damage = {Min = 22, Max = 25}},
}

Sounds = {
	Slash = {Sound = Handle:WaitForChild("Slash"), Delay = 0.25},
	SwordDraw = {Sound = Handle:WaitForChild("SwordDraw")},
	SwordHit = {Sound = Handle:WaitForChild("SwordHit")},
	BashHit = {Sound = Handle:WaitForChild("BashHit")},
	BashMiss = {Sound = Handle:WaitForChild("BashMiss"), Delay = 0.25},
}

TouchDamage = {Min = 0, Max = 0}

Clicks = 0
FirstClick = false

ToolEquipped = false
Attacking = false
Blocking = false
MouseDown = false
BlockTick = 0

ReloadTime = 1

Gravity = 196.20
Rate = (1 / 60)

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

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
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
	
	humanoid:TakeDamage(DamageAmount)
	
end

function ShieldBlow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not Shield or not Shield.Parent or CurrentAnimation ~= Animations.ShieldBash then
		return
	end
	
	local LeftArm = Character:FindFirstChild("Left Arm")
	if not LeftArm then
		return
	end
	
	local LeftGrip = Shield:FindFirstChild("Weld")
	if not LeftGrip or (LeftGrip.Part0 ~= LeftArm and LeftGrip.Part1 ~= LeftArm) then
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
	
	local torso = character:FindFirstChild("Torso")
	if torso then
		torso.Velocity = torso.Velocity + CFrame.new(Torso.Position, torso.Position).lookVector * 75
	end
	
	Sounds.BashHit.Sound:Play()
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or {Min = 0, Max = 0})
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	
	Sounds.BashHit.Sound:Play()
	CurrentAnimation = nil
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	humanoid:TakeDamage(DamageAmount)
	
end


function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			local RandomSound = PossibleSounds[math.random(1, #PossibleSounds)]
			Delay(((RandomSound.Delay and RandomSound.Delay) or 0), (function()
				RandomSound.Sound:Play()
			end))
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

function SetHumanoid(humanoid, MaxHealth, WalkSpeed)
	if not humanoid or not humanoid.Parent or humanoid.Health == 0 then
		return
	end
	local Ratio = (humanoid.Health / humanoid.MaxHealth)
	humanoid.WalkSpeed = WalkSpeed
	humanoid.MaxHealth = MaxHealth
	humanoid.Health = (Ratio * humanoid.MaxHealth)
end

function CreateShield()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if not LeftArm then
		return
	end
	Shield = BaseShield:Clone()
	local ShieldWeld = Instance.new("Weld")
	ShieldWeld.Part0 = LeftArm
	ShieldWeld.Part1 = Shield
	ShieldWeld.C0 = CFrame.new(-0.75, -0.25, 0.125) * CFrame.Angles((math.pi / 10), (math.pi / 2.125), -(math.pi / 2))
	ShieldWeld.Parent = Shield
	Shield.Touched:connect(ShieldBlow)
	Shield.Parent = Tool
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Attacking = true
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		Tool.Enabled = false
		Attacking = true
		local AttackAnims = {}
		local AttackSounds = {}
		if Clicks == 1 then
			AttackSounds = {Sounds.Slash}
			AttackAnims = ((not Blocking and {Animations.Slash}) or {Animations.ShieldBash})
		elseif Clicks > 1 and not Blocking then
			AttackSounds = {Sounds.Slash}
			AttackAnims = {Animations.Slash}
			local FirePart = BasePart:Clone()
			FirePart.Name = "FirePart"
			FirePart.Transparency = 1
			FirePart.CanCollide = false
			local Fire = Instance.new("Fire")
			Fire.Color = Color3.new((255 / 255), (255 / 255), (0 / 255))
			Fire.SecondaryColor = Color3.new((170 / 255), (170 / 255), (0 / 255))
			Fire.Heat = 25
			Fire.Size = 5
			Fire.Enabled = true
			Fire.Parent = FirePart
			local FireWeld = Instance.new("Weld")
			FireWeld.Part0 = Handle
			FireWeld.Part1 = FirePart
			FireWeld.C0 = FireWeld.C0 * CFrame.Angles(-(math.pi / 2), 0, 0)
			FireWeld.Parent = FirePart
			Debris:AddItem(FirePart, 2)
			FirePart.Parent = Tool
			local MousePosition = InvokeClient("MousePosition").Position
			local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
			Torso.CFrame = Direction
			local Parts = GetAllConnectedParts(Torso)
			local Mass = 0
			for i, v in pairs(Parts) do
				Mass = (Mass + v:GetMass())
			end
			Mass = (Mass * Gravity * 100)
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.maxForce = Vector3.new(Mass, 0, Mass)
			BodyVelocity.velocity = Direction.lookVector * 50
			Debris:AddItem(BodyVelocity, 0.25)
			BodyVelocity.Parent = Torso
			local BodyGyro = Instance.new("BodyGyro")
			BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			BodyGyro.cframe = Direction
			Debris:AddItem(BodyGyro, 0.25)
			BodyGyro.Parent = Torso
		end
		Attack(AttackAnims, AttackSounds)
		FirstClick = false
		Clicks = 0
		Attacking = false
		wait(ReloadTime)
		Tool.Enabled = true
	end
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
	Spawn(function()
		Sounds.SwordDraw.Sound:Play()
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	Spawn(CreateShield)
	ToolEquipped = true
end

function Unequipped()
	Attacking = false
	Blocking = false
	MouseDown = false
	FirstClick = false
	Clicks = 0
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	if Shield and Shield.Parent then
		Shield:Destroy()
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
	if player == Player and ToolEquipped and CheckIfAlive() then
		if Mode == "Button1Click" then
			local Down = Value.Down
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
			if Key == "q" then
				if Down and not MouseDown and not Blocking and (tick() - BlockTick) >= 2 then
					MouseDown = Down
					Delay(0.25, function()
						if MouseDown then
							Blocking = true
							SetHumanoid(Humanoid, 200, 8)
							InvokeClient("PlayAnimation", Animations.Block)
						end
					end)
				elseif MouseDown or Blocking then
					MouseDown = false
					if Blocking then
						BlockTick = tick()
						Blocking = false
						SetHumanoid(Humanoid, 100, 16)
						InvokeClient("StopAnimation", Animations.Block)
					end
				end
			end
		end
	end
end)

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)