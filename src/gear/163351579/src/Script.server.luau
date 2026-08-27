--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Buzzing = Handle:WaitForChild("Buzzing")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ReloadTime = 5

Damage = 1

BeeDuration = 10
BeeSpeed = 15

Grips = {
	NormalGrip = CFrame.new(0.125, -0.675000012, 0.949999988, 1, 0, -3.69598024e-006, 0, 1, 0, 3.69598024e-006, 0, 1),
	ReleaseGrip = CFrame.new(0.125, -0.675000012, 0.949999988, 1, 0, -7.76634351e-007, 9.632965e-008, 0.992277861, 0.124034733, 7.706372e-007, -0.124034733, 0.992277861)
}

Bee = Instance.new("Part")
Bee.Name = "KillerBee"
Bee.Material = Enum.Material.Plastic
Bee.Shape = Enum.PartType.Block
Bee.FormFactor = Enum.FormFactor.Custom
Bee.TopSurface = Enum.SurfaceType.Smooth
Bee.BottomSurface = Enum.SurfaceType.Smooth
Bee.Size = Vector3.new(0.2, 0.2, 0.2)
Bee.CanCollide = false
BeeMesh = Instance.new("SpecialMesh")
BeeMesh.MeshType = Enum.MeshType.FileMesh
BeeMesh.MeshId = "http://www.roblox.com/asset?id=162005808"
BeeMesh.TextureId = "http://www.roblox.com/asset?id=162005862"
BeeMesh.Scale = Vector3.new(1, 1, 1)
BeeMesh.Parent = Bee

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

