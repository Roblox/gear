--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Freeze = script:WaitForChild("Freeze")
Slow = script:WaitForChild("Slow")

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

Claw = BasePart:Clone()
Claw.Name = "Claw"
Claw.Size = Vector3.new(0.75, 1.5, 1.25)
Claw.CanCollide = false
ClawMesh = Instance.new("SpecialMesh")
ClawMesh.MeshType = Enum.MeshType.FileMesh
ClawMesh.MeshId = ""
ClawMesh.TextureId = (BaseUrl .. "223067175")
ClawMesh.Scale = Vector3.new(1.5, 1.25, 1.25)
ClawMesh.VertexColor = Vector3.new(1, 1, 1)
ClawMesh.Offset = Vector3.new(0, 0, 0)
ClawMesh.Parent = Claw

SwingSpeed = 0.75

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = (1 / SwingSpeed), Delay = 0, Duration = (1 / SwingSpeed), Damage = {Min = 5, Max = 5}},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Solidify = Handle:WaitForChild("Solidify"),
}

TouchDamage = {Min = 0, Max = 0}

Clicks = 0
FirstClick = false

ToolEquipped = false
Attacking = false
Blocking = false
MouseDown = false

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

Handle.Transparency = 0
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

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not CurrentAnimation then
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
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	humanoid:TakeDamage(DamageAmount)
	
	local FreezeChance = math.random(1, 10)
	if FreezeChance == 1 then
		local FreezeScript = character:FindFirstChild(Freeze.Name)
		if not FreezeScript then
			FreezeScript = Freeze:Clone()
			FreezeScript.Disabled = false
			FreezeScript.Parent = character
			Sounds.Solidify.Pitch = (math.random(5, 25) * 0.1)
			Sounds.Solidify:Play()
		end
	end
	
	local SlowScript = character:FindFirstChild(Slow.Name)
	if not SlowScript then
		SlowScript = Slow:Clone()
		SlowScript.Disabled = false
		SlowScript.Parent = character
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

function SetHumanoid(humanoid, MaxHealth, WalkSpeed)
	if not humanoid or not humanoid.Parent or humanoid.Health == 0 then
		return
	end
	local Ratio = (humanoid.Health / humanoid.MaxHealth)
	humanoid.WalkSpeed = WalkSpeed
	humanoid.MaxHealth = MaxHealth
	humanoid.Health = (Ratio * humanoid.MaxHealth)
end

function CreateClaws()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")
	
	LeftClaw = Claw:Clone()
	LeftClaw.Name = "LeftClaw"
	LeftClaw.Mesh.MeshId = (BaseUrl .. "223066851")
	
	RightClaw = Claw:Clone()
	RightClaw.Name = "RightClaw"
	RightClaw.Mesh.MeshId = (BaseUrl .. "223066820")
	
	LeftWeld = Instance.new("Weld")
	LeftWeld.Part1 = LeftClaw
	LeftWeld.C0 = CFrame.new(0.075, -1.75, -0.2) * CFrame.Angles(0, math.pi, 0)
	LeftWeld.Parent = LeftClaw
	
	RightWeld = Instance.new("Weld")
	RightWeld.Part1 = RightClaw
	RightWeld.C0 = CFrame.new(0.075, -1.75, -0.2) * CFrame.Angles(0, math.pi, 0)
	RightWeld.Parent = RightClaw
	
	for i, v in pairs({{Arm = LeftArm, Claw = LeftClaw, Weld = LeftWeld}, {Arm = RightArm, Claw = RightClaw, Weld = RightWeld}}) do
		if v.Arm and v.Arm.Parent then
			v.Weld.Part0 = v.Arm
			v.Claw.Touched:connect(Blow)
			v.Claw.Parent = Tool
		end
	end
	
	if LeftClaw.Parent or RightClaw.Parent then
		Handle.Transparency = 1
	end
	
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
			AttackAnims = {Animations.Slash}
		elseif Clicks > 1 then
			if Blocking then
				AttackSounds = {Sounds.Slash}
				AttackAnims = {Animations.Slash}
			else
				AttackSounds = {Sounds.Slash}
				AttackAnims = {Animations.Slash}
			end
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
		InvokeClient("PlayAnimation", Animations.Equip)
	end)
	Spawn(CreateClaws)
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
	for i, v in pairs({LeftClaw, RightClaw}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Spawn(function()
		for i, v in pairs(Animations) do
			InvokeClient("StopAnimation", v)
		end
	end)
	Handle.Transparency = 0
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
		end
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)