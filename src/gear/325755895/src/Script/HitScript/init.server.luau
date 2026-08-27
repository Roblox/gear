--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

SnowMeltScript = script:WaitForChild("SnowMeltScript")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.SmoothNoOutlines,
	BottomSurface = Enum.SurfaceType.SmoothNoOutlines,
	FrontSurface = Enum.SurfaceType.SmoothNoOutlines,
	BackSurface = Enum.SurfaceType.SmoothNoOutlines,
	LeftSurface = Enum.SurfaceType.SmoothNoOutlines,
	RightSurface = Enum.SurfaceType.SmoothNoOutlines,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Creator = script:WaitForChild("Creator")
Damage = script:WaitForChild("Damage")

AlreadyHit = false

function GetCreatorPlayer()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function PlaySound(Position, Sound)
	local Sound = Sound:Clone()
	local SoundPart = BasePart:Clone()
	SoundPart.Name = "Effect"
	SoundPart.Transparency = 1
	SoundPart.Size = Vector3.new(0.2, 0.2, 0.2)
	SoundPart.CanCollide = false
	SoundPart.Anchored = true
	SoundPart.CFrame = CFrame.new(Position)
	Sound.Parent = SoundPart
	Debris:AddItem(SoundPart, 1.5)
	SoundPart.Parent = game:GetService("Workspace")
	Sound:Play()
end

function SplashScreen(Player)
	if not Player or not Player:IsA("Player") then
		return
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if not PlayerGui then
		return
	end
	local Flakes = {"19003948", "19003957", "19003971", "19003978", "19003982", "19003990", "19003998"}
	local Globs = {"19323823", "19323854"}
	local SplatGui = Create("ScreenGui"){
		Name = "SplatGui",
	}
	local Frame = Create("Frame") {
		Name = "SnowEffect",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = SplatGui,
	}
	--Big Glob
	local Size = ((math.random() * 0.2) + 0.5)
	local s = Create("ImageLabel"){
		Size = UDim2.new(Size, 0, Size, 0),
		Position = UDim2.new((math.random() - (Size / 2)), 0, (math.random() - (Size / 2)), 0),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Rotation = math.random(0, 360),
		BackgroundTransparency = 1,
		Image = (BaseUrl .. Globs[math.random(1, #Globs)]),
		Parent = Frame,
	}
	Debris:AddItem(s, (5 + (math.random() * 2)))
	--Flakes
	for i = 1, 20 do
		local Size = ((math.random() * 0.05) + 0.05)
		local s = Create("ImageLabel"){
			Size = UDim2.new(Size, 0, Size, 0),
			Position = UDim2.new((math.random() - (Size / 2)), 0, (math.random() - (Size / 2)), 0),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			Rotation = math.random(0, 360),
			BackgroundTransparency = 1,
			Image = (BaseUrl .. Flakes[math.random(1, #Flakes)]),
			Parent = Frame,
		}
		Debris:AddItem(s, (3 + (math.random() * 6)))
	end
	local SnowMeltScriptCopy = SnowMeltScript:Clone()
	local Delay = Create("NumberValue"){
		Name = "Delay",
		Value = 3,
		Parent = SnowMeltScriptCopy,
	}
	SnowMeltScriptCopy.Disabled = false
	SnowMeltScriptCopy.Parent = Frame
	Debris:AddItem(SplatGui, 10)
	SplatGui.Parent = PlayerGui
end


function Explode(Amount)
	for i = 1, Amount do
		local Flake = BasePart:Clone()
		Flake.Name = "Effect"
		Flake.BrickColor = Part.BrickColor
		Flake.Material = Enum.Material.Concrete
		Flake.Size = Vector3.new(0.75, 0.2, 0.75)
		Flake.CanCollide = true
		Flake.Velocity = (Part.Velocity * Vector3.new((math.random() * 0.65), (2 + (math.random() * 1)), (math.random() * 0.65)))
		Flake.RotVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
		Flake.CFrame = (Part.CFrame + (Part.Velocity * math.random() * 0.05) + Vector3.new(0, (math.random() * 3), 0))
		Debris:AddItem(Flake, (30 + (math.random() * 5)))
		Flake.Parent = game:GetService("Workspace")
	end
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function Blow(Hit)
	local IgnoredNames = {"Effect", "Projectile"}
	if not Hit or not Hit.Parent or CheckTableForString(IgnoredNames, Hit.Name) or AlreadyHit then
		return
	end
	local CreatorPlayer = GetCreatorPlayer()
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		local CanDamage = true
		local player = Players:GetPlayerFromCharacter(character)
		if player and CreatorPlayer then
			if player == CreatorPlayer then
				return
			end
			if IsTeamMate(CreatorPlayer, player) then
				CanDamage = false
			end
		end
		if CanDamage then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, CreatorPlayer)
			humanoid:TakeDamage(Damage.Value)
			if player then
				SplashScreen(player)
			end
		end
	end
	AlreadyHit = true
	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
		end
	end
	local HitSounds = {"19326853", "19326880", "19326891"}
	local Sound = Create("Sound"){
		SoundId = (BaseUrl .. HitSounds[math.random(1, #HitSounds)]),
		Pitch = 1,
		Volume = 1,
		Looped = false,
		PlayOnRemove = false,
	}
	PlaySound(Part.Position, Sound)
	Explode(math.random(4, 8))
end

Part.Touched:connect(Blow)