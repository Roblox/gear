--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

CameraShake = script:WaitForChild("CameraShake")

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

local animationFolder = Tool.Animations

Animations = {
	Equip = {Animation = animationFolder.R6:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Whack = {Animation = animationFolder.R6:WaitForChild("Whack"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 20, Max = 30}},
	Bash = {Animation = animationFolder.R6:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 15, Max = 20}},
	SideSwipe = {Animation = animationFolder.R6:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 12, Max = 16}},
	
	R15Equip = {Animation = animationFolder.R6:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Whack = {Animation = animationFolder.R6:WaitForChild("Whack"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 20, Max = 30}},
	R15Bash = {Animation = animationFolder.R6:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 15, Max = 20}},
	R15SideSwipe = {Animation = animationFolder.R6:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 12, Max = 16}}
}

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Hit = Handle:WaitForChild("Hit"),
}

Grips = {
	Unequipped = CFrame.new(0, 0, 1.5, 0, 0, -1, 1, 0, 0, 0, -1, -0),
	Equipped = CFrame.new(-0.25, -0.25, 1.5, -0.379485011, 0.508547366, -0.772897601, 0.75745213, 0.650476396, 0.0560958609, 0.531279027, -0.564145386, -0.632046342)
}

ToolEquipped = false

Clicks = 0
FirstClick = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Unequipped
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "HumanoidJumped" and Value then
			
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
	if not Hit or not Hit.Parent or not CheckIfAlive() or not CurrentAnimation then
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
	if CurrentAnimation == Animations.Whack or CurrentAnimation == Animations.R15Whack then
		local ShakeDuration = 5
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			local playergui = player:FindFirstChild("PlayerGui")
			if playergui then
				local CameraShakeScript = playergui:FindFirstChild("CameraShake")
				if not CameraShakeScript then
					CameraShakeScript = CameraShake:Clone()
					CameraShakeScript.Disabled = false
					local DurationValue = Instance.new("NumberValue")
					DurationValue.Name = "Duration"
					DurationValue.Parent = CameraShakeScript
				end
				local Duration = CameraShakeScript:FindFirstChild("Duration")
				if Duration then
					Duration.Value = ShakeDuration
				end
				CameraShakeScript.Parent = playergui
			end
		end
	end
	Sounds.Hit:Play()
	table.insert(HitHumanoids, {Humanoid = humanoid, Hits = 0, MaxHits = math.random(1, 3)})
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	local DamageValue = CurrentAnimation.Damage
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	local Radius = Vector3.new(1.25, 0.25, 1.25)
	Radius = (Radius * 100)
	local Offset = Vector3.new(math.random(-Radius.X, Radius.X), math.random(-Radius.Y, Radius.Y), math.random(-Radius.Z, Radius.Z))
	Offset = Offset * Vector3.new(0.01, 0.01, 0.01)
	Billboard((Handle.Position + Offset + Vector3.new(0, 2.5, 0)), DamageAmount, 2, BrickColor.new("Really red").Color)
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
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			SingleClickAnims = {Animations.R15Bash}
			DoubleClickAnims = {Animations.R15Whack, Animations.R15SideSwipe}
		end
		local SlashSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
		SlashSounds[math.random(1, #SlashSounds)]:Play()
		CurrentAnimation = (((Clicks < 2 or #DoubleClickAnims == 0) and SingleClickAnims[math.random(1, #SingleClickAnims)]) or DoubleClickAnims[math.random(1, #DoubleClickAnims)])
		Tool.Grip = Grips.Unequipped
		HitHumanoids = {}
		InvokeClient("PlayAnimation", CurrentAnimation)
		wait(CurrentAnimation.Duration)
		HitHumanoids = {}
		Tool.Grip = Grips.Equipped
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
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	local CurrentlyEquipped = true
	EquippedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if EquippedToolUnequipped then
		EquippedToolUnequipped:disconnect()
	end
	if not CurrentlyEquipped then
		return
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	wait(0.125)
	if CurrentlyEquipped then
		Tool.Grip = Grips.Equipped
--		local animation = Animations.Equip
--		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
--			animation = Animations.R15Equip
--		end
--		InvokeClient("PlayAnimation", animation)
		ToolEquipped = true
	end
	Spawn(function()
		local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
		if CurrentlyEquipped then
			InvokeClient("SetLocalTransparencyModifier", {Object = RightArm, Transparency = 0, AutoUpdate = false})
		end
	end)
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	Tool.Grip = Grips.Unequipped
	ToolEquipped = false
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)