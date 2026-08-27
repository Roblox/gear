--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Fire = Handle:WaitForChild("Fire")

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

AnimationsBin = Tool:WaitForChild("Animations")

Animations = {
	Hold = {Animation = AnimationsBin:WaitForChild("Hold"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Slash = {Animation = AnimationsBin:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	Jab = {Animation = AnimationsBin:WaitForChild("Jab"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 20}},
	ClockwiseWhip = {Animation = AnimationsBin:WaitForChild("ClockwiseWhip"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 25}},
	CounterClockwiseWhip = {Animation = AnimationsBin:WaitForChild("CounterClockwiseWhip"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 25}},
	Spin = {Animation = AnimationsBin:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 15, Max = 15}},
	DownwardSpin = {Animation = AnimationsBin:WaitForChild("DownwardSpin"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 8, Max = 8}},
}

Sounds = {
	Swing = Handle:WaitForChild("Swing"),
	Hit = Handle:WaitForChild("Hit"),
}

TouchDamage = {Min = 0, Max = 0}

Rate = (1 / 60)

ToolEquipped = false

Remotes = Tool:WaitForChild("Remotes")

ServerControl = (Remotes:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Remotes

ClientControl = (Remotes:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Remotes

Handle.Transparency = 0
Fire.Enabled = true
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
			local torso = character:FindFirstChild("Torso")
			if torso then
				torso.Velocity = CFrame.new(Part.Position, torso.Position).lookVector * 40
			end
			humanoid.Sit = true
		end
		
		Billboard((Part.CFrame * CFrame.new(0, 0, (Part.Size.Z / 2)).p + Vector3.new(0, 1.5, 0)), FinalizedDamage, 1.5, BrickColor.new("Bright red").Color)
		
		humanoid:TakeDamage(FinalizedDamage)
		
		if humanoid.Health <= 0 then
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("BasePart") then
					v.Name = "Part"
					v.CanCollide = false
					v:BreakJoints()
					if v.Transparency < 1 then
						local Gravity = 196.20
						local Weight = (v:GetMass() * Gravity)
						local Speed = 50
						local Direction = (CFrame.new() * CFrame.Angles(math.random(-360, 360), math.random(-360, 360), math.random(-360, 360))).lookVector --CFrame.new(Handle.Position, v.Position).lookVector
						local Velocity = ((Direction + Vector3.new(0, (math.random(35, 60) * 0.01), 0)) * Speed)
						v.BrickColor = BrickColor.new("Really black")
						v.Material = Enum.Material.Neon
						v.Transparency = 0.1
						v.Velocity = Velocity
						Debris:AddItem(v, 3)
					end
				end
			end
		end
		
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
		local BaseBlade = BasePart:Clone()
		BaseBlade.Name = "Blade"
		BaseBlade.Transparency = 1
		BaseBlade.Size = Vector3.new(0.25, 0.75, 2)
		BaseBlade.CanCollide = false
		local Blades = {
			(CFrame.new(((Handle.Size.X / 2) + (BaseBlade.Size.X / 1)), -((Handle.Size.Y / 2) + (BaseBlade.Size.Y / 2) - BaseBlade.Size.Y - 0), -((Handle.Size.Z / 2) + (BaseBlade.Size.Z / 2) - BaseBlade.Size.Z - 0.5)) * CFrame.Angles(0, (math.pi / 8), 0)),
			(CFrame.new(-((Handle.Size.X / 2) + (BaseBlade.Size.X / 1)), ((Handle.Size.Y / 2) + (BaseBlade.Size.Y / 2) - BaseBlade.Size.Y - 0), ((Handle.Size.Z / 2) + (BaseBlade.Size.Z / 2) - BaseBlade.Size.Z - 0.5)) * CFrame.Angles(0, (math.pi / 8), 0)),
		}
		for i, v in pairs(Blades) do 
			local Blade = BaseBlade:Clone()
			local BladeWeld = Instance.new("Weld")
			BladeWeld.Part0 = Handle
			BladeWeld.Part1 = Blade
			BladeWeld.C0 = v
			BladeWeld.Parent = Blade
			Blow(Blade)
			Blade.Parent = Tool
		end
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	local AttackAnims = {Animations.Slash, Animations.Jab, Animations.ClockwiseWhip, Animations.CounterClockwiseWhip, Animations.Spin, Animations.DownwardSpin}
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
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Hold)
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