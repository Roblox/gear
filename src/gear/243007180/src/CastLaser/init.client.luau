--Made by Luckymaxer

Debris = game:GetService("Debris")

Camera = game:GetService("Workspace").CurrentCamera

Sounds = {
	RayHit = script:WaitForChild("Hit")
}

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

BaseRay = BasePart:Clone()
BaseRay.Name = "Laser"
BaseRay.BrickColor = BrickColor.new("New Yeller")
BaseRay.Material = Enum.Material.SmoothPlastic
BaseRay.Size = Vector3.new(0.2, 0.2, 0.2)
BaseRay.Anchored = true
BaseRay.CanCollide = false
BaseRayMesh = Instance.new("SpecialMesh")
BaseRayMesh.Name = "Mesh"
BaseRayMesh.MeshType = Enum.MeshType.Brick
BaseRayMesh.Scale = Vector3.new(0.2, 0.2, 1)
BaseRayMesh.Offset = Vector3.new(0, 0, 0)
BaseRayMesh.VertexColor = Vector3.new(1, 1, 1)
BaseRayMesh.Parent = BaseRay

function PlaySound(Position, Sound)
	local SoundPart = BasePart:Clone()
	SoundPart.Name = "ParticlePart"
	SoundPart.Transparency = 1
	SoundPart.Anchored = true
	SoundPart.CanCollide = false
	local SoundObject = Sound:Clone()
	SoundObject.Parent = SoundPart
	Debris:AddItem(SoundPart, 1.5)
	SoundPart.Parent = game:GetService("Workspace")
	SoundPart.CFrame = CFrame.new(Position)
	SoundObject:Play()
end

function FireRay(StartPosition, TargetPosition, Hit)
	
	local Vec = (TargetPosition - StartPosition)
	local Distance = Vec.magnitude
	local Direction = Vec.unit
	
	local PX = (StartPosition + (0.25 * Distance) * Direction)
	local PY = (StartPosition + (0.5 * Distance) * Direction)
	local PZ = (StartPosition + (0.75 * Distance) * Direction)
	
	local DX = (StartPosition - PX).magnitude
	local DY = (PX - PY).magnitude
	local DZ = (PY - PZ).magnitude
	
	local Limit = 2
	local AX = (PX + Vector3.new(math.random(math.max(-Limit, (-0.21 * DX)), math.min(Limit, (0.21 * DX))),math.random(math.max(-Limit, (-0.21 * DX)),math.min(Limit, (0.21 * DX))), math.random(math.max(-Limit, (-0.21 * DX)), math.min(Limit, (0.21 * DX)))))
	local AY = (PY + Vector3.new(math.random(math.max(-Limit, (-0.21 * DY)), math.min(Limit, (0.21 * DY))),math.random(math.max(-Limit, (-0.21 * DY)),math.min(Limit, (0.21 * DY))), math.random(math.max(-Limit, (-0.21 * DY)), math.min(Limit, (0.21 * DY)))))
	local AZ = (PZ + Vector3.new(math.random(math.max(-Limit, (-0.21 * DZ)), math.min(Limit, (0.21 * DZ))),math.random(math.max(-Limit, (-0.21 * DZ)),math.min(Limit, (0.21 * DZ))), math.random(math.max(-Limit, (-0.21 * DZ)), math.min(Limit, (0.21 * DZ)))))
	
	local Rays = {
		{Distance = (AX - StartPosition).magnitude, Direction = CFrame.new(StartPosition, AX)},
		{Distance = (AY - AX).magnitude, Direction = CFrame.new(AX, AY)},
		{Distance = (AZ - AY).magnitude, Direction = CFrame.new(AY, AZ)},
		{Distance = (TargetPosition - AZ).magnitude, Direction = CFrame.new(AZ, TargetPosition)},
	}
	
	for i, v in pairs(Rays) do
		local Ray = BaseRay:Clone()
		Ray.BrickColor = BrickColor.new("New Yeller")
		Ray.Reflectance = 0.4
		Ray.Transparency = 0.7
		local Mesh = Ray.Mesh
		Mesh.Scale = (Vector3.new(0.15, 0.15, (v.Distance / 1)) * 5)
		Ray.CFrame = (v.Direction * CFrame.new(0, 0, (-0.5 * v.Distance)))
		Debris:AddItem(Ray, (0.1 / (#Rays - (i - 1))))
		Ray.Parent = Camera
	end
	
end

pcall(function()
	local StartPosition = script:WaitForChild("StartPosition").Value
	local TargetPosition = script:WaitForChild("TargetPosition").Value
	local RayHit = script:WaitForChild("RayHit").Value
	FireRay(StartPosition, TargetPosition)
	if RayHit then
		PlaySound(TargetPosition, Sounds.RayHit)
	end
end)

Debris:AddItem(script, 1)