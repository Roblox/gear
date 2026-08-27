--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Throw = Handle:WaitForChild("Throw")
Reload = Tool:WaitForChild("Reload")

Loaded = Tool:WaitForChild("Loaded")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Equipped = false
Charging = false
FireDebounce = false

Damage = 20

ReloadTime = 0.25

Grips = {
	Normal = CFrame.new(0, -0.949999988, 1, 1, 0, -3.69598024e-006, -0, 1, 0, 3.69598024e-006, 0, 1),
	Firing = CFrame.new(0, -0.949999988, 1, 1, 0, -3.58562761e-006, 8.69642349e-007, 0.970142543, 0.242535636, 3.4785694e-006, -0.242535636, 0.970142543)
}

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

function EquipQuiver()
	Quiver = Instance.new("Part")
	Quiver.Name = "Quiver"
	Quiver.Material = Enum.Material.Plastic
	Quiver.Shape = Enum.PartType.Block
	Quiver.FormFactor = Enum.FormFactor.Custom
	Quiver.TopSurface = Enum.SurfaceType.Smooth
	Quiver.BottomSurface = Enum.SurfaceType.Smooth
	Quiver.Size = Vector3.new(1.75, 3.75, 1.75)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.MeshId = "http://www.roblox.com/asset?id=159947443"
	Mesh.TextureId = "http://www.roblox.com/asset?id=159947512"
	Mesh.Parent = Quiver
	local Weld = Instance.new("Weld")
	Weld.Part0 = Quiver
	Weld.Part1 = Torso
	Weld.C0 = CFrame.new(0, -0.5, -0.9) * CFrame.Angles(0, 0, (math.pi / 8))
	Weld.Parent = Quiver
	Quiver.Parent = Character
end

