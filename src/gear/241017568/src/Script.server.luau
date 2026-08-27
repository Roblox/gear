--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Fire = Handle:WaitForChild("Fire")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
InsertService = game:GetService("InsertService")

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

WaveModel = InsertService:LoadAsset(212226090)
Wave = WaveModel:GetChildren()[1]:Clone()
Wave.Size = Vector3.new(10, 3.5, 20)
Debris:AddItem(WaveModel, 0)

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75, Damage = {Min = 15, Max = 22}},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75, Damage = {Min = 15, Max = 22}},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Unsheath = Handle:WaitForChild("Unsheath"),
}

Special = {
	Enabled = true,
	Active = false,
	Reloading = false,
	ReloadTime = 25,
	Damage = 45,
}

TouchDamage = {Min = 6, Max = 8}

DashEnabled = true
AttackEnabled = true
ToolEquipped = false

Gravity = 196.20

LastClick = 0

Rate = (1 / 60)

IncreasedWalkSpeed = 20

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Fire.Enabled = false
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

function Blow(Hit)
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
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
	local DamageAmount = math.random(DamageValue.Min, DamageValue.Max)
	
	local FinalizedDamage = (DamageAmount * (((BodyGyro and BodyGyro.Parent) and 1.5) or 1))	
	
	humanoid:TakeDamage(FinalizedDamage)
	
end

function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			PossibleSounds[math.random(1, #PossibleSounds)]:Play()
		end 
		CurrentAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		InvokeClient("PlayAnimation", CurrentAnimation)
		if CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
			wait(CurrentAnimation.Duration)
			InvokeClient("StopAnimation", CurrentAnimation)
			CurrentAnimation = nil
		end
	end
end

function GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function Dash()
	DashEnabled = false
	local MousePosition = InvokeClient("MousePosition").Position
	local Direction = CFrame.new(Torso.Position, Vector3.new(MousePosition.X, Torso.Position.Y, MousePosition.Z))
	Torso.CFrame = Direction
	local Parts = GetAllConnectedParts(Torso)
	local Mass = 0
	for i, v in pairs(Parts) do
		Mass = (Mass + v:GetMass())
	end
	Mass = (Mass * Gravity * 100)
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(Mass, 0, Mass)
	BodyVelocity.velocity = Direction.lookVector * 100
	Debris:AddItem(BodyVelocity, 0.5)
	BodyVelocity.Parent = Torso
	if BodyGyro and BodyGyro.Parent then
		BodyGyro:Destroy()
	end
	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = Direction
	Debris:AddItem(BodyGyro, 0.5)
	BodyGyro.Parent = Torso
	wait(2)
	DashEnabled = true
end

function Activated()
	if not ToolEquipped or not AttackEnabled or not CheckIfAlive() then
		return
	end
	AttackEnabled = false
	RunService.Stepped:wait()
	local Time = tick()
	if (Time - LastClick) < 0.25 and DashEnabled and not Tool.Enabled and not Special.Active then
		Spawn(Dash)
	elseif Tool.Enabled then
		Spawn(function()
			Tool.Enabled = false
			Humanoid.WalkSpeed = 10
			Fire.Enabled = true
			Delay(0.5, function()
				Fire.Enabled = false
			end)
			local AttackAnims = {Animations.LeftSlash, Animations.RightSlash}
			local AttackSounds = {Sounds.Slash}
			Attack(AttackAnims, AttackSounds)
			if ToolEquipped then
				Humanoid.WalkSpeed = IncreasedWalkSpeed
			end
			Tool.Enabled = true
		end)
	end
	LastClick = Time
	AttackEnabled = true
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
	Humanoid.WalkSpeed = IncreasedWalkSpeed
	ToolEquipped = true
end

function Unequipped()
	Humanoid.WalkSpeed = 16
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
	if Mode == "KeyPress" then
		local Key = Value.Key
		local Down = Value.Down
		if Key == "q" and Down and Special.Enabled and not Special.Active then
			Special.Enabled = false
			Special.Active = true
			local CreatorPlayer = Player
			local Waves = {}
			local NumberOfWaves = 12
			local WaveDuration = 2
			for i = 1, NumberOfWaves do
				local WaveClone = Wave:Clone()
				Debris:AddItem(WaveClone, (WaveDuration + 1))
				WaveClone.Parent = game:GetService("Workspace")
				WaveClone.CFrame = ((Torso.CFrame * CFrame.new(0, -Torso.Size.Y, 0)) * CFrame.Angles(0, (((math.pi * 2) / NumberOfWaves) * i), 0))
				WaveClone.CFrame = (WaveClone.CFrame + WaveClone.CFrame.lookVector * Wave.Size.Z)
				WaveClone.CFrame = (WaveClone.CFrame * CFrame.Angles(0, -(math.pi / 2), 0))
				WaveClone.CFrame = (WaveClone.CFrame * CFrame.new(0, -WaveClone.Size.Y, 0))
				WaveClone.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent then
						return
					end
					local character = Hit.Parent
					local player = Players:GetPlayerFromCharacter(character)
					if player and (IsTeamMate(Player, player) or player == CreatorPlayer) then
						return
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, CreatorPlayer)
					humanoid:TakeDamage(Special.Damage)
				end)
				table.insert(Waves, WaveClone)
			end
			local RiseRate = 10
			local RiseAmount = ((Wave.Size.Y + (Torso.Size.Y * 0.5)) / RiseRate)
			Spawn(function()
				for i = 1, 10 do
					for i, v in pairs(Waves) do
						if v and v.Parent then
							v.CFrame = (v.CFrame * CFrame.new(0, RiseAmount, 0))
						end
					end
					wait(Rate)
				end
			end)
			local MoveStart = tick()
			while (tick() - MoveStart) < WaveDuration do
				for i, v in pairs(Waves) do
					if v and v.Parent then
						v.CFrame = (v.CFrame + (v.CFrame * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * 1.05)
					end
				end
				wait(Rate)
			end
			for i, v in pairs(Waves) do
				if v and v.Parent then
					v:Destroy()
				end
			end
			Special.Reloading = true
			Special.Active = false
			wait(Special.ReloadTime)
			Special.Reloading = false
			Special.Enabled = true
		end
	end
end)

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)