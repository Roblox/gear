--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Splat = Handle:WaitForChild("Splat")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ReloadTime = 2

Damage = 15

Meshes = {
	Loaded = "http://www.roblox.com/asset?id=160207972",
	Unloaded = "http://www.roblox.com/asset?id=160207986"
}

Grips = {
	NormalGrip = CFrame.new(0.125, 1.25, 0, 1, 0, -3.69598024e-006, 0, 1, 0, 3.69598024e-006, 0, 1),
	ReleaseGrip = CFrame.new(0.125, 1.25, 0, 1, 0, 0, -0, 0.963053524, 0.269310266, 0, -0.269310266, 0.963053524)
}

Images = {161216978, 161217003, 161217021, 161217039, 161217056, 161217111, 161217134, 161217163, 161217177, 161217190}

Ammo = Instance.new("Part")
Ammo.Name = "Watermelon"
Ammo.Material = Enum.Material.Plastic
Ammo.Shape = Enum.PartType.Block
Ammo.FormFactor = Enum.FormFactor.Custom
Ammo.TopSurface = Enum.SurfaceType.Smooth
Ammo.BottomSurface = Enum.SurfaceType.Smooth
Ammo.Size = Vector3.new(2, 1, 1)
AmmoMesh = Instance.new("SpecialMesh")
AmmoMesh.MeshType = Enum.MeshType.FileMesh
AmmoMesh.MeshId = "http://www.roblox.com/asset?id=160207800"
AmmoMesh.TextureId = "http://www.roblox.com/asset?id=160208024"
AmmoMesh.Scale = Vector3.new(1, 1, 1)
AmmoMesh.Parent = Ammo

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

function CoverScreen(player)
	local PlayerGui = player:FindFirstChild("PlayerGui")
	if PlayerGui then

		local ScreenGui = Instance.new("ScreenGui") 
		ScreenGui.Name = "WatermelonSplatter"
		local MainFrame = Instance.new("Frame") 
		MainFrame.Name = "Splater"
		MainFrame.Position = UDim2.new(0, 0, 0, 0) 
		MainFrame.Size = UDim2.new(1, 0, 1, 0) 
		MainFrame.BackgroundColor = BrickColor.new(1, 1, 1)
		MainFrame.Transparency = 1
		MainFrame.BorderColor = BrickColor.new(1, 1, 1)
		MainFrame.Parent = ScreenGui
	
		local s = Instance.new("ImageLabel")
		local size = ((math.random() * 0.2) + 0.5)
		s.Size = UDim2.new(size, 0, size, 0)
		s.Position = UDim2.new((math.random() - (size / 2)), 0, (math.random() - (size / 2)),0)
		s.SizeConstraint = Enum.SizeConstraint.RelativeXX
		s.Transparency = 1
		s.Image = "http://www.roblox.com/asset/?id=" .. Images[math.random(1, #Images)]
		s.Parent = MainFrame
	
		Debris:AddItem(s, (5 + (math.random() * 2)))
	
		for i = 1, 20 do
			local s = Instance.new("ImageLabel")
			local size = ((math.random() * 0.05) + 0.05)
			s.Size = UDim2.new(size,0, size, 0)
			s.Position = UDim2.new((math.random() - (size / 2)), 0, (math.random() - (size / 2)), 0)
			s.SizeConstraint = Enum.SizeConstraint.RelativeXX
			s.Transparency = 1
			s.Image = "http://www.roblox.com/asset/?id=" .. Images[math.random(1, #Images)]
			s.Parent = mainFrame
			Debris:AddItem(s, (3 + (math.random() * 6)))
		end
	
		Debris:AddItem(ScreenGui, 10)
		
		ScreenGui.Parent = PlayerGui		
	
	end
end

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		Tool.Grip = Grips.ReleaseGrip
		Mesh.MeshId = Meshes.Unloaded
		local HandleClone = Handle:Clone()
		local HandleCloneY = HandleClone:Clone()
		HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
		HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * 1
		local HandleCloneZ = HandleCloneY:Clone()
		HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * ((HandleClone.Size.Z / 2) + (Ammo.Size.Z / 2))
		local HandleCloneX = HandleCloneZ:Clone()
		HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
		local AmmoClone = Ammo:Clone()
		local BodyForce = Instance.new("BodyForce")
		BodyForce.force = Vector3.new(0, AmmoClone:GetMass() * workspace.Gravity, 0)
		BodyForce.Parent = AmmoClone
		local SplatSound = Splat:Clone()
		SplatSound.Parent = AmmoClone
		AmmoClone.Touched:connect(function(Hit)
			if Hit and Hit.Parent and Hit ~= Handle then
				local character, humanoid = FindCharacterAncestor(Hit.Parent)
				if character ~= Character then
					SplatSound:Play()
					if character and humanoid and humanoid.Health > 0 then
						UntagHumanoid(humanoid)
						TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(Damage)
						local player = Players:GetPlayerFromCharacter(character)
						if player then
							CoverScreen(player)
						end
					end
					local Radius = 2
					for i = 1, 50 do
						local Splatter = Instance.new("Part")
						Splatter.Name = "WatermelonSplatter"
						Splatter.BrickColor = BrickColor.new("Really red")
						Splatter.Material = Enum.Material.Plastic
						Splatter.Shape = Enum.PartType.Block
						Splatter.TopSurface = Enum.SurfaceType.Smooth
						Splatter.BottomSurface = Enum.SurfaceType.Smooth
						Splatter.Size = Vector3.new(0.2, 0.2, 0.2)
						Splatter.CanCollide = true
						local BlockMesh = Instance.new("BlockMesh")
						BlockMesh.Parent = Splatter
						Debris:AddItem(Splatter, 2)
						Splatter.Parent = game:GetService("Workspace")
						Splatter.CFrame = AmmoClone.CFrame + Vector3.new((math.random(-Radius, Radius) / 10), (math.random(-Radius, Radius) / 10), (math.random(-Radius, Radius) / 10))
						Splatter.Velocity = Vector3.new((math.random(-1, 1) * math.random(5, 25)), (math.random(-1, 1) * math.random(5, 25)), (math.random(-1, 1) * math.random(5, 25)))
					end
					AmmoClone:Destroy()
				end
			end
		end)
		Debris:AddItem(BodyForce, 0.375)
		Debris:AddItem(AmmoClone, 5)
		AmmoClone.Parent = game:GetService("Workspace")
		local TargetPoint = Humanoid.TargetPoint
		AmmoClone.CFrame = HandleCloneX.CFrame
		AmmoClone.CFrame = CFrame.new(AmmoClone.Position, TargetPoint)
		AmmoClone.Velocity = CFrame.new(AmmoClone.Position, TargetPoint).lookVector * 75
		wait(ReloadTime)
		Tool.Grip = Grips.NormalGrip
		Mesh.MeshId = Meshes.Loaded
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Character or not Humanoid or not Torso then
		return
	end
	Tool.Grip = Grips.NormalGrip
	Mesh.MeshId = Meshes.Loaded
end

function Unequipped()
	
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)