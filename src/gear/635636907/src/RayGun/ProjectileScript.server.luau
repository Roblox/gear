--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Creator = Part:FindFirstChild("Creator")
Damage = Part:WaitForChild("Damage")

Sounds = {
	Hit = Part:WaitForChild("Hit"),
}

HitDelay = false

BasePart = Create("Part"){
	Shape = Enum.PartType.Block,
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	Locked = true,
	CanCollide = true,
	Anchored = false,
}

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
	
function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function GetCreator()
	return (((Creator and Creator.Parent and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end
function PartHit(Hit)
	local CreatorPlayer = GetCreator()
	if not Hit or not Hit.Parent or not CreatorPlayer or HitDelay then
		return
	end
	local character = Hit.Parent
	local HitParent = character
	if character:IsA("Hat") then
		character = character.Parent
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.Health > 0 then
		for i, v in pairs(character:GetChildren()) do
			if v:IsA("ForceField") then
				return
			end
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			if (CreatorPlayer == player or IsTeamMate(CreatorPlayer, player)) then
				return
			end
		end
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, CreatorPlayer)
		humanoid:TakeDamage(Damage.Value)
		if humanoid.Health <= 0 then
		end
	end
	if (Hit.Transparency >= 1 and not Hit.CanCollide and not humanoid) or Hit.Name == "HumanoidRootPart" then
		return
	end
	HitDelay = true
	if (humanoid or Hit:GetMass() < (1.2 * 200)) and not HitParent:IsA("Hat") and not HitParent:IsA("Tool") then
		--Hit.BrickColor = Part.BrickColor
	end
	Sounds.Hit:Play()
	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") then
			v.Enabled = false
		end
	end
	Debris:AddItem(Part, 2)
end

Part.Touched:connect(PartHit)