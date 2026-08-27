--Rescripted by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Creator = script:FindFirstChild("Creator")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

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

FirePart = BasePart:Clone()
FirePart.Name = "Effect"
FirePart.Transparency = 1
FirePart.CanCollide = false
SoulFire = Create("Fire"){
	Name = "Fire",
	Color = Color3.new((178 / 255), (178 / 255), (178 / 255)),
	SecondaryColor = Color3.new((255 / 255), (0 / 255), (0 / 255)),
	Heat = 25,
	Size = 6,
	Enabled = true,
	Parent = FirePart
}

Gravity = 196.20

StoreHealth = 0
StoreCFrame = nil

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

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function KillEnemy()
	local Character = script.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	local Torso = Character:FindFirstChild("Torso")
	local Player = Players:GetPlayerFromCharacter(Character)
	local HealthAfter = 0
	if Humanoid and Humanoid.Health > 0 and Torso then
		for i, v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") then
				v:Destroy()
			end
		end
		if Humanoid then
			Humanoid.WalkSpeed = 0
		end
		if Torso then
			local BV = Create("BodyVelocity"){
				P = 300000,
				maxForce = Vector3.new(300000, 300000, 300000),
				velocity = Vector3.new(0, 3, 0),
			}
			FireWeld = Create("Weld"){
				Name = "FireWeld",
				Part0 = Torso,
				Part1 = FirePart,
				C0 = CFrame.new(0, 0, 0),
				C1 = CFrame.new(0, 0, 0),
				Parent = FirePart,
			}
			Debris:AddItem(BV, 2.75)
			Debris:AddItem(FirePart, 6)
			BV.Parent = Torso
			FirePart.Parent = game:GetService("Workspace")
		end
		wait(2.75)
		if Humanoid and Humanoid.Parent and Humanoid.Health > 0 then
			local CreatorPlayer = GetCreator()
			local TeamMate = false
			if CreatorPlayer and Player and IsTeamMate(CreatorPlayer, Player) then
				TeamMate = true
			end
			if not TeamMate then
				local Damage = math.huge
				HealthAfter = (Humanoid.Health - Damage)
				StoreHealth = Clamp(Humanoid.Health, 0, 100)
				UntagHumanoid(Humanoid)
				TagHumanoid(Humanoid, CreatorPlayer)
				Humanoid:TakeDamage(Damage)
				StoreCFrame = Torso.CFrame
			end
		end
	end
	return ((HealthAfter <= 0 and true) or false)
end

function Follow(torso)
	while torso and FirePart do 
		local Distance = (torso.Position - FirePart.Position).Magnitude
		if Distance > 2 then
			if FirePart then
				FirePart.Velocity = ((torso.Position - FirePart.Position).Unit * 55)
			end
		end
		wait()
	end
end

local Dead = KillEnemy()

if Dead then
	--wait(1)	
	local CreatorPlayer = GetCreator()
	if CreatorPlayer then
		local Character = CreatorPlayer.Character
		if Character then
			local Humanoid = Character:FindFirstChild("Humanoid")
			local Torso = Character:FindFirstChild("Torso")
			if Humanoid and Humanoid.Health > 0 and Torso then
				Spawn(function()
					--wait(3)
				end)
				if FireWeld and FireWeld.Parent then
					FireWeld:Destroy()
				end
				local Mass = (FirePart:GetMass() * Gravity)
				local Force = Create("BodyForce"){
					force = Vector3.new(0, Mass, 0),
					Parent = FirePart,
				}
				FirePart.Velocity = Vector3.new(0, 0, 0)
				if StoreCFrame then
					FirePart.CFrame = StoreCFrame
				end
				Spawn(function()
					Follow(Torso)
				end)
				FirePart.Touched:connect(function(Hit)
					if not Hit or not Hit.Parent then
						return
					end
					local character = Hit.Parent
					if character:IsA("Hat") then
						character = character.Parent
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					local player = Players:GetPlayerFromCharacter(character)
					if player and player == CreatorPlayer then
						if FirePart and FirePart.Parent then
							FirePart:Destroy()
						end
						humanoid.Health = (humanoid.Health + (StoreHealth * 2.25) + 3)
					end
				end)
			end
		end
	else 	
		for i, v in pairs({FirePart, FireWeld}) do
			if v and v.Parent then
				v:Destroy()
			end
		end
	end
end

wait(6)
script:Destroy()