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
BaseShield.Size = Vector3.new(3.5, 3, 0.5)
ShieldMesh = Instance.new("SpecialMesh")
ShieldMesh.MeshType = Enum.MeshType.FileMesh
ShieldMesh.MeshId = (BaseUrl .. "243045671")
ShieldMesh.TextureId = (BaseUrl .. "243045712")
ShieldMesh.Scale = Vector3.new(1, 1, 0.5)
ShieldMesh.VertexColor = Vector3.new(1, 1, 1)
ShieldMesh.Offset = Vector3.new(0, 0, 0)
ShieldMesh.Parent = BaseShield

Animations = {
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Block = {Animation = Tool:WaitForChild("Block"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Slash1 = {Animation = Tool:WaitForChild("Slash1"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 9, Max = 12}},
	Slash2 = {Animation = Tool:WaitForChild("Slash2"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 9, Max = 12}},
	Blast = {Animation = Tool:WaitForChild("Blast"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5},
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
}

TouchDamage = {Min = 2, Max = 2}

Clicks = 0
FirstClick = false

ToolEquipped = false
Attacking = false
Blocking = false
BlockTick = 0

Special = {
	Enabled = true,
	Active = false,
	ReloadTime = 20,
	Damage = 30,
	Radius = 15,
	PushBack = 75,
}

ReloadTime = 1

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
	DamageAmount = ((Blocking and (DamageAmount / 2)) or DamageAmount)
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	humanoid:TakeDamage(DamageAmount)
	
end

function Attack(PossibleAnims)
	if PossibleAnims and #PossibleAnims > 0 then
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
	ShieldWeld.C0 = CFrame.new(-0.5, -0.25, 0.125) * CFrame.Angles((math.pi / 10), (math.pi / 2.125), -(math.pi / 2))
	ShieldWeld.Parent = Shield
	Shield.Parent = Tool
end

function GetTotalParts(MaxParts, PossibleParts, Parts)
	if MaxParts < PossibleParts then
		return MaxParts
	elseif Parts >= MaxParts then
		return 0
	elseif MaxParts >= PossibleParts then
		local PartCount = (MaxParts - PossibleParts)
		if Parts <= MaxParts then
			PartCount = (MaxParts - Parts)
			if PartCount > PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		elseif PartCount >= PossibleParts then
			return PossibleParts
		else
			return PartCount
		end
	end
end

function GetParts(Region, MaxParts, Ignore)
	local Parts = {}
	local RerunFailed = false
	while #Parts < MaxParts and not RerunFailed do
		local Region = Region
		local PossibleParts = GetTotalParts(MaxParts, 100, #Parts)
		local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
		if #PartsNearby == 0 then
			RerunFailed = true
		else
			for i, v in pairs(PartsNearby) do
				table.insert(Parts, v)
				table.insert(Ignore, v)
			end
		end
	end
	return Parts
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
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

function Activated()
	if not Tool.Enabled or not ToolEquipped or Special.Active then
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
		if Clicks == 1 or not Special.Enabled or Blocking then
			Sounds.Slash:Play()
			AttackAnims = {Animations.Slash1, Animations.Slash2}
		elseif Clicks > 1 and not Blocking and Special.Enabled then
			Special.Enabled = false
			Special.Active = true
			local Animation = Animations.Blast
			Spawn(function()
				InvokeClient("PlayAnimation", Animation)
			end)
			wait(Animation.Duration / 2)
			local NegativeRegion = (Torso.Position - Vector3.new(Special.Radius, (Torso.Size.Y * 1.5), Special.Radius))
			local PositiveRegion = (Torso.Position + Vector3.new(Special.Radius, Special.Radius, Special.Radius))
			local Region = Region3.new(NegativeRegion, PositiveRegion)
			local IgnoreList = {Character}
			for i, v in pairs(Players:GetChildren()) do
				if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and IsTeamMate(Player, v) then
					table.insert(IgnoreList, v.Character)
				end
			end
			local Parts = GetParts(Region, 1000, IgnoreList)
			local Humanoids = {}
			for i, v in pairs(Parts) do
				local character = v.Parent
				if character:IsA("Hat") then
					character = character.Parent
				end
				local humanoid = character:FindFirstChild("Humanoid")
				local torso = character:FindFirstChild("Torso")
				if humanoid and humanoid.Health > 0 and torso and not CheckTableForInstance(Humanoids, humanoid) then
					table.insert(Humanoids, humanoid)
				end
			end
			for i, v in pairs(Humanoids) do
				local humanoid = v
				if humanoid and humanoid.Parent and humanoid.Health > 0 then
					local character = humanoid.Parent
					if character then
						local torso = character:FindFirstChild("Torso")
						if torso then
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(Special.Damage)
							humanoid.Sit = true
							torso.Velocity = (CFrame.new(Torso.Position, torso.Position).lookVector * Special.PushBack)
						end
					end
				end
			end
			Special.Active = false
			Delay(Special.ReloadTime, (function()
				Special.Enabled = true
			end))
		end
		Attack(AttackAnims)
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
		Sounds.Unsheath:Play()
		InvokeClient("PlayAnimation", Animations.Hold)
	end)
	Spawn(CreateShield)
	ToolEquipped = true
end

function Unequipped()
	Attacking = false
	Blocking = false
	FirstClick = false
	Special.Active = false
	Clicks = 0
	for i, v in pairs({ToolUnequipped, Shield, ReduceDamage}) do
		if tostring(v) == "Connection" then
			v:disconnect()
		elseif type(v) == "userdata" and v and v.Parent then
			v:Destroy()
		end
	end
	if CheckIfAlive() then
		SetHumanoid(Humanoid, 100, 16)
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
	if Mode == "Button1Click" then
		local Down = Value.Down
	elseif Mode == "KeyPress" then
		local Key = Value.Key
		local Down = Value.Down
		if Key == "q" and not Special.Active then
			if Down and not Blocking then
				local LeftArm = Character:FindFirstChild("Left Arm")
				if not LeftArm or not Shield or not Shield.Parent then
					return
				end
				Blocking = true
				Spawn(function()
					InvokeClient("PlayAnimation", Animations.Block)
				end)
				if ReduceDamage then
					ReduceDamage:disconnect()
				end
				IgnoreHealthChange = false
				local CurrentHealth = Humanoid.Health
				ReduceDamage = Humanoid.Changed:connect(function(Property)
					local NewHealth = Humanoid.Health
					if not IgnoreHealthChange and NewHealth ~= Humanoid.MaxHealth then
						if NewHealth < CurrentHealth then
							local DamageDealt = (CurrentHealth - NewHealth)
							IgnoreHealthChange = true
							Humanoid.Health = (Humanoid.Health + (DamageDealt / 2))
							IgnoreHealthChange = false
						end
					end
					CurrentHealth = NewHealth
				end)
				SetHumanoid(Humanoid, 200, 8)
			elseif not Down and Blocking then
				Blocking = false
				if ReduceDamage then
					ReduceDamage:disconnect()
				end
				SetHumanoid(Humanoid, 100, 16)
				Spawn(function()
					InvokeClient("StopAnimation", Animations.Block)
				end)
			end
		end
	end
end)

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)