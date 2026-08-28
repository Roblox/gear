--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

InnerPart = Tool:WaitForChild("Inner"):Clone()
InnerPart.Transparency = 0

BasePart = Tool:WaitForChild("Blade"):Clone()
BasePart.Transparency = 0.5
for i, v in ipairs(BasePart:GetChildren()) do
	if v:IsA("SurfaceLight") then
		v.Enabled = true
	end
end
BasePart.Material = Enum.Material.Neon
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false
BasePart.BrickColor = BrickColor.new("Electric blue")

BaseBlade = BasePart:Clone()
BaseBlade.Name = "Blade"
BaseBlade.Reflectance = 0
BaseBlade.Transparency = 0.5
BaseBlade.Size = Vector3.new(0.25, 5.25, 0.25)
BaseBlade.CanCollide = false
BaseInner = InnerPart:Clone()

--for i, v in pairs({"Top", "Bottom", "Left", "Right", "Front", "Back"}) do
--	local Light = Instance.new("SurfaceLight")
--	Light.Name = "Light"
--	Light.Angle = 180
--	Light.Brightness = 25
--	Light.Range = 5
--	Light.Color = Color3.new((0 / 255), (255 / 255), (255 / 255))
--	Light.Face = Enum.NormalId[v]
--	Light.Shadows = false
--	Light.Enabled = true
--	Light.Parent = BaseBlade
--end

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 1.5},
	Bash = {Animation = Tool:WaitForChild("Bash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	--SidewaysJab = {Animation = Tool:WaitForChild("SidewaysJab"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	Slash = {Animation = Tool:WaitForChild("Slash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	InwardSlash = {Animation = Tool:WaitForChild("InwardSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	OutwardSlash = {Animation = Tool:WaitForChild("OutwardSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	UpwardSlash = {Animation = Tool:WaitForChild("UpwardSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	DownwardIdlePose = {Animation = Tool:WaitForChild("DownwardIdlePose"), FadeTime = 0.25, Weight = nil, Speed = 1, Duration = 1, Damage = {Min = 10, Max = 15}},
	SideStepUpperSlash = {Animation = Tool:WaitForChild("SideStepUpperSlash"), FadeTime = 0.25, Weight = nil, Speed = 1.5, Duration = 1, Damage = {Min = 10, Max = 15}},
	--SideStepSpin = {Animation = Tool:WaitForChild("SideStepSpin"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = 1, Damage = {Min = 10, Max = 15}},
	Swipe = {Animation = Tool:WaitForChild("Swipe"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 10, Max = 15}},

	R15Equip = {Animation = Tool:WaitForChild("R15Equip"), FadeTime = nil, Weight = nil, Speed = 4, Duration = 1.5},
	R15Bash = {Animation = Tool:WaitForChild("R15Bash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.5, Damage = {Min = 10, Max = 15}},

	R15Slash = {Animation = Tool:WaitForChild("R15Slash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	R15InwardSlash = {Animation = Tool:WaitForChild("R15InwardSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	R15OutwardSlash = {Animation = Tool:WaitForChild("R15OutwardSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	R15UpwardSlash = {Animation = Tool:WaitForChild("R15UpwardSlash"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	R15Spin = {Animation = Tool:WaitForChild("R15Spin"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.5, Damage = {Min = 10, Max = 15}},
	R15DownwardIdlePose = {Animation = Tool:WaitForChild("R15DownwardIdlePose"), FadeTime = 0.25, Weight = nil, Speed = 1, Duration = 1, Damage = {Min = 10, Max = 15}},
	R15SideStepUpperSlash = {Animation = Tool:WaitForChild("R15SideStepUpperSlash"), FadeTime = 0.25, Weight = nil, Speed = 1.5, Duration = 1, Damage = {Min = 10, Max = 15}},
	
	R15Swipe = {Animation = Tool:WaitForChild("R15Swipe"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.5, Damage = {Min = 10, Max = 15}},	
}

Sounds = {
	Equip = {Sound = Handle:WaitForChild("Equip")},
	Unequip = {Sound = Handle:WaitForChild("Unequip")},
	HitWall = {Sound = Handle:WaitForChild("HitWall")},
	HitPlayer = {Sound = Handle:WaitForChild("HitPlayer"), Pitch = {Min = 1.25, Max = 1.75}},
	Slash1 = {Sound = Handle:WaitForChild("Slash1"), Pitch = {Min = 1, Max = 1.1}},
	Slash2 = {Sound = Handle:WaitForChild("Slash2"), Pitch = {Min = 1, Max = 1.5}},
	Slash3 = {Sound = Handle:WaitForChild("Slash3"), Pitch = {Min = 1, Max = 1.25}},
}

TouchDamage = {Min = 5, Max = 5}

Rate = (1 / 60)

HitSoundDelay = 0.4
HitSoundPlayable = true

ToolActive = false
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

function Blow(Part)
	local TouchedConnection = Part.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or not ToolActive then
			return
		end
		
		local character = Hit.Parent
		if character == Character or character == Tool then
			return
		end
		
		local player = Players:GetPlayerFromCharacter(character)
		if player and (IsTeamMate(Player, player) or player == Player) then
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
		
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if character == Character or not humanoid or humanoid.Health == 0 then
			if CurrentAnimation and HitSoundPlayable then
				HitSoundPlayable = false
				local SoundCopy = Sounds.HitWall.Sound:Clone()
				Debris:AddItem(SoundCopy, 1.5)
				SoundCopy.Parent = Blade
				SoundCopy:Play()
				Delay(HitSoundDelay, (function()
					HitSoundPlayable = true
				end))
			end
			return
		end
		
		if CurrentAnimation and HitSoundPlayable then
			HitSoundPlayable = false
			local Sound = Sounds.HitPlayer
			local SoundCopy = Sound.Sound:Clone()
			SoundCopy.Pitch = (math.random((Sound.Pitch.Min * 1000), (Sound.Pitch.Max * 1000)) * 0.001)
			Debris:AddItem(SoundCopy, 1.5)
			SoundCopy.Parent = Blade
			SoundCopy:Play()
			Delay(HitSoundDelay, (function()
				HitSoundPlayable = true
			end))
		end
		
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		
		local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
		local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
		
		if FinalizedDamage <= 0 then
			return
		end
			
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
		ToolActive = false
		local BladeOffset = Vector3.new(0, -0.175, -0.0375)
		Blade = BaseBlade:Clone()
		Inner = BaseInner:Clone()
		for _, obj in next, Blade:GetChildren() do
			if obj and (obj:IsA("SurfaceLight") or obj:IsA("Beam")) then
				obj.Enabled = true
			elseif obj and obj:IsA("Motor6D") then
				obj:Destroy()
			end
		end
		InnerWeld = Instance.new("Motor6D")
		BladeWeld = Instance.new("Motor6D")
		InnerWeld.Part0 = Handle
		InnerWeld.Part1 = Inner
		InnerWeld.C0 = Blade.CFrame
		BladeWeld.Part0 = Handle
		BladeWeld.Part1 = Blade
		BladeWeld.C0 = CFrame.new((0 + BladeOffset.X), (((Handle.Size.Y / 2) + (BaseBlade.Size.Y / 2)) + BladeOffset.Y), ((((Handle.Size.Z / 2) + (BaseBlade.Size.Z / 2)) / 2) + BladeOffset.Z))
		InnerWeld.C0 = CFrame.new((0 + BladeOffset.X), (((Handle.Size.Y / 2) + (BaseInner.Size.Y / 2)) + BladeOffset.Y), ((((Handle.Size.Z / 2) + (BaseBlade.Size.Z / 2)) / 2) + BladeOffset.Z))
		BladeWeld.Parent = Blade
		InnerWeld.Parent = Inner
--		local OriginalScale = Blade.Size
--		Blade.Size = (Blade.Size * Vector3.new(1, 0, 1))
		if ToolEquipped then
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			local CurrentlyEquipped = true
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			Spawn(function()
				wait(0.5)
				if not ToolEquipped or not CurrentlyEquipped then
					return
				end
				Sounds.Equip.Sound:Play()
				Blade.Parent = Tool
				Inner.Parent = Tool
				local RiseRate = 25
				for i = 1, RiseRate do
					if not ToolEquipped or not CurrentlyEquipped then
						break
					end
			--		Blade.Size = Vector3.new(OriginalScale.X, ((OriginalScale.Y / RiseRate) * i), OriginalScale.Z)
			--		BladeWeld.C0 = CFrame.new(BladeWeld.C0.X, ((Handle.Size.Y / 2) + (Blade.Size.Y * 2) + BladeOffset.Y), BladeWeld.C0.Z)
					wait(Rate)
				end
				wait(0.25)
				if ToolUnequipped then
					ToolUnequipped:disconnect()
				end
				if not ToolEquipped or not CurrentlyEquipped or not CheckIfAlive() then
					return
				end
				ToolActive = true
				Blow(Blade)
			end)
		end
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not ToolActive then
		return
	end
	Tool.Enabled = false
	local SlashSounds = {Sounds.Slash1, Sounds.Slash2, Sounds.Slash3}
	local SlashSound = SlashSounds[math.random(1, #SlashSounds)]
	SlashSound.Sound.Pitch = (math.random((SlashSound.Pitch.Min * 1000), (SlashSound.Pitch.Max * 1000)) * 0.001)
	SlashSound.Sound:Play()
	local AttackAnims = {Animations.Bash, Animations.Slash, Animations.InwardSlash, Animations.OutwardSlash, Animations.UpwardSlash, Animations.Spin, Animations.DownwardIdlePose, Animations.SideStepUpperSlash, Animations.Swipe}
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		AttackAnims = {Animations.R15Bash, Animations.R15Slash, Animations.R15InwardSlash, Animations.R15OutwardSlash, Animations.R15UpwardSlash, Animations.R15Spin, Animations.R15DownwardIdlePose, Animations.R15SideStepUpperSlash, Animations.R15Swipe}
	end
	Attack(AttackAnims)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		local Animation = Animations.Equip
		if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Animation = Animations.R15Equip
		end
		InvokeClient("PlayAnimation", Animation)
	end)
	Spawn(function()
		for i, v in pairs(Animations) do
			Spawn(function()
				InvokeClient("Preload", v.Animation.AnimationId)
			end)
		end
		for i, v in pairs(Sounds) do
			Spawn(function()
				InvokeClient("Preload", v.Sound.SoundId)
			end)
		end
	end)
	Spawn(function()
		CreateBlade(true)
	end)
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		if v and v.Sound and v.Sound.Parent then
			v.Sound:Stop()
		end
	end
	HitSoundPlayable = true
	local Sound = Sounds.HitPlayer
	Sound.Sound.Pitch = Sound.Pitch.Min
	Sound.Sound:Play()
	--Sounds.Unequip.Sound:Play()
	CreateBlade(false)
	ToolActive = false
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