function CheckTable(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		local Positions = {
			Vector3.new(-0.05, 0, ((Handle.Size.Z / 2) + (Bee.Size.Z / 2) - 0.15)),
			Vector3.new(-0.075, 0.2, ((Handle.Size.Z / 2) + (Bee.Size.Z / 2) - 0.15)),
			Vector3.new(0.15, -0.05, ((Handle.Size.Z / 2) + (Bee.Size.Z / 2) - 0.15)),
			Vector3.new(0.3, 0.1, ((Handle.Size.Z / 2) + (Bee.Size.Z / 2) - 0.15)),
			Vector3.new(0.25, 0.3, ((Handle.Size.Z / 2) + (Bee.Size.Z / 2) - 0.15)),
			Vector3.new(0.05, 0.35, ((Handle.Size.Z / 2) + (Bee.Size.Z / 2) - 0.15)),
		}
		local BeeModel = Instance.new("Model")
		BeeModel.Name = "Bees"
		local Bees = {}
		local BeeConnections = {}
		Spawn(function()
			local BeeCheck = tick()
			while (#Bees == 0 and (tick() - BeeCheck) < 5) do
				wait()
			end
			if #Bees > 0 then
				local BeeCheck = tick()
				while (#Bees > 0 and (tick() - BeeCheck) < BeeDuration) do
					for i, v in pairs(Bees) do
						if v and v.Parent then
							Spawn(function()
								local IgnoreObjects = {Character, BeeModel}
								local BeeRadius = 25
								local NegativePartRadius = Vector3.new(((v.Size.X / 2) + (BeeRadius / 1)), 0, ((v.Size.Z / 2) + (BeeRadius / 1)))
								local PositivePartRadius =Vector3.new(((v.Size.X / 2) + (BeeRadius / 1)), 0, ((v.Size.Z / 2) + (BeeRadius / 1)))
								local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new(v.Position - NegativePartRadius, v.Position + PositivePartRadius), IgnoreObjects, 100)
								local Humanoids = {}
								local Torsos = {}
								local ClosestPlayer = {Humanoid = nil, Torso = nil, Distance = BeeRadius}
								for ii, vv in pairs(Parts) do
									if vv and vv.Parent then
										local humanoid = vv.Parent:FindFirstChild("Humanoid")
										local torso = vv.Parent:FindFirstChild("Torso") or vv.Parent:FindFirstChild("UpperTorso")
										if humanoid and humanoid.Health > 0 and torso and not CheckTable(Humanoids, humanoid) then
											table.insert(Humanoids, humanoid)
											table.insert(Torsos, {Humanoid = humanoid, Torso = torso})
										end
									end
								end
								for ii, vv in pairs(Torsos) do
									local Distance = (vv.Torso.Position - v.Position).magnitude
									if vv.Humanoid.Health > 0 and Distance < ClosestPlayer.Distance then
										ClosestPlayer = {Humanoid = vv.Humanoid, Torso = vv.Torso, Distance = Distance}
									end
								end
								if v and v.Parent and ClosestPlayer.Humanoid and ClosestPlayer.Humanoid.Health > 0 and ClosestPlayer.Torso then
									local BeeSwarmRadius = 1
									local BeeCFrame = CFrame.new(v.Position, (ClosestPlayer.Torso.Position + Vector3.new(math.random(-BeeSwarmRadius, BeeSwarmRadius), math.random(-BeeSwarmRadius, BeeSwarmRadius), math.random(-BeeSwarmRadius, BeeSwarmRadius)))) * CFrame.Angles(0, math.pi, 0)
									v.BodyGyro.cframe = BeeCFrame
									v.Velocity = BeeCFrame.lookVector * -BeeSpeed
								end
							end)
						end
					end
					wait()
				end
			end
			for i, v in pairs(BeeConnections) do
				v:disconnect()
			end
			BeeModel:Destroy()
		end)
		Debris:AddItem(BeeModel, BeeDuration)
		BeeModel.Parent = game:GetService("Workspace")
		for i = 1, 5 do
			if not Equipped then
				break
			end
			local OriginalCFrame = Handle.CFrame
			Tool.Grip = Grips.ReleaseGrip
			for ii, vv in pairs(Positions) do
				local BeeClone = Bee:Clone()
				local BodyForce = Instance.new("BodyForce")
				BodyForce.force = Vector3.new(0, BeeClone:GetMass() * 196.20, 0)
				BodyForce.Parent = BeeClone
				local BeeCFrame = PositionProjectile(Handle, vv.X, vv.Y, vv.Z) * CFrame.Angles(math.pi + math.rad(30), (-math.pi + math.rad(30)), math.rad(45))
				local BodyGyro = Instance.new("BodyGyro")
				BodyGyro.maxTorque = Vector3.new(1e+5, 1e+5, 1e+5)
				BodyGyro.cframe = BeeCFrame
				BodyGyro.Parent = BeeClone
				BeeClone.Touched:connect(function(Hit)
					if Hit and Hit.Parent and Hit.Parent ~= Character then
						local humanoid = Hit.Parent:FindFirstChild("Humanoid")
						if humanoid and humanoid.Health > 0 then
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(Damage)
						end
					end
				end)
				
				local BeeRemoved = BeeClone:GetPropertyChangedSignal("Parent"):Connect(function()
					if BeeClone.Parent == nil then
						for iii, vvv in pairs(Bees) do
							if vvv == BeeClone then
								table.remove(Bees, iii)
							end
						end
					end
				end)
				table.insert(BeeConnections, BeeRemoved)
				table.insert(Bees, BeeClone)
				BeeClone.Parent = BeeModel
				BeeClone.CFrame = BeeCFrame
				BeeClone.Velocity = CFrame.new(BeeClone.Position, Vector3.new(OriginalCFrame.p.X, BeeClone.Position.Y, OriginalCFrame.p.Z)).lookVector * -BeeSpeed
			end
			wait(0.25)
			Tool.Grip = Grips.NormalGrip
			wait(0.25)
		end
		while BeeModel and BeeModel.Parent do
			wait()
		end
		wait(ReloadTime)
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
	Equipped = true
	Tool.Grip = Grips.NormalGrip
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