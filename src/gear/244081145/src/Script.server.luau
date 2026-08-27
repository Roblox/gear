--Made by Luckymaxer
--Updated for R15 avatars by StarWars

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
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

AnimationsFolder = Tool.Animations

Animations = {
	Hold = {Animation = AnimationsFolder.R6:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Slash = {Animation = AnimationsFolder.R6:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	Jab = {Animation = AnimationsFolder.R6:WaitForChild("Jab"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 20}},
	ClockwiseWhip = {Animation = AnimationsFolder.R6:WaitForChild("ClockwiseWhip"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 25}},
	CounterClockwiseWhip = {Animation = AnimationsFolder.R6:WaitForChild("CounterClockwiseWhip"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 25}},
	Twirl = {Animation = AnimationsFolder.R6:WaitForChild("Twirl"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 20, Max = 20}},
	Spin = {Animation = AnimationsFolder.R6:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 15}},
	DownwardSpin = {Animation = AnimationsFolder.R6:WaitForChild("DownwardSpin"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 8, Max = 8}},

	R15Hold = {Animation = AnimationsFolder.R15:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Slash = {Animation = AnimationsFolder.R15:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	R15Jab = {Animation = AnimationsFolder.R15:WaitForChild("Jab"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 20}},
	R15ClockwiseWhip = {Animation = AnimationsFolder.R15:WaitForChild("ClockwiseWhip"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 25}},
	R15CounterClockwiseWhip = {Animation = AnimationsFolder.R15:WaitForChild("CounterClockwiseWhip"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 25}},
	R15Twirl = {Animation = AnimationsFolder.R15:WaitForChild("Twirl"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 20, Max = 20}},
	R15Spin = {Animation = AnimationsFolder.R15:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 15}},
	R15DownwardSpin = {Animation = AnimationsFolder.R15:WaitForChild("DownwardSpin"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 8, Max = 8}},
}

Sounds = {
	Swing = Handle:WaitForChild("Swing"),
	Hit = Handle:WaitForChild("Hit"),
}

TouchDamage = {Min = 0, Max = 0}

Rate = (1 / 60)

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

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

function Blow(Part)
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() then
			return
		end
		
		local character = Hit.Parent
		
		local player = Players:GetPlayerFromCharacter(character)
		if player and (IsTeamMate(Player, player) or player == Player) then
			return
		end
		
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if character == Character or not humanoid or humanoid.Health == 0 then
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
		
		Sounds.Hit.Pitch = (math.random(2500, 8000) * 0.001)
		Sounds.Hit:Play()		
		
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		
		local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		
		if FinalizedDamage <= 0 then
			return
		end
		
		local TripChance = math.random(1, 10)
		if TripChance == 1 then
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if torso then
				torso.Velocity = CFrame.new(Part.Position, torso.Position).lookVector * 40
			end
			humanoid.Sit = true
		end
		
		Billboard((Part.CFrame * CFrame.new(0, 0, (Part.Size.Z / 2)).p + Vector3.new(0, 1.5, 0)), FinalizedDamage, 1.5, BrickColor.new("Bright red").Color)
		
		humanoid:TakeDamage(FinalizedDamage)
		
	end)
	return TouchedConnection
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		InvokeClient("PlayAnimation", CurrentAnimation)
		AttackAnimation.Start = tick()
		if AttackAnimation.Duration and AttackAnimation.Duration > 0 then
			wait(AttackAnimation.Duration)
			AttackAnimation.Start = nil
			InvokeClient("StopAnimation", AttackAnimation)
			CurrentAnimation = nil
		end
	end
end

function CreateBlade(Create)
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	if Create then
		Blade = BasePart:Clone()
		Blade.Name = "Blade"
		Blade.Transparency = 1
		Blade.Size = Vector3.new(0.25, 0.25, 2)
		Blade.CanCollide = false
		local BladeWeld = Instance.new("Weld")
		BladeWeld.Part0 = Handle
		BladeWeld.Part1 = Blade
		BladeWeld.C0 = CFrame.new(0, 0, -((Handle.Size.Z / 2) + (Blade.Size.Z / 2) - Blade.Size.Z - 0.5))
		BladeWeld.Parent = Blade
		Blow(Blade)
		Blade.Parent = Tool
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	local AttackAnims = {Animations.Slash, Animations.Jab, Animations.ClockwiseWhip, Animations.CounterClockwiseWhip, Animations.Twirl, Animations.Spin, Animations.DownwardSpin}
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		AttackAnims = {Animations.R15Slash, Animations.R15Jab, Animations.R15ClockwiseWhip, Animations.R15CounterClockwiseWhip, Animations.R15Twirl, Animations.R15Spin, Animations.R15DownwardSpin} 
	end 
	Sounds.Swing.Pitch = (math.random(2500, 6000) * 0.001)
	Sounds.Swing:Play()
	Attack(AttackAnims)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		local Animation = Animations.Hold 
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Hold
		end 
		InvokeClient("PlayAnimation", Animation)
	end)
	Spawn(function()
		CreateBlade(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	CreateBlade(false)
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
end)

CreateBlade(false)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)