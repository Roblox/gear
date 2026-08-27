--Made by Luckymaxer

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
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Animations = {
	Swing1 = {Animation = Tool:WaitForChild("Swing1"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.75},
	Swing2 = {Animation = Tool:WaitForChild("Swing2"), FadeTime = nil, Weight = nil, Speed = 3, Duration = 0.75},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Unsheath = Handle:WaitForChild("Unsheath"),
}

Damage = {
	Touch = {Min = 0, Max = 0},
	Hit = {Min = 28, Max = 45},
}

CriticalHitMultiplier = 1.5

ToolEquipped = false
Attacking = false

ReloadTime = 0.75

Gravity = 196.20
Rate = (1 / 60)

HumanoidsHit = {}

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
	
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	
	local character = Hit.Parent
	if character == Character then
		return
	end
	
	local player = Players:GetPlayerFromCharacter(character)
	if player and IsTeamMate(Player, player) then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 or CheckTableForInstance(HumanoidsHit, humanoid) then
		return
	end
	
	table.insert(HumanoidsHit, humanoid)
	
	local DamageValue = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	
	if CurrentAnimation then
		local CriticalHit = math.random(1, 10)
		if CriticalHit == 1 then
			DamageAmount = (DamageAmount * CriticalHitMultiplier)
		end
	end
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local HealthAfter = (humanoid.Health - DamageAmount)
	
	humanoid:TakeDamage(DamageAmount)
	
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
					v.BrickColor = BrickColor.new("Really red")
					v.Transparency = 0.5
					v.Velocity = Velocity
					Debris:AddItem(v, 3)
				end
			end
		end
	end
	
end

function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			local RandomSound = PossibleSounds[math.random(1, #PossibleSounds)]
			RandomSound:Play()
		end
		local SelectedAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		Delay(((SelectedAnimation.Delay and SelectedAnimation.Delay) or 0), (function()
			HumanoidsHit = {}
			CurrentAnimation = SelectedAnimation
			Spawn(function()
				InvokeClient("PlayAnimation", CurrentAnimation)
			end)
			if CurrentAnimation and CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
				wait(CurrentAnimation.Duration)
			end
			CurrentAnimation = nil
			HumanoidsHit = {}
		end))
	end
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	Attacking = true
	local AttackSounds = {Sounds.Slash}
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.Swing1, Animations.Swing2}
	Attack(AttackAnims, AttackSounds)
	Attacking = false
	wait(ReloadTime)
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
	Sounds.Unsheath:Play()
	ToolEquipped = true
end

function Unequipped()
	Attacking = false
	for i, v in pairs(Sounds) do
		v:Stop()
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
	if player ~= Player or not ToolEquipped or not CheckIfAlive() then
		return
	end
end)

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)