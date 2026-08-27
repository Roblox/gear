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

AnimationsBin = Tool:WaitForChild("Animations")
R6Anims = AnimationsBin:WaitForChild("R6")
R15Anims = AnimationsBin:WaitForChild("R15")

Animations = {
	Equip = {Animation = R6Anims:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1.7},
	DownLeftSlash = {Animation = R6Anims:WaitForChild("DownLeftSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	DownRightSlash = {Animation = R6Anims:WaitForChild("DownRightSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	UpLeftSlash = {Animation = R6Anims:WaitForChild("UpLeftSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	UpRightSlash = {Animation = R6Anims:WaitForChild("UpRightSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	UpSlash = {Animation = R6Anims:WaitForChild("UpSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	DownSlash = {Animation = R6Anims:WaitForChild("DownSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	UpperSlash = {Animation = R6Anims:WaitForChild("UpperSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	OuterSlash = {Animation = R6Anims:WaitForChild("OuterSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	R15Equip = {Animation = R15Anims:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1.7},
	R15DownLeftSlash = {Animation = R15Anims:WaitForChild("DownLeftSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	R15DownRightSlash = {Animation = R15Anims:WaitForChild("DownRightSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	R15UpLeftSlash = {Animation = R15Anims:WaitForChild("UpLeftSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	R15UpRightSlash = {Animation = R15Anims:WaitForChild("UpRightSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	R15UpSlash = {Animation = R15Anims:WaitForChild("UpSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	R15DownSlash = {Animation = R15Anims:WaitForChild("DownSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	R15UpperSlash = {Animation = R15Anims:WaitForChild("UpperSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
	R15OuterSlash = {Animation = R15Anims:WaitForChild("OuterSlash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.5},
}

Sounds = {
	SwordSlash = Handle:WaitForChild("SwordSlash"),
	SwordSheath = Handle:WaitForChild("SwordSheath"),
	SwordClash = Handle:WaitForChild("SwordClash"),
	SwordScrape = Handle:WaitForChild("SwordScrape"),
	SwordStrike = Handle:WaitForChild("SwordStrike"),
	SwordCollide = Handle:WaitForChild("SwordCollide"),
}

GripOffset = 0.125
Grips = {
	Equipped = CFrame.new(0, -1.65, 0, 1, 0, -0, 0, 1, 0, 0, 0, 1),
	Lunge = CFrame.new(0, -1.65, 0, 1, 0, 0, 0, 0, -1, -0, 1, 0),
	LungeUp = CFrame.new(0, -1.65, 0, 1, 0, 0, 0, GripOffset, -1, -0, 1, GripOffset),
	LungeDown = CFrame.new(0, -1.65, 0, 1, 0, 0, 0, -GripOffset, -1, -0, 1, -GripOffset),
	LungeLeft = CFrame.new(0, -1.65, 0, 1, -0, GripOffset, GripOffset, 0, -1, 0, 1, 0),
	LungeRight = CFrame.new(0, -1.65, 0, 1, -0, -GripOffset, -GripOffset, 0, -1, 0, 1, 0),
}

Damages = {
	Touched = {Min = 5, Max = 8},
	Hit = {Min = 10, Max = 15}
}

HitHumanoids = {}
SoundPlayable = false
LastAnimation = 0

ToolEquipped = false
MouseDown = false

Remotes = Tool:WaitForChild("Remotes")
ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

Tool.Grip = Grips.Equipped
Tool.Enabled = true

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

function Billboard(Pos, Text, Time, Color)
	local Rate = (1 / 30)
	local Pos = (Pos or Vector3.new(0, 0, 0))
	local Text = (Text or "")
	local Time = (Time or 2)
	local Color = (Color or Color3.new(1, 0, 0))
	local EffectPart = BasePart:Clone()
	EffectPart.Name = "Effect"
	EffectPart.Size = Vector3.new(0, 0, 0)
	EffectPart.CFrame = CFrame.new(Pos)
	EffectPart.Anchored = true
	EffectPart.CanCollide = false
	EffectPart.Transparency = 1
	local BillboardGui = Instance.new("BillboardGui")
	BillboardGui.Size = UDim2.new(3, 0, 3, 0)
	BillboardGui.Adornee = EffectPart
	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.Text = Text
	TextLabel.TextColor3 = Color
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.ArialBold
	TextLabel.Parent = BillboardGui
	BillboardGui.Parent = EffectPart
	Debris:AddItem(EffectPart, (Time + 0.1))
	EffectPart.Parent = game:GetService("Workspace")
	Delay(0, function()
		local Frames = (Time / Rate)
		for Frame = 1, Frames do
			wait(Rate)
			local Percent = (Frame / Frames)
			EffectPart.CFrame = CFrame.new(Pos) + Vector3.new(0, Percent, 0)
			TextLabel.TextTransparency = Percent
		end
		if EffectPart and EffectPart.Parent then
			EffectPart:Destroy()
		end
	end)
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 or humanoid == Humanoid then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
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
	if SoundPlayable then
		SoundPlayable = false
		local SlashSounds = {Sounds.SwordClash, Sounds.SwordScrape, Sounds.SwordStrike, Sounds.SwordCollide}
		SlashSounds[math.random(1, #SlashSounds)]:Play()
	end
	local DamageValue = ((CurrentAnimation and Damages.Hit) or Damages.Touched)
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	if CurrentAnimation then
		table.insert(HitHumanoids, {Humanoid = humanoid, Hits = 0, MaxHits = math.random(1, 3)})
		local Radius = Vector3.new(1.25, 0.25, 1.25)
		Radius = (Radius * 100)
		local Offset = Vector3.new(math.random(-Radius.X, Radius.X), math.random(-Radius.Y, Radius.Y), math.random(-Radius.Z, Radius.Z))
		Offset = Offset * Vector3.new(0.01, 0.01, 0.01)
		Billboard((Handle.Position + Offset + Vector3.new(0, 2.5, 0)), DamageAmount, 2, BrickColor.new("Really red").Color)
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DamageAmount)
end

function ChooseIndex(Table, LastIndex)
	local IndexChosen = math.random(1, #Table)
	if LastIndex == IndexChosen then
		return ChooseIndex(Table, LastIndex)
	else
		return IndexChosen
	end
end

function Activated()
	if not ToolEquipped or not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	SoundPlayable = true
	local SlashAnimations = {Animations.DownLeftSlash, Animations.DownRightSlash, Animations.UpLeftSlash, Animations.UpRightSlash, Animations.UpSlash, Animations.DownSlash, Animations.UpperSlash, Animations.OuterSlash}
	if Humanoid.RigType == Enum.HumanoidRigType.R15 then
		SlashAnimations = {Animations.R15DownLeftSlash, Animations.R15DownRightSlash, Animations.R15UpLeftSlash, Animations.R15UpRightSlash, Animations.R15UpSlash, Animations.R15DownSlash, Animations.R15UpperSlash, Animations.R15OuterSlash}
	end
	local SwordGrips = {Grips.Lunge, Grips.LungeLeft, Grips.LungeRight, Grips.LungeUp, Grips.LungeDown}
	Sounds.SwordSlash:Play()
	Tool.Grip = SwordGrips[math.random(1, #SwordGrips)]
	LastAnimation = ChooseIndex(SlashAnimations, LastAnimation)
	CurrentAnimation = SlashAnimations[LastAnimation]
	HitHumanoids = {}
	Spawn(function()
		InvokeClient("PlayAnimation", CurrentAnimation)
	end)
	wait(CurrentAnimation.Duration)
	local BuildUp = false
	local BuildUpAttack = Tool.Activated:connect(function()
		BuildUp = true
	end)
	HitHumanoids = {}
	Delay(0.75, (function()
		if BuildUpAttack then
			BuildUpAttack:disconnect()
		end
		if BuildUp then
			return
		end
		CurrentAnimation = nil
		SoundPlayable = false
		Tool.Grip = Grips.Equipped
	end))
	Tool.Enabled = true
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
	Tool.Grip = Grips.Equipped
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Sounds.SwordSheath:Play()
	local Animation = ((Humanoid.RigType == Enum.HumanoidRigType.R6 and Animations.Equip) or Animations.R15Equip)
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	wait(Animation.Duration)
	if not CurrentlyEquipped then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Tool.Grip = Grips.Equipped
	MouseDown = false
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
	if player ~= Player or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)