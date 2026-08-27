--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Goldify = script:WaitForChild("Goldify")
SpeedBoost = script:WaitForChild("SpeedBoost")

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

Clover = BasePart:Clone()
Clover.Name = "Clover"
Clover.BrickColor = BrickColor.new("Camo")
Clover.Size = Vector3.new(1, 0.75, 0.2)
Clover.CanCollide = true
CloverMesh = Instance.new("SpecialMesh")
CloverMesh.Name = "Mesh"
CloverMesh.MeshType = Enum.MeshType.FileMesh
CloverMesh.MeshId = (BaseUrl .. "149229831")
CloverMesh.TextureId = (BaseUrl .. "1361097")
CloverMesh.Scale = Vector3.new(5, 5, 0.5)
CloverMesh.VertexColor = Vector3.new(0.25, 0.75, 0)
CloverMesh.Offset = Vector3.new(0, 0, 0)
CloverMesh.Parent = Clover

GoldClover = Clover:Clone()
GoldClover.Mesh.VertexColor = Vector3.new(0.9, 0.75, 0.25)

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75, Damage = {Min = 30, Max = 30}},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75, Damage = {Min = 30, Max = 30}},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Unsheath = Handle:WaitForChild("Unsheath"),
}

TouchDamage = {Min = 0, Max = 0}
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
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
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
	
	if HealthAfter <= 0 then
		local DeathEffect = math.random(1, 2)
		if DeathEffect == 1 then
			local GoldifyScript = Goldify:Clone()
			GoldifyScript.Disabled = false
			GoldifyScript.Parent = character
			local SpeedBoostScript = Character:FindFirstChild(SpeedBoost.Name)
			if not SpeedBoostScript then
				SpeedBoostScript = SpeedBoost:Clone()
			end
			SpeedBoostScript.Duration.Value = 15
			SpeedBoostScript.Disabled = false
			SpeedBoostScript.Parent = Character
		elseif DeathEffect == 2 then
			local head = character:FindFirstChild("Head")
			if head then
				local SpawnPosition = head.CFrame
				for i, v in pairs(character:GetChildren()) do
					if not v:IsA("Humanoid") then
						v:Destroy()
					end
				end
				for i = 1, math.random(8, 16) do
					local NewClover = Clover:Clone()
					local Mass = (NewClover:GetMass() * Gravity)
					local BodyVelocity = Instance.new("BodyVelocity")
					BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
					BodyVelocity.velocity = Vector3.new(0, -4, 0)
					BodyVelocity.Parent = NewClover
					NewClover.CFrame = SpawnPosition * CFrame.Angles((math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01), (math.random(-360, 360) * 0.01)) +Vector3.new((math.random(-300, 300) * 0.01), 2, (math.random(-300, 300) * 0.01))
					Debris:AddItem(NewClover, 5)
					NewClover.Parent = game:GetService("Workspace")
				end
			end
			local health = (Humanoid.MaxHealth * 0.15)
			Humanoid.Health = (Humanoid.Health + health)
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
			InvokeClient("PlayAnimation", CurrentAnimation)
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
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash}
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
	if Mode == "Button1Click" then
		local Down = Value.Down
	elseif Mode == "KeyPress" then
		local Down = Value.Down
		local Key = Value.Key
		local ByteKey = string.byte(Key)
	end
end)

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)