--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

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

MorphTime = 30
Kills = 0
Morphed = false

Packages = {
	{68804611, 68804301, 68804361, 68804412, 68804436, 68804480},
	{59721671, 59772137, 59772181, 59772219, 59772279, 59772667},
}


Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1.7},
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 0.8, Damage = {Min = 12, Max = 15}},
	Lunge = {Animation = Tool:WaitForChild("Lunge"), FadeTime = nil, Weight = nil, Speed = 2.25, Duration = 0.8, Damage = {Min = 15, Max = 30}},
	JumpAttack = {Animation = Tool:WaitForChild("JumpAttack"), FadeTime = nil, Weight = nil, Speed = 2.5, Duration = 1, Damage = {Min = 25, Max = 35}},
}

Sounds = {
	Roar = Handle:WaitForChild("Roar"),
	Hit1 = Handle:WaitForChild("Hit1"),
	Hit2 = Handle:WaitForChild("Hit2"),
	Hit3 = Handle:WaitForChild("Hit3"),
	Swoosh1 = Handle:WaitForChild("Swoosh1"),
	Swoosh2 = Handle:WaitForChild("Swoosh2")
}

TouchDamage = {Min = 5, Max = 8}

HumanoidsHit = {}

ToolEquipped = false
MouseDown = false

Clicks = 0
FirstClick = false

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
			local Down = Value.Down
			if Down and not MouseDown then
				MouseDown = true
				Activated()
			elseif not Down and MouseDown then
				MouseDown = false
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

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
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
	
	if CheckTableForInstance(HumanoidsHit, humanoid) then
		return
	end
	
	local HitSounds = {Sounds.Hit1, Sounds.Hit2, Sounds.Hit3}
	HitSounds[math.random(1, #HitSounds)]:Play()
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	DamageAmount = (DamageAmount * (((Morphed and Character == OriginalCharacter) and 2) or 1))
	
	local Radius = Vector3.new(1.25, 0.25, 1.25)
	Radius = (Radius * 100)
	local Offset = Vector3.new(math.random(-Radius.X, Radius.X), math.random(-Radius.Y, Radius.Y), math.random(-Radius.Z, Radius.Z))
	Offset = Offset * Vector3.new(0.01, 0.01, 0.01)
	Billboard((Handle.Position + Offset + Vector3.new(0, 5, 0)), DamageAmount, 2, BrickColor.new("Really red").Color)
	
	table.insert(HumanoidsHit, humanoid)
	Delay(0.5, function()
		for i, v in pairs(HumanoidsHit) do
			if v == humanoid then
				table.remove(HumanoidsHit, i)
			end
		end
	end)
	
	humanoid:TakeDamage(DamageAmount)
	
	if humanoid.Health == 0 and not Morphed then
		Kills = (Kills + 1)
		if Kills >= 5 then
			Sounds.Roar:Play()
			OriginalCharacter = Character
			Kills = 0
			Morphed = true
			local Package = Packages[math.random(1, #Packages)]
			local PlayerAssets = {}
			local MorphAssets = {}
			for i, v in pairs(OriginalCharacter:GetChildren()) do
				if v:IsA("CharacterMesh") or v:IsA("Hat") then
					table.insert(PlayerAssets, v:Clone())
					v:Destroy()
				end
			end
			for i, v in pairs(Package) do
				local AssetModel = InsertService:LoadAsset(v)
				local Asset = AssetModel:GetChildren()[1]:Clone()
				if AssetModel and AssetModel.Parent then
					AssetModel:Destroy()
				end
				table.insert(MorphAssets, Asset)
				Asset.Parent = Character
			end
			wait(MorphTime)
			if OriginalCharacter and OriginalCharacter.Parent then
				for i, v in pairs(MorphAssets) do
					if v and v.Parent then
						v:Destroy()
					end
				end
				for i, v in pairs(PlayerAssets) do
					v.Parent = OriginalCharacter
				end
			end
			Morphed = false
		end
	end
end

function Attack(PossibleAnims)
	if PossibleAnims and #PossibleAnims > 0 then
		local SwooshSounds = {Sounds.Swoosh1, Sounds.Swoosh2}
		SwooshSounds[math.random(1, #SwooshSounds)]:Play()
		CurrentAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		InvokeClient("PlayAnimation", CurrentAnimation)
		if CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
			wait(CurrentAnimation.Duration)
			CurrentAnimation = nil
		end
	end
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
		local AttackAnims = {}
		if Clicks == 1 then
			AttackAnims = {Animations.Slash, Animations.Lunge}
		elseif Clicks > 1 then
			AttackAnims = {Animations.JumpAttack}
		end
		if Clicks > 1 then
			Humanoid.WalkSpeed = 0
		end
		Attack(AttackAnims)
		Humanoid.WalkSpeed = 16
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
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	if EquippedToolUnequipped then
		EquippedToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	EquippedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if not EquippedToolUnequipped then
		return
	end
	local Animation = Animations.Equip
	InvokeClient("PlayAnimation", Animation)
	wait(Animation.Duration)
	if not EquippedToolUnequipped then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	ToolEquipped = false
end

Handle.Touched:connect(Blow)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)