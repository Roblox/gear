--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

FunctionsLibrary = script:FindFirstChild("Functions")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	FormFactor = Enum.FormFactor.Custom,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Rate = (1 / 15)

Projectiles = {}
Removing = false

Functions = require(FunctionsLibrary)


Model.ChildAdded:connect(function(Child)
	if Child:IsA("BasePart") and Child.Name == "Projectile" then

	end
end)

Model.ChildRemoved:connect(function(Child)
	for i, v in pairs(Projectiles) do
		if v == Child then
			table.remove(Projectiles, i)
		end
	end
	RemoveModel()
end)



wait(1)

RemoveModel()