--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

Animations = {
	Whack = {Animation = Tool:WaitForChild("Whack"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 12, Max = 15}},
	Bash = {Animation = Tool:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 5, Duration = 0.85, Damage = {Min = 12, Max = 15}},
	SideSwipe = {Animation = Tool:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 16, Max = 22}},
}

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Hit = Handle:WaitForChild("Hit"),
}

Clicks = 0
FirstClick = false

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
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

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not CurrentAnimation then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 then
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
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	local HumanoidFound = false
	for i, v in pairs(HitHumanoids) do
		if v.Humanoid == humanoid then
			local Index = HitHumanoids[i]
			Index.Hits = (Index.Hits + 1)
			HitHumanoids[i] = Index
			if Index.Hits >= Index.MaxHits then
				HumanoidFound = true
			end
		end
	end
	if HumanoidFound then
		return
	end
	Sounds.Hit:Play()
	table.insert(HitHumanoids, {Humanoid = humanoid, Hits = 0, MaxHits = math.random(1, 3)})
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	local DamageValue = CurrentAnimation.Damage
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	--[[local ForceField = nil
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("ForceField") then
			ForceField = v
		end
	end
	if not ForceField then
		local TakeChance = math.random(1, 10)
		local IgnoreParts = {"Head", "Torso", "HumanoidRootPart"}
		if TakeChance == 1 and not CheckTableForString(IgnoreParts, Hit.Name) then
			Hit.Parent = Tool
			local NewSize = Vector3.new(0.5, 0.5, 0.5)
			if Hit:GetMass() > (NewSize.X * NewSize.Y * NewSize.Z) then
				Hit.Size = NewSize
			end
			Hit.Name = "Effect"
			Hit.CanCollide = false
			Hit:BreakJoints()
			local Weld = Instance.new("Weld")
			Weld.Name = "Stick"
			Weld.Part0 = Handle
			Weld.Part1 = Hit
			local HitCFrame = Hit.CFrame
			local PX, PY, PZ, R00, R01, R02, R10, R11, R12, R20, R21, R22 = HitCFrame:components()
			local DistanceBetween = (HitCFrame.p - Handle.Position).Magnitude
			local HitDirection = CFrame.new(HitCFrame.p, Handle.Position)
			local StickCFrame = (HitCFrame + HitDirection.lookVector * ((DistanceBetween / 2) + 0.5))
			StickCFrame = CFrame.new(StickCFrame.p.X, StickCFrame.p.Y, StickCFrame.p.Z, R00, R01, R02, R10, R11, R12, R20, R21, R22)
			Weld.C0 = Handle.CFrame:inverse()
			Weld.C1 = StickCFrame:inverse()
			Weld.Parent = Hit
		end
	end]]
	humanoid:TakeDamage(DamageAmount)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
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
		local SingleClickAnims = {Animations.Bash}
		local DoubleClickAnims = {Animations.Whack, Animations.SideSwipe}
		local SlashSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
		SlashSounds[math.random(1, #SlashSounds)]:Play()
		CurrentAnimation = (((Clicks < 2 or #DoubleClickAnims == 0) and SingleClickAnims[math.random(1, #SingleClickAnims)]) or DoubleClickAnims[math.random(1, #DoubleClickAnims)])
		HitHumanoids = {}
		Spawn(function()
			InvokeClient("PlayAnimation", CurrentAnimation)
		end)
		wait(CurrentAnimation.Duration)
		HitHumanoids = {}
		CurrentAnimation = nil
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	Spawn(function()
		local Limbs = {Character:WaitForChild("Right Arm")}
		for i, v in pairs(Limbs) do
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = v, Transparency = 0, AutoUpdate = false})
			end)
		end
	end)
	ToolEquipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
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

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)