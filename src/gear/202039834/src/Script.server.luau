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
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1.7},
	DownLeftSlash = {Animation = Tool:WaitForChild("DownLeftSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.25},
	DownRightSlash = {Animation = Tool:WaitForChild("DownRightSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.25},
	UpLeftSlash = {Animation = Tool:WaitForChild("UpLeftSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.25},
	UpRightSlash = {Animation = Tool:WaitForChild("UpRightSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.25},
	UpSlash = {Animation = Tool:WaitForChild("UpSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.25},
	DownSlash = {Animation = Tool:WaitForChild("DownSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.25},
	UpperSlash = {Animation = Tool:WaitForChild("UpperSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.25},
	OuterSlash = {Animation = Tool:WaitForChild("OuterSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.25},
}

Sounds = {
	SwordSlash = Handle:WaitForChild("SwordSlash"),
	SwordSheath = Handle:WaitForChild("SwordSheath"),
	SwordClash = Handle:WaitForChild("SwordClash"),
	SwordScrape = Handle:WaitForChild("SwordScrape"),
	SwordStrike = Handle:WaitForChild("SwordStrike"),
	SwordCollide = Handle:WaitForChild("SwordCollide"),
}

Grips = {
	Equipped = CFrame.new(0, 0.075, 2, 1, 0, -0, 0, 0, 1, 0, -1, 0),
	Lunge = CFrame.new(0, 0.075, 2, 1, 0, -0, 0, 1, 0.000900089624, 0, -0.000900089624, 1),
	LungeUp = CFrame.new(0, 0.075, 2, 1, 0, 0, -0, 0.97, 0.25, 0, -0.25, 0.97),
	LungeDown = CFrame.new(0, 0.075, 2, 1, 0, 0, 0, 0.97, -0.25, -0, 0.25, 0.97),
	LungeLeft = CFrame.new(0, 0.075, 2, 0.97, 0.00207756273, -0.25, 0, 1, 0.00856601074, 0.25, -0.00831025094, 0.97),
	LungeRight = CFrame.new(0, 0.075, 2, 0.97, -0.00183315866, 0.25, 0, 1, 0.00755830668, -0.25, -0.00733263465, 0.97),
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

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Equipped
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player and ToolEquipped then
		if Mode == "MouseClick" and Value then
			local Down = Value.Down
			if Down and not MouseDown and Tool.Enabled then
				Tool.Enabled = false
				MouseDown = true
				while MouseDown do
					Activated()
					wait()
				end
			elseif not Down and MouseDown then
				MouseDown = false
				Tool.Enabled = false
				wait(1)
				Tool.Grip = Grips.Equipped
				Tool.Enabled = true
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
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
	local RightArm = Character:FindFirstChild("Right Arm")
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
		InvokeClient("PlaySound", SlashSounds[math.random(1, #SlashSounds)])
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
	if not ToolEquipped then
		return
	end
	SoundPlayable = true
	local SlashAnimations = {Animations.DownLeftSlash, Animations.DownRightSlash, Animations.UpLeftSlash, Animations.UpRightSlash, Animations.UpSlash, Animations.DownSlash, Animations.UpperSlash, Animations.OuterSlash}
	local SwordGrips = {Grips.Lunge, Grips.LungeLeft, Grips.LungeRight, Grips.LungeUp, Grips.LungeDown}
	InvokeClient("PlaySound", Sounds.SwordSlash)
	Tool.Grip = SwordGrips[math.random(1, #SwordGrips)]
	LastAnimation = ChooseIndex(SlashAnimations, LastAnimation)
	CurrentAnimation = SlashAnimations[LastAnimation]
	HitHumanoids = {}
	InvokeClient("PlayAnimation", CurrentAnimation)
	wait(CurrentAnimation.Duration)
	HitHumanoids = {}
	CurrentAnimation = nil
	SoundPlayable = false
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	Spawn(function()
		for i, v in pairs(Animations) do
			if v and v.Animation then
				InvokeClient("Preload", v.Animation.AnimationId)
			end
		end
	end)
	if EquippedToolUnequipped then
		EquippedToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	EquippedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	wait(0.0125)
	if not EquippedToolUnequipped then
		return
	end
	InvokeClient("PlaySound", Sounds.SwordSheath)
	local Animation = Animations.Equip
	InvokeClient("PlayAnimation", Animation)
	wait(Animation.Duration)
	if not CurrentlyEquipped then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs({EquippedToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	Tool.Grip = Grips.Equipped
	MouseDown = false
	ToolEquipped = false
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)