--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Functions = require(script:WaitForChild("Functions"))

StunScript = script:WaitForChild("StunScript")

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
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Whack = {Animation = Tool:WaitForChild("Whack"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 20, Max = 30}},
	Bash = {Animation = Tool:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 15, Max = 20}},
	SideSwipe = {Animation = Tool:WaitForChild("SideSwipe"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 12, Max = 16}},
	R15Equip = {Animation = Tool:WaitForChild("R15Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Whack = {Animation = Tool:WaitForChild("R15Whack"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 20, Max = 30}},
	R15Bash = {Animation = Tool:WaitForChild("R15Bash"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 15, Max = 20}},
	R15SideSwipe = {Animation = Tool:WaitForChild("R15SideSwipe"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 0.85, Damage = {Min = 12, Max = 16}}

}

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Hit = Handle:WaitForChild("Hit"),
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

Tool.Enabled = true

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
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or Functions.IsTeamMate(Player, player)) then
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
	--if CurrentAnimation == Animations.Whack then
		local StunChance = math.random(1, 10)
		if StunChance == 1 then
			local StunScriptCopy = character:FindFirstChild(StunScript.Name)
			if not StunScriptCopy then
				StunScriptCopy = StunScript:Clone()
				local Duration = Instance.new("NumberValue")
				Duration.Name = "Duration"
				Duration.Value = 0
				Duration.Parent = StunScriptCopy
				local JumpDisabler = StunScriptCopy:FindFirstChild("JumpDisabler")
				if JumpDisabler then
					JumpDisabler.Disabled = false
				end
			end
			local Duration = StunScriptCopy:FindFirstChild("Duration")
			if Duration then
				Duration.Value = 3.5
			end
			StunScriptCopy.Disabled = false
			StunScriptCopy.Parent = character
		end
	--end
	Sounds.Hit:Play()
	table.insert(HitHumanoids, {Humanoid = humanoid, Hits = 0, MaxHits = math.random(1, 3)})
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, Player)
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
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		Spawn(function()
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				InvokeClient("PlayAnimation", Animations.R15Equip)
			else
				InvokeClient("PlayAnimation", Animations.Equip)
			end
		end)
		local Limbs = {Character:FindFirstChild("Right Arm")}
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Limbs = {Character:FindFirstChild("RightUpperArm"), Character:FindFirstChild("RightLowerArm"), Character:FindFirstChild("RightHand")}
		end
		for i, v in pairs(Limbs) do
			Spawn(function()
				InvokeClient("SetLocalTransparencyModifier", {Object = v, Transparency = 0, AutoUpdate = false})
			end)
		end
	end)
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
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

function OnServerInvoke(player, mode, value)
	if player ~= Player or not mode or not value then
		return
	end
end

Handle.Touched:connect(Blow)

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)