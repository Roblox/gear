--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

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

Seahorse = require(script:WaitForChild("Seahorse"))
Particles = script:WaitForChild("Particles")

ToolEquipped = false

Handle.Transparency = 0
Tool.Enabled = true

function SpawnSeahorse(CreateNew)
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("Model") or v:IsA("BasePart")) and v ~= Handle then
			v:Destroy()
		end
	end
	if not CreateNew then
		return
	end
	local SeahorseCopy = Seahorse:Clone()
	local Body = SeahorseCopy.Body
	local ParticlePart = SeahorseCopy.ParticlePart
	for i, v in pairs(Particles:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			local Particle = v:Clone()
			Particle.Enabled = false
			Particle.Parent = ParticlePart
		end
	end
	local TorsoWeld = Create("Weld"){
		Part0 = Torso,
		Part1 = Body,
		C0 = CFrame.new(0, 0, -2.1),
		C1 = CFrame.new(0, 0, 0),
		Parent = Body
	}
	SeahorseCopy.Parent = Tool
end

function FreezePlayer()
	if CheckIfAlive() then
		local FreezePart = BasePart:Clone()
		FreezePart.Name = "FreezePart"
		FreezePart.Transparency = 1
		FreezePart.Anchored = true
		FreezePart.CanCollide = false
		local FreezeWeld = Instance.new("Weld")
		FreezeWeld.Part0 = Torso
		FreezeWeld.Part1 = FreezePart
		FreezeWeld.Parent = FreezePart
		Debris:AddItem(FreezePart, 0.125)
		FreezePart.Parent = Character
		Torso.Velocity = Vector3.new(0, -25, 0)
		Torso.RotVelocity = Vector3.new(0, 0, 0)
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
	Spawn(function()
		SpawnSeahorse(true)
	end)
	Handle.Transparency = 1
end

function Unequipped()
	SpawnSeahorse(false)
	FreezePlayer()
	ToolEquipped = false
	Handle.Transparency = 0
end

SpawnSeahorse(false)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)