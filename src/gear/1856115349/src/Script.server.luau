--Rescripted by Luckymaxer
--Made by Stickmasterluke

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Sparkles = Handle:WaitForChild("Sparkles")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

WeaponHud = Tool:WaitForChild("WeaponHud")
WeaponNameTag = WeaponHud:WaitForChild("WeaponName")
GuiBar = WeaponHud:WaitForChild("Bar")
GuiBarFill = GuiBar:WaitForChild("Fill")
WeaponNameTag.Text = Tool:WaitForChild("ToolName").Value

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
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = nil},
	Hold = {Animation = Tool:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = nil},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = nil},
	Stab1 = {Animation = Tool:WaitForChild("Stab1"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = nil},
	Stab2 = {Animation = Tool:WaitForChild("Stab2"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = nil},
}

Sounds = {
	Swoosh1 = Handle:WaitForChild("Swoosh1"),
	Swoosh2 = Handle:WaitForChild("Swoosh2"),
	Hit1 = Handle:WaitForChild("Hit1"),
	Hit2 = Handle:WaitForChild("Hit2"),
	Hit3 = Handle:WaitForChild("Hit3"),
	Clash1 = Handle:WaitForChild("Clash1"),
	Clash2 = Handle:WaitForChild("Clash2"),
	Clash3 = Handle:WaitForChild("Clash3"),
	Clash4 = Handle:WaitForChild("Clash4"),
	Clash5 = Handle:WaitForChild("Clash5"),
}

Damage = 22 -- +/- 10%
DamageWindow = 1 --How long the player has to hit opponent to deal damage after click
SwingRate = 0.75

BloodEffects = false

Ready = false
ToolEquipped = false
Rate = (1 / 30)
LastSwing = 0

MouseDown = false
CurrentAnimation = nil

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" then
			MouseDown = Value.Down
			if MouseDown then
				Activated()
			end
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local Down = Value.Down
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
	local Pos = (Pos or Vector3.new(0, 0, 0))
	local Text = (Text or "Hello World!")
	local Time = (Time or 2)
	local Color = (Color or Color3.new(1, 0, 0))
	local Pos = (Pos + Vector3.new(0, 5, 0))
	local EffectPart = BasePart:Clone()
	EffectPart.Name = "Effect"
	EffectPart.Size = Vector3.new(0, 0, 0)
	EffectPart.CFrame=CFrame.new(Pos)
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
			EffectPart.CFrame=CFrame.new(Pos) + Vector3.new(0, (5 * Percent), 0)
			TextLabel.TextTransparency = Percent
		end
		if EffectPart and EffectPart.Parent then
			EffectPart:Destroy()
		end
	end)
end

