--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")
GhostFire = Handle:WaitForChild("GhostFire")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Kills = Tool:WaitForChild("Kills")


BaseUrl = "http://www.roblox.com/asset/?id="

IconImages = {37755007, 37755011, 37755016, 37755024, 37755034, 37755036, 37755042, 37755045, 37755047, 37755054}

Grips = {
	Up = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0),
	Out = CFrame.new(0, 0, -1.5, 0, -1, -0, -1, 0, -0, 0, 0, -1),
}

DamageValues = {
	BaseDamage = 10,
	SlashDamage = 10,
	LungeDamage = 20,
	Upgrade = {
		Min = 15,
		Max = 25,
	},
}

Damage = DamageValues.BaseDamage

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Lunge = Handle:WaitForChild("Lunge"),
	Unsheath = Handle:WaitForChild("Unsheath"),
	Ghost = Handle:WaitForChild("Ghost")
}

LastAttack = 0
TransparentParts = {}
ToolEquipped = false

Kills.Value = 0
Handle.Transparency = 0.7
Tool.Name = "Ghostwalker"
Tool.TextureId = (BaseUrl .. "89722223")
Tool.Enabled = true

function SwordUp()
	Tool.Grip = Grips.Up
end

function SwordOut()
	Tool.Grip = Grips.Out
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

function SetTransparency(PrimaryParent, Transparency)
	local Parts = {}
	local function SetParentTransparency(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v ~= Tool then
				if v ~= RootPart then
					local ItemTransparency = nil
					for ii, vv in pairs(TransparentParts) do
						if vv and vv.Part and vv.Part == v then
							ItemTransparency = vv.Transparency
						end
					end
					pcall(function()
						table.insert(Parts, {Part = v, Transparency = (ItemTransparency or v.Transparency)})
						v.Transparency = Transparency
					end)
				end
				SetParentTransparency(v, Transparency)
			end
		end
	end
	SetParentTransparency(PrimaryParent)
	return Parts
end

function MakeGhostly(Transparency)
	for i, v in pairs({GhostlyItemAdded, GhostlyItemRemoved}) do
		if v then
			v:disconnect()
		end
	end
	if Transparency <= 0 then
		for i, v in pairs(TransparentParts) do
			if v and v.Part and v.Part.Parent then
				v.Part.Transparency = v.Transparency
			end
		end
		TransparentParts = {}
			return
	end
	TransparentParts = SetTransparency(Character, Transparency)
	GhostlyItemAdded = Character.DescendantAdded:connect(function(Child)
		if Child:IsA("BasePart") then
			if Child == Handle then
				return
			end
			for i, v in pairs(SetTransparency(Child, Transparency)) do
				table.insert(TransparentParts, v)
			end
		end
	end)
	GhostlyItemRemoved = Character.DescendantRemoving:connect(function(Child)
		if Child:IsA("BasePart") then
			for ii, vv in pairs(TransparentParts) do
				if vv.Part == Child then
					vv.Part.Transparency = vv.Transparency
					table.remove(TransparentParts, ii)
				end
			end
		end
	end)
end

function ManagePower()
	local Power = Kills.Value
	Tool.Name = "Ghostwalker (" .. Power .. ")"
	if (Power >= 0 and Power <= Kills.MaxValue) then
		Tool.TextureId = (BaseUrl .. IconImages[Power + 1])
	end
	local DmgInc = (DamageValues.Upgrade.Min + (DamageValues.Upgrade.Max - DamageValues.Upgrade.Min) * (Power / Kills.MaxValue))
	DamageValues.SlashDamage = DmgInc
	DamageValues.LungeDamage = (2 * DmgInc)
	print(DamageValues.SlashDamage)
	MakeGhostly(0.2 + ((Power / Kills.MaxValue) * 0.8))
end

function UpdateGhostState(Enabled)
	if GhostEffect and GhostEffect.Parent then
		GhostEffect:Destroy()
	end
	for i, v in pairs({ItemAdded, ItemRemoved}) do
		if v then
			v:disconnect()
		end
	end
	if not Enabled then
		MakeGhostly(0)
	else
		
		local Gravity = game:GetService("Workspace").Gravity
		
		local function CalcWeight(Mass)
			return (Mass * Gravity * 0.85)
		end
		
		local Mass = 0
		for i, v in pairs(GetAllConnectedParts(RootPart)) do
			Mass = (Mass + v:GetMass())
		end
		GhostEffect = Instance.new("BodyForce")
		GhostEffect.Name = "GhostEffect"
		GhostEffect.force = Vector3.new(0, CalcWeight(Mass), 0)
		GhostEffect.Parent = RootPart
		
		ManagePower()
		
		ItemAdded = Character.DescendantAdded:connect(function(Child)
			if Child:IsA("BasePart") then
				GhostEffect.force = (GhostEffect.force + Vector3.new(0, CalcWeight(Child:GetMass()), 0))
			end
		end)
		ItemRemoved = Character.DescendantRemoving:connect(function(Child)
			if Child:IsA("BasePart") then
				GhostEffect.force = (GhostEffect.force - Vector3.new(0, CalcWeight(Child:GetMass()), 0))
			end
		end)
	end
	
end

function Attack()
	Damage = DamageValues.SlashDamage
	Sounds.Slash:Play()
	local Anim = Instance.new("StringValue")
	Anim.Name = "toolanim"
	Anim.Value = "Slash"
	Anim.Parent = Tool
end

function Lunge()
	Damage = DamageValues.LungeDamage
	Sounds.Lunge:Play()
	local Anim = Instance.new("StringValue")
	Anim.Name = "toolanim"
	Anim.Value = "Lunge"
	Anim.Parent = Tool	
	local Force = Instance.new("BodyVelocity")
	Force.velocity = Vector3.new(0, 10, 0) 
	Force.maxForce = Vector3.new(0, 4000, 0)
	Debris:AddItem(Force, 0.5)
	Force.Parent = RootPart
	wait(0.25)
	SwordOut()
	wait(0.25)
	if Force and Force.Parent then
		Force:Destroy()
	end
	wait(0.5)
	SwordUp()
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	local RightArm = (Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand"))
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
	print(Damage)
	if humanoid.Health <= 0 then
		Kills.Value = (Kills.Value + 1)
		ManagePower()
		Sounds.Ghost:Play()
		Delay(0.01, (function()
			GhostFire.Enabled = true
			wait(0.3)
			GhostFire.Enabled = false
		end))
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local Tick = RunService.Stepped:wait()
	if (Tick - LastAttack) < 0.2 then
		Lunge()
	else
		Attack()
	end
	Damage = DamageValues.BaseDamage
	LastAttack = Tick
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent and Player and Player.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		UpdateGhostState(true)
	end)
	Sounds.Unsheath:Play()
end

function Unequipped()
	Spawn(function()
		UpdateGhostState(false)
	end)
	ToolEquipped = false
end

SwordUp()

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)