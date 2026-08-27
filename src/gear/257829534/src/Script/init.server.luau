--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Functions = require(script:WaitForChild("Functions"))

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

Animations = {
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = 0, Weight = nil, Speed = 3, Damage = {Min = 5, Max = 8}},
	Slice = {Animation = Tool:WaitForChild("Slice"), FadeTime = 0, Weight = 1, Speed = 2.5, Damage = {Min = 5, Max = 8}},
	Bash = {Animation = Tool:WaitForChild("Bash"), FadeTime = 0, Weight = nil, Speed = 2, Damage = {Min = 5, Max = 8}},
}

Sounds = {
	Swing = {Sound = Handle:WaitForChild("Swing"), Pitch = {Min = 0.9, Max = 2}},
	Hit = {Sound = Handle:WaitForChild("Hit"), Pitch = {Min = 0.9, Max = 2}},
}

TouchDamage = {Min = 0, Max = 0}

SoundPlayable = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function Blow(Part)
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped then
			return
		end
		
		local character = Hit.Parent
		if character == Character or character == Tool then
			return
		end
		
		local player = Players:GetPlayerFromCharacter(character)
		if player and (Functions.IsTeamMate(Player, player) or player == Player) then
			return
		end
		
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
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
		
		if CurrentAnimation and SoundPlayable then
			SoundPlayable = false
			local Sound = Sounds.Hit
			local SoundCopy = Sound.Sound:Clone()
			SoundCopy.Pitch = (math.random((Sound.Pitch.Min * 1000), (Sound.Pitch.Max * 1000)) * 0.001)
			Debris:AddItem(SoundCopy, 1.5)
			SoundCopy.Parent = Handle
			SoundCopy:Play()
		end
		
		Functions.UntagHumanoid(humanoid)
		Functions.TagHumanoid(humanoid, Player)
		
		local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		
		if FinalizedDamage <= 0 then
			return
		end
			
		humanoid:TakeDamage(FinalizedDamage)
		
		SoundPlayable = false
		
	end)
	return TouchedConnection
end

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		SoundPlayable = true
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		local AnimationState = InvokeClient("PlayAnimation", CurrentAnimation)
		CurrentAnimation = nil
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	local SlashSounds = {Sounds.Swing}
	local SlashSound = SlashSounds[math.random(1, #SlashSounds)]
	SlashSound.Sound.Pitch = (math.random((SlashSound.Pitch.Min * 1000), (SlashSound.Pitch.Max * 1000)) * 0.001)
	SlashSound.Sound:Play()
	local AttackAnims = {Animations.Slash, Animations.Slice, Animations.Bash}
	Attack(AttackAnims)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		if v and v.Sound and v.Sound.Parent then
			v.Sound:Stop()
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

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Blow(Handle)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)