function MakeBlood(Part)
	if not Part then
		return
	end
	local Blood = BasePart:Clone()
	Blood.BrickColor = BrickColor.new("Bright red")
	Blood.Transparency = (math.random(0, 1) * 0.5)
	Blood.CanCollide = ((math.random() < 0.5 and false) or true)
	Blood.Size = Vector3.new((0.2 * math.random(1, 5)), (0.2 * math.random(1, 5)), (0.2 * math.random(1, 5)))
	Blood.Velocity= Part.Velocity + (Vector3.new((math.random() - 0.5), (math.random() - 0.5), (math.random() - 0.5)) * 30)
	Blood.RotVelocity = Part.RotVelocity + (Vector3.new((math.random() - 0.5), (math.random() - 0.5), (math.random() - 0.5)) * 20)
	Blood.CFrame= Part.CFrame * CFrame.new(((math.random() - 0.5) * 3), ((math.random() - 0.5) * 3), ((math.random() - 0.5) * 3)) * CFrame.Angles((math.pi * 2 * math.random()), (math.pi * 2 * math.random()), (math.pi * 2 * math.random()))
	Debris:AddItem(Blood, (math.random() * 4))
	Blood.Parent = game:GetService("Workspace")
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not Ready or not ToolEquipped or (tick() - LastSwing) > DamageWindow then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	if Hit:FindFirstChild("CanBlock") and Handle:FindFirstChild("Blockable") then
		local Ready = false
		local PossibleSounds = {Sounds.Clash1, Sounds.Clash2, Sounds.Clash3, Sounds.Clash4, Sounds.Clash5}
		local Sound = PossibleSounds[math.random(1, #PossibleSounds)]
		Sound:Play()
		Sparkles.Enabled = true
		Delay(0.2, function()
			Sparkles.Enabled = false
		end)
		Billboard(Handle.Position, "Block", 2, Color3.new(1, 1, 0))
	end
	local humanoid = character:FindFirstChild("Humanoid")
	local player = Players:GetPlayerFromCharacter(character)
	local RightArm = Character:FindFirstChild("Right Arm")
	if humanoid and humanoid.Health > 0 and humanoid ~= Humanoid and RightArm then
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if RightGrip and (RightGrip.Part0 == Handle or RightGrip.Part1 == Handle) then
			if player and player ~= Player and not Player.Neutral and not player.Neutral and Player.TeamColor == player.TeamColor then
				return --No team killing
			end
			Ready = false
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid)
			local LocalDamage= math.floor(Damage * (0.9 + (math.random() * 0.2)) + 0.5)
			humanoid:TakeDamage(LocalDamage)
			Billboard(Hit.Position, ("-" .. tostring(LocalDamage)))
			local PossibleSounds = {Sounds.Hit1, Sounds.Hit2, Sounds.Hit3}
			local Sound = PossibleSounds[math.random(1, #PossibleSounds)]
			Sound:Play()
			if BloodEffects then
				local NumBloodEffects = math.ceil(LocalDamage / 10)
				for i = 1, math.random((NumBloodEffects - 1), (NumBloodEffects + 1)) do
					MakeBlood(Hit)
				end
			end
		end
	end
end

function Activated()
	if ToolEquipped and (tick() - LastSwing) >= SwingRate then
		Tool.Enabled = false
		Ready = true
		
		local PossibleSounds = {Sounds.Swoosh1, Sounds.Swoosh2}
		local Sound = PossibleSounds[math.random(1, #PossibleSounds)]
		Sound:Play()
		
		local AttackAnimations = {Animations.LeftSlash, Animations.RightSlash, Animations.Stab1, Animations.Stab2}
		local NewAnimation = AttackAnimations[math.random(1, #AttackAnimations)]
		while NewAnimation == CurrentAnimation do
			NewAnimation = AttackAnimations[math.random(1, #AttackAnimations)]
		end
		
		CurrentAnimation = NewAnimation
		
		InvokeClient("PlayAnimation", CurrentAnimation)

		LastSwing = tick()

		wait(SwingRate)
		
		if MouseDown then
			Activated()
		end
		
		Tool.Enabled = true
	end
end

function UpdateGui()
	local SwingPercent = math.min(((tick() - LastSwing) / SwingRate), 1)
	if SwingPercent < 0.5 then	--fade from red to yellow then to green
		GuiBarFill.BackgroundColor3 = Color3.new(1, (SwingPercent * 2), 0)
	else
		GuiBarFill.BackgroundColor3 = Color3.new((1 - ((SwingPercent - 0.5 ) / 0.5)), 1, 0)
	end
	GuiBarFill.Size = UDim2.new(SwingPercent, 0, 1, 0)
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	PlayerGui = Player:FindFirstChild("PlayerGui")
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	if PlayerGui then
		WeaponHud.Parent = PlayerGui
	end
	InvokeClient("PlayAnimation", Animations.Equip)
	LastSwing = tick()
	Ready = false
	ToolEquipped = true
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	WeaponHud.Parent = Tool
	ToolEquipped = false
	Ready = false
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

Spawn(function()
	while true do
		UpdateGui()
		wait(Rate)
	end
end)