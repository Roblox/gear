--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = require(script:WaitForChild("Functions"))

ParticleScript = script:WaitForChild("ParticleScript")
FireSpread = script:WaitForChild("FireSpread")

Sounds = {}

Creator = Part:FindFirstChild("Creator")
Damage = Part:WaitForChild("Damage")

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

Rate = (1 / 60)

HitDelay = false

function GetCreator()
	return (((Creator and Creator.Parent and Creator.Value and Creator.Value:IsA("Player")) and Creator.Value) or nil)
end

function PartHit(Hit)
	local CreatorPlayer = GetCreator()
	if not Hit or not Hit.Parent or not CreatorPlayer or HitDelay or Part.Velocity.Magnitude < 8 then
		return
	end
	local character = Hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (CreatorPlayer == player or Functions.IsTeamMate(CreatorPlayer, player)) then
		return
	end
	HitDelay = true
	Functions.UntagHumanoid(humanoid)
	Functions.TagHumanoid(humanoid, CreatorPlayer)
	humanoid:TakeDamage(Damage.Value)
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Transparency < 1 then
			local Fire = FireSpread:Clone()
			Fire.Enabled = true
			local ParticleScriptCopy = ParticleScript:Clone()
			ParticleScriptCopy.Disabled = false
			ParticleScriptCopy.Parent = Fire
			Debris:AddItem(Fire, 3)
			Fire.Parent = v
		end
	end
	Part.Anchored = true
	Part.Transparency = 1
	for i, v in pairs(Part:GetChildren()) do
		if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Light") then
			v.Enabled = false
		end
	end
	Debris:AddItem(Part, 1.5)
end

Part.Touched:connect(PartHit)