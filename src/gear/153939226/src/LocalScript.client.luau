--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

BunnyModel = InsertService:LoadAsset(153878529)
BunnyAI = BunnyModel:GetChildren()[1]:Clone()
BunnyModel:Destroy()

BunnySpawnRadius = 10

BunnySpawns = {}
Bunnies = {}
Debounce = false

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

function DisableTool()
	Tool.Enabled = false
	wait(20)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function Activated(Mouse)
	if #Bunnies == 0 then
		Debounce = true
		local HandleClone = Handle:Clone()
		HandleClone.CanCollide = true
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.cframe = Handle.CFrame
		BodyGyro.Parent = HandleClone
		Handle.Transparency = 1
		Debris:AddItem(HandleClone, 10)
		HandleClone.Parent = game:GetService("Workspace")
		HandleClone.CFrame = Handle.CFrame
		wait(2)
		if HandleClone and HandleClone.Parent then
			for i = 1, 100 do
				if HandleClone and HandleClone.Parent then
					HandleClone.Transparency = HandleClone.Transparency + 0.01
					if HandleClone.Transparency >= 0.999 then
						HandleClone:Destroy()
						break
					end
				else
					break
				end
				wait()
			end
		end
		for i = 1, 15 do
			local BunnySpawn = Instance.new("Model")
			BunnySpawn.Name = "BunnySpawn"
			local ExteriorSpawn = Instance.new("Part")
			ExteriorSpawn.Name = "ExteriorSpawn"
			ExteriorSpawn.BrickColor = BrickColor.new("Brown")
			ExteriorSpawn.Anchored = true
			ExteriorSpawn.CanCollide = false
			ExteriorSpawn.Locked = true
			ExteriorSpawn.Shape = Enum.PartType.Block
			ExteriorSpawn.Material = Enum.Material.Plastic
			ExteriorSpawn.TopSurface = Enum.SurfaceType.Smooth
			ExteriorSpawn.BottomSurface = Enum.SurfaceType.Smooth
			ExteriorSpawn.FormFactor = Enum.FormFactor.Custom
			ExteriorSpawn.Size = Vector3.new(2, 0.25, 2)
			ExteriorSpawn.Parent = BunnySpawn
			ExteriorSpawn.CFrame = CFrame.new((Torso.Position.X + math.random(-BunnySpawnRadius, BunnySpawnRadius)), (Torso.Position.Y - (Torso.Size.Y * 1.5) - (ExteriorSpawn.Size.Y / 2) + (ExteriorSpawn.Size.Y / 4)), (Torso.Position.Z + math.random(-BunnySpawnRadius, BunnySpawnRadius)))
			local CylinderMesh = Instance.new("CylinderMesh")
			CylinderMesh.Parent = ExteriorSpawn
			local InteriorSpawn = ExteriorSpawn:Clone()
			InteriorSpawn.Name = "InteriorSpawn"
			InteriorSpawn.BrickColor = BrickColor.new("Black")
			InteriorSpawn.Size = Vector3.new(1.75, 0.25, 1.75)
			InteriorSpawn.Parent = BunnySpawn
			InteriorSpawn.CFrame = ExteriorSpawn.CFrame + Vector3.new(0, 0.01, 0)
			table.insert(BunnySpawns, BunnySpawn)
			Debris:AddItem(BunnySpawn, 15)
			BunnySpawn.Parent = game:GetService("Workspace")
		end
		for i, v in pairs(BunnySpawns) do
			local BunnyAIClone = BunnyAI:Clone()
			BunnyAIClone:FindFirstChild("Creator").Value = Player
			local BunnyTorso = BunnyAIClone:FindFirstChild("Torso")
			table.insert(Bunnies, BunnyAIClone)
			Debris:AddItem(BunnyAIClone, (60 * 2))
			BunnyAIClone.Parent = game:GetService("Workspace")
			BunnyTorso.CFrame = v:GetModelCFrame() - Vector3.new(0, ((BunnyAI:GetModelSize().Y / 2) + (v:GetModelSize().Y / 2)), 0)
			BunnyTorso.Anchored = true
		end
		for i = 0.01, BunnyAI:GetModelSize().Y * 1.15, 0.01 do
			for i, v in pairs(Bunnies) do
				local BunnyTorso = v:FindFirstChild("Torso")
				if BunnyTorso then
					BunnyTorso.CFrame = BunnyTorso.CFrame + Vector3.new(0, 0.01, 0)
				end
			end
			wait()
		end
		for i, v in pairs(Bunnies) do
			local BunnyTorso = v:FindFirstChild("Torso")
			local BunnyHumanoid = v:FindFirstChild("Humanoid")
			if BunnyTorso then
				BunnyTorso.Anchored = false
			end
			if BunnyHumanoid then
				v.Changed:connect(function()
					if not v.Parent then
						for ii, vv in pairs(Bunnies) do
							if v == vv then
								table.remove(Bunnies, ii)
								if #Bunnies == 0 then
									DisableTool()
								end
							end
						end						
					end
				end)
				BunnyHumanoid.Died:connect(function()
					for ii, vv in pairs(Bunnies) do
						if v == vv then
							table.remove(Bunnies, ii)
							if #Bunnies == 0 then
								DisableTool()
							end
						end
						v:Destroy()
					end
				end)
			end
		end
		Debounce = false
	else
		for i, v in pairs(Bunnies) do
			if Mouse.Target then
				local character, humanoid = FindCharacterAncestor(Mouse.Target)
				if character and humanoid and humanoid.Health > 0 then
					v.Target.Value = character
					v.Mode.Value = "Attack"
				else
					v.Target.Value = nil
					v.WalkToPoint.Value = Mouse.Hit.p
					v.Mode.Value = "Wander"
				end
			else
				v.Target.Value = nil
				if v.Mode.Value == "Pause" then
					v.Mode.Value = "Follow"
				else
					v.Mode.Value = "Pause"
				end
			end
		end
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Character or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Mouse.Button1Down:connect(function()
		if Tool.Enabled and not Debounce then
			Activated(Mouse)
		end
	end)
end

function Unequipped()
	
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)