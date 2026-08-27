--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

LightningFunctions = require(script:WaitForChild("LightningFunctions"))

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Gravity = 196.20
Rate = (1 / 60)

Shots = {Total = 6, Used = 0}
ShotReload = 10
FireRate = 0.125

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Remotes = (Tool:FindFirstChild("Remotes") or Create("Folder"){
	Name = "Remotes",
	Parent = Tool,
})
ServerControl = (Remotes:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Remotes,
})
ClientControl = (Remotes:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Remotes,
})

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

ReadyParticle = script:WaitForChild("ReadyParticle")
HitScript = script:WaitForChild("HitScript")

Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Strike = Handle:WaitForChild("Strike"),
	Lightning = Handle:WaitForChild("Lightning"),
}

BaseOrb = BasePart:Clone()
BaseOrb.Name = "Projectile"
BaseOrb.Transparency = 0.2
BaseOrb.BrickColor = BrickColor.new("Bright red")
BaseOrb.Material = Enum.Material.Neon
BaseOrb.Size = Vector3.new(1, 1, 1)
BaseOrb.CanCollide = false
Create("SpecialMesh"){
	Name = "Mesh",
	MeshType = Enum.MeshType.Sphere,
	Scale = Vector3.new(1, 1, 1),
	VertexColor = Vector3.new(1, 1, 1),
	Offset = Vector3.new(0, 0, 0),
	Parent = BaseOrb,
}
ParticleEffect = ReadyParticle:Clone()
ParticleEffect.LockedToPart = false
ParticleEffect.Enabled = true
ParticleEffect.Parent = BaseOrb
StrikeSound = Sounds.Strike:Clone()
StrikeSound.Parent = BaseOrb

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

function TakeDamage(humanoid, Damage)
	if not humanoid or not humanoid:IsA("Humanoid") or not Damage or not Player then
		return
	end
	local character = humanoid.Parent
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("ForceField") then
			return
		end
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		if IsTeamMate(Player, player) then
			return
		end
	end
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(Damage)
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function GetParts(Region, MaxParts, Ignore)
	local Parts = {}
	local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, 500)
	for i, v in pairs(PartsNearby) do
		table.insert(Parts, v)
	end
	return Parts
end

function GetNearbyObjects(Region)
	local IgnoreList = {Character}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v ~= Player and v.Character and v.Character.Parent and IsTeamMate(Player, v) then
			table.insert(IgnoreList, v.Character)
		end
	end
	return GetParts(Region, 500, IgnoreList)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Fire(TargetPosition)
	Shots.Used = (Shots.Used + 1)
	Delay(ShotReload, (function()
		Shots.Used = (Shots.Used - 1)
		if Shots.Used < Shots.Total then
			Tool.Enabled = true
		end
	end))
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if not CheckIfAlive() or not ToolEquipped or not CurrentlyEquipped then
		return
	end
	local Projectile = BaseOrb:Clone()
	local SpawnPosition = (Handle.CFrame * CFrame.new(0, ((Handle.Size.Y / 2) - (Projectile.Size.Y / 2)), 0))
	local TargetDirection = CFrame.new(SpawnPosition.p, TargetPosition)
	local Speed = 75
	local Velocity = (TargetDirection.lookVector * Speed)
	local Mass = (Projectile:GetMass() * Gravity)
	local BodyVelocity = Create("BodyVelocity"){
		Name = "BodyVelocity",
		maxForce = Vector3.new(Mass, Mass, Mass),
		velocity = Velocity,
		Parent = Projectile,
	}
	Projectile.Velocity = Velocity
	local Values = {
		{Name = "Creator", Class = "ObjectValue", Value = Player},
		{Name = "Damage", Class = "NumberValue", Value = 20},
	}
	for i, v in pairs(Values) do
		local Value = Create(v.Class){
			Name = v.Name,
			Value = v.Value,
			Parent = Projectile,
		}
	end
	local HitScriptCopy = HitScript:Clone()
	HitScriptCopy.Disabled = false
	HitScriptCopy.Parent = Projectile
	Projectile.CFrame = SpawnPosition
	Debris:AddItem(Projectile, 15)
	Projectile.Parent = game:GetService("Workspace")
end

function Activated()
	local MouseData = InvokeClient("MouseData")
	if not Tool.Enabled or not CheckIfAlive() or not MouseData or not MouseData.Position or Shots.Used >= Shots.Total then
		return
	end
	Tool.Enabled = false
	local Sound = Sounds.Fire:Clone()
	Debris:AddItem(Sound, 1.25)
	Sound.Parent = Handle
	Sound:Play()
	Fire(MouseData.Position)
	wait(FireRate)
	if Shots.Used < Shots.Total then
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	while CurrentlyEquipped and CheckIfAlive() do
		wait(math.random(2, 6))
		if not CurrentlyEquipped or not CheckIfAlive() then
			break
		end
		Spawn(function()
			local HumanoidsHit = {}
			local LightningRadius = 6
			local StartPosition = ((Torso.CFrame * CFrame.new(0, 100, 0)) + (Torso.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)).lookVector * math.random(3, 40))
			local TargetPosition = (StartPosition + Vector3.new(0, -1, 0) * 2)
			local RayData = LightningFunctions.Zap({StartPosition = StartPosition.p, TargetPosition = TargetPosition.p, Character = Character, Color = "Bright violet", Individual = true, Duration = 2.5, TimeToFade = 1.5, MaxRange = 150, Thickness = 0.6, SegmentLength = 5})
			if RayData then
				local RayPos = RayData.RayPos
				local SoundPart = BasePart:Clone()
				SoundPart.Name = "Effect"
				SoundPart.Transparency = 1
				SoundPart.CanCollide = false
				local Sound = Sounds.Lightning:Clone()
				Sound.Parent = SoundPart
				Debris:AddItem(SoundPart, 2)
				SoundPart.Parent = game:GetService("Workspace")
				SoundPart.CFrame = CFrame.new(RayPos)
				Sound:Play()
				local LightningRegion = Region3.new((RayPos - Vector3.new(LightningRadius, LightningRadius, LightningRadius)), (RayPos + Vector3.new(LightningRadius, LightningRadius, LightningRadius)))
				for i, v in pairs(GetNearbyObjects(LightningRegion)) do
					if v and v.Parent then
						local character = v.Parent
						if character ~= Character then
							local humanoid = character:FindFirstChild("Humanoid")
							if humanoid and humanoid.Health > 0 then
								local player = Players:GetPlayerFromCharacter(character)
								if not player or (player and not IsTeamMate(Player, player)) then
									if not CheckTableForInstance(HumanoidsHit, humanoid) then
										local ForceField = nil
										for ii, vv in pairs(character:GetChildren()) do
											if vv:IsA("ForceField") then
												ForceField = vv
												break
											end
										end
										if not ForceField then
											table.insert(HumanoidsHit, humanoid)
											TakeDamage(humanoid, 80)
											local torso = (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
											if torso then
												humanoid.Sit = true
												torso.Velocity = (CFrame.new(Torso.Position, torso.Position).lookVector * 10)
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end)
	end
end

function Unequipped()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
	end
	if mode == "KeyPress" then
		local Key = value.Key
		local Down = value.Down
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)