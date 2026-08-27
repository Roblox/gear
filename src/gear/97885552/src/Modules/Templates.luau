--Rescripted by Luckymaxer

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

Bullet = BasePart:Clone()
Bullet.Name = "Bullet"
Bullet.CanCollide = false
BulletMesh = Instance.new("SpecialMesh")
BulletMesh.MeshType = Enum.MeshType.FileMesh
BulletMesh.MeshId = "http://www.roblox.com/asset/?id=95387759"
BulletMesh.TextureId = "http://www.roblox.com/asset/?id=95387789"
BulletMesh.Scale = Vector3.new(3, 3, 3)
BulletMesh.VertexColor = Vector3.new(1, 1, 1)
BulletMesh.Parent = Bullet

Shell = Bullet:Clone()
Shell.Name = "Shell"
Shell.BrickColor = BrickColor.new("Bright yellow")
Shell.Size = Vector3.new(1, 0.4, 0.33)
Shell.CanCollide = true

SparkEffect = BasePart:Clone()
SparkEffect.Name = "Effect"
SparkEffect.CanCollide = false

Templates = {
	Bullet = Bullet,
	Shell = Shell,
	SparkEffect = SparkEffect,
}

return Templates