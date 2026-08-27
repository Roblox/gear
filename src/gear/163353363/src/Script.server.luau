--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
ContentProvider = game:GetService("ContentProvider")

Grips = {
	Normal = CFrame.new(0, -0.5, 0.649999976, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Firing = CFrame.new(0, -0.5, 0.649999976, 1, 0, 0, -0, 0.992277861, 0.124034733, 0, -0.124034733, 0.992277861)
}

BaseTextureId = 162829035

Meshes = {
	{Id = 163459324, Name = "Waffle", Size = Vector3.new(1.5, 1.5, 0.5), Height = -0.25, Angle = CFrame.Angles(math.pi, math.pi, 0), FaceCFrame = CFrame.new(0,0,-0.5) * CFrame.Angles(math.pi,0,0.15)},
	{Id = 163459238, Name = "Bacon", Size = Vector3.new(1, 0.25, 0.5), Height = -0.4, Angle = CFrame.Angles((math.pi / 2), 0, math.pi), FaceCFrame = CFrame.new(-0.1125, -0.675, -0.35) * CFrame.Angles(((math.pi / 2) - 0.1),  -0.2, (math.pi - 0.275))},
	{Id = 163459259, Name = "Egg1", Size = Vector3.new(0.75, 0.25, 0.6), Height = -0.3, Angle = CFrame.Angles((math.pi / 2), 0, math.pi), FaceCFrame = CFrame.new(0.2, -0.64, 0.25) * CFrame.Angles((math.pi / 2),  0, (math.pi - 0.2))},
	{Id = 163459304, Name = "Egg2", Size = Vector3.new(0.25, 0.2, 0.3), Height = -0.3, Angle = CFrame.Angles((math.pi / 2), 0, -math.pi / 1.25), FaceCFrame = CFrame.new(0.4, -0.55, 0.3) * CFrame.Angles((math.pi / 2) + 0.05,  1.1, math.pi)}
}

CurrentMesh = 0

ReloadTime = 0.25

Projectile = Instance.new("Part")
Projectile.Name = "Projectile"
Projectile.Material = Enum.Material.Plastic
Projectile.Shape = Enum.PartType.Block
Projectile.TopSurface = Enum.SurfaceType.Smooth
Projectile.BottomSurface = Enum.SurfaceType.Smooth
Projectile.Size = Vector3.new(0.25, 0.25, 0.25)
Projectile.CanCollide = true
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.FileMesh
Mesh.TextureId = "http://www.roblox.com/asset?id=" .. BaseTextureId
Mesh.Parent = Projectile


ContentProvider:Preload("http://www.roblox.com/asset?id=" .. BaseTextureId)

for i, v in pairs(Meshes) do
	ContentProvider:Preload("http://www.roblox.com/asset?id=" .. v.Id)
end

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function PositionProjectile(handle, x, y, z)
	local HandleClone = handle:Clone()
	local HandleCloneY = HandleClone:Clone()
	HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
	HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * y
	local HandleCloneZ = HandleCloneY:Clone()
	HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * z
	local HandleCloneX = HandleCloneZ:Clone()
	HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * x
	return HandleCloneX.CFrame
end

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		Tool.Grip = Grips.Firing
		CurrentMesh = (CurrentMesh + 1)
		if CurrentMesh > #Meshes then
			CurrentMesh = 1
		end
		local SelectedMesh = Meshes[CurrentMesh]
		local ProjectileClone = Projectile:Clone()
		ProjectileClone.Size = SelectedMesh.Size
		ProjectileClone.Mesh.MeshId = "http://www.roblox.com/asset?id=" .. SelectedMesh.Id
		local BreakfastPart = ProjectileClone:Clone()
		BreakfastPart.Name = SelectedMesh.Name
		BreakfastPart.CanCollide = false
		local BodyForce = Instance.new("BodyForce")
		BodyForce.force = Vector3.new(0, ProjectileClone:GetMass() * workspace.Gravity, 0)
		BodyForce.Parent = ProjectileClone
		local Position = Vector3.new(0, SelectedMesh.Height, ((Handle.Size.Z / 2) + (Projectile.Size.Z / 2) + 0.25))
		ProjectileClone.Touched:connect(function(Hit)
			if Hit and Hit.Parent and Hit.Name ~= Projectile.Name then
				local character, humanoid = FindCharacterAncestor(Hit.Parent)
				if character and character ~= Character and humanoid and humanoid.Health > 0 then
					local head = character:FindFirstChild("Head")
					if head then
						local BreakfastFace = character:FindFirstChild("BreakfastFace")
						if not BreakfastFace and CurrentMesh == 1 then
							BreakfastFace = Instance.new("Model")
							BreakfastFace.Name = "BreakfastFace"
							BreakfastFace.Parent = character
						end
						if BreakfastFace and not BreakfastFace:FindFirstChild(SelectedMesh.Name) then
							local Weld = Instance.new("Weld")
							Weld.Part0 = head
							Weld.Part1 = BreakfastPart
							Weld.C1 = SelectedMesh.FaceCFrame
							Weld.Parent = BreakfastPart
							BreakfastPart.Parent = BreakfastFace
						end
					end
				end
				if not character or character ~= Character then
					ProjectileClone:Destroy()
				end
			end
		end)
		Debris:AddItem(ProjectileClone, 5)
		ProjectileClone.Parent = game:GetService("Workspace")
		local TargetPoint = Humanoid.TargetPoint
		ProjectileClone.CFrame = PositionProjectile(Handle, Position.X, Position.Y, Position.Z)
		ProjectileClone.CFrame = CFrame.new(ProjectileClone.Position, TargetPoint)
		ProjectileClone.CFrame = ProjectileClone.CFrame * SelectedMesh.Angle
		ProjectileClone.Velocity = CFrame.new(ProjectileClone.Position, TargetPoint).lookVector * 75
		wait(ReloadTime)
		Tool.Grip = Grips.Normal
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Humanoid then
		return
	end
	Equipped = true
	Tool.Grip = Grips.Normal
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Equipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)