function Fire()
	if Tool.Enabled then
		if Loaded.Value then
			Tool.Grip = Grips.Firing
			Delay(0.25, function()
				Tool.Grip = Grips.Normal
			end)
			Tool.Enabled = false
			Loaded.Value = false
			Throw.Pitch = (1.1 + (0.15 * math.random()))
			Throw:Play()
			local FiringPositions = {}
			local HandleClone = Handle:Clone()
			local HandleCloneY = HandleClone:Clone()
			HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
			HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * 0
			local HandleCloneZ = HandleCloneY:Clone()
			HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * (HandleClone.Size.Z / 2)
			local HandleCloneX = HandleCloneZ:Clone()
			HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
			HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * ((HandleClone.Size.X / 2) - 0.5)
			table.insert(FiringPositions, HandleCloneX.CFrame)
			local HandleCloneY = HandleClone:Clone()
			HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
			HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * 0
			local HandleCloneZ = HandleCloneY:Clone()
			HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * (HandleClone.Size.Z / 2)
			local HandleCloneX = HandleCloneZ:Clone()
			HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
			HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * (-(HandleClone.Size.X / 2) + 0.5)
			table.insert(FiringPositions, HandleCloneX.CFrame)
			local HandleCloneY = HandleClone:Clone()
			HandleCloneY.CFrame = HandleCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)		
			HandleCloneY.CFrame = HandleCloneY.CFrame - HandleCloneY.CFrame.lookVector * -(HandleClone.Size.Y / 3)
			local HandleCloneZ = HandleCloneY:Clone()
			HandleCloneZ.CFrame = HandleCloneZ.CFrame + HandleClone.CFrame.lookVector * (HandleClone.Size.Z / 2)
			local HandleCloneX = HandleCloneZ:Clone()
			HandleCloneX.CFrame = HandleCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
			HandleCloneX.CFrame = HandleCloneX.CFrame - HandleCloneX.CFrame.lookVector * 0
			table.insert(FiringPositions, HandleCloneX.CFrame)
			for i, v in pairs(FiringPositions) do
				local Plunger = Instance.new("Part")
				Plunger.Name = "Plunger"
				Plunger.Material = Enum.Material.Plastic
				Plunger.Shape = Enum.PartType.Block
				Plunger.FormFactor = Enum.FormFactor.Custom
				Plunger.TopSurface = Enum.SurfaceType.Smooth
				Plunger.BottomSurface = Enum.SurfaceType.Smooth
				Plunger.Size = Vector3.new(0.75, 0.75, 2.3)
				local Mesh = Instance.new("SpecialMesh")
				Mesh.MeshType = Enum.MeshType.FileMesh
				Mesh.MeshId = "http://www.roblox.com/asset?id=159947401"
				Mesh.TextureId = "http://www.roblox.com/asset?id=159947512"
				Mesh.Parent = Plunger
				local BodyForce = Instance.new("BodyForce")
				BodyForce.force = Vector3.new(0, Plunger:GetMass() * 196.20, 0)
				BodyForce.Parent = Plunger
				local Debounce = false
				Plunger.Touched:connect(function(Hit)
					if Hit and Hit.Parent and Hit.Name ~= Plunger.Name and not Debounce then
						local character, humanoid = FindCharacterAncestor(Hit.Parent)
						if ((character and character ~= Character and humanoid and humanoid.Health > 0) or not character) then
							Debounce = true
							local Weld = Instance.new("Weld")
							Weld.Part0 = Hit
							Weld.Part1 = Plunger
							Weld.C0 = Hit.CFrame:inverse() * Plunger.CFrame
							Weld.C1 = Plunger.CFrame:inverse() * Plunger.CFrame
							Weld.Parent = Plunger

							if character then
								UntagHumanoid(humanoid)
								TagHumanoid(humanoid, Player)
								humanoid:TakeDamage(Damage)
							end
						end
					end
				end)
				Debris:AddItem(Plunger, 5)
				Plunger.Parent = game:GetService("Workspace")
				local TargetPoint = Humanoid.TargetPoint
				Plunger.CFrame = v + Handle.CFrame.lookVector * (Plunger.Size.Z / 2)
				Plunger.CFrame = CFrame.new(Plunger.Position, TargetPoint)
				Plunger.Velocity = CFrame.new(Plunger.Position, TargetPoint).lookVector * 100
			end
			wait(ReloadTime)
			Tool.Enabled = true
		else
			Tool.Enabled = false
			ReloadAnim = Humanoid:LoadAnimation(Reload)
			if ReloadAnim then
				ReloadAnim:Play()
			end
			wait(0.25)
			local LeftArm = Character:FindFirstChild("Left Arm")
			if LeftArm then
				Plunger = Instance.new("Part")
				Plunger.Name = "Plunger"
				Plunger.Material = Enum.Material.Plastic
				Plunger.Shape = Enum.PartType.Block
				Plunger.FormFactor = Enum.FormFactor.Custom
				Plunger.TopSurface = Enum.SurfaceType.Smooth
				Plunger.BottomSurface = Enum.SurfaceType.Smooth
				Plunger.Size = Vector3.new(0.75, 0.75, 2.3)
				local Mesh = Instance.new("SpecialMesh")
				Mesh.MeshType = Enum.MeshType.FileMesh
				Mesh.MeshId = "http://www.roblox.com/asset?id=159947401"
				Mesh.TextureId = "http://www.roblox.com/asset?id=159947512"
				Mesh.Parent = Plunger
				local Weld = Instance.new("Weld")
				Weld.Part0 = Plunger
				Weld.Part1 = LeftArm
				Weld.Parent = Plunger
				Weld.C0 = CFrame.new(0, 1, 0)
				Debris:AddItem(Plunger, 2)
				Plunger.Parent = Character
			end
			wait(1)
			if Plunger and Plunger.Parent then
				Plunger:Destroy()
			end
			if ReloadAnim then
				ReloadAnim:Stop()
			end
			Loaded.Value = true
			wait(ReloadTime)
			Tool.Enabled = true
		end
	end
end

function Activated()
	Fire()
end

function Equipped(Mouse)
	Tool.Grip = Grips.Normal
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Character or not Humanoid or not Torso then
		return
	end
	wait()
	EquipQuiver()
	Equipped = true
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Equipped = false
	if Quiver and Quiver.Parent then
		Quiver:Destroy()
	end
	if ReloadAnim then
		ReloadAnim:Stop()
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)