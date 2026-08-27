--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

FrightenScript = script:WaitForChild("FrightenScript")

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

Animations = {
}

Sounds = {
	BatScreech = Handle:WaitForChild("BatScreech"),
	GhostScream = Handle:WaitForChild("GhostScream"),
	PumpkinSplat = Handle:WaitForChild("PumpkinSplat"),
	Launch = Handle:WaitForChild("Launch")
}

Objects = {
	Pumpkins = {
		{
			Size = Vector3.new(0.75, 0.9, 0.75),
			MeshId = "http://www.roblox.com/asset/?id=64490321",
			TextureId = "http://www.roblox.com/asset/?id=64490105",
			Scale = Vector3.new(0.75, 0.75, 0.75),
			VertexColor = Vector3.new(1, 1, 1)
		},
		{
			Size = Vector3.new(1, 0.9, 1),
			MeshId = "http://www.roblox.com/asset/?id=37223756",
			TextureId = "http://www.roblox.com/asset/?id=37223746",
			Scale = Vector3.new(0.75, 0.75, 0.8),
			VertexColor = Vector3.new(1, 1, 1)
		},
		{
			Size = Vector3.new(1, 0.8, 1),
			MeshId = "http://www.roblox.com/asset/?id=37223787",
			TextureId = "http://www.roblox.com/asset/?id=37223779",
			Scale = Vector3.new(1, 1, 1),
			VertexColor = Vector3.new(1, 1, 1)
		},
		{
			Size = Vector3.new(0.8, 0.6, 0.9),
			MeshId = "http://www.roblox.com/asset/?id=16435900",
			TextureId = "http://www.roblox.com/asset/?id=16435893",
			Scale = Vector3.new(0.5, 0.5, 0.5),
			VertexColor = Vector3.new(1, 1, 1)
		}
	},
	Ghosts = {
		{
			Size = Vector3.new(1.25, 1.5, 0.5),
			MeshId = "http://www.roblox.com/asset/?id=64445076",
			TextureId = "http://www.roblox.com/asset/?id=64445059",
			Scale = Vector3.new(0.5, 0.5, 0.5),
			VertexColor = Vector3.new(1, 1, 1)
		},
		{
			Size = Vector3.new(2, 1.25, 0.5),
			MeshId = "http://www.roblox.com/asset/?id=89391602",
			TextureId = "http://www.roblox.com/asset/?id=89391636",
			Scale = Vector3.new(0.25, 0.25, 0.25),
			VertexColor = Vector3.new(0.8, 1, 0.8)
		},
		{
			Size = Vector3.new(0.75, 1.5, 0.75),
			MeshId = "http://www.roblox.com/asset/?id=179124206",
			TextureId = "http://www.roblox.com/asset/?id=179124246",
			Scale = Vector3.new(0.25, 0.25, 0.25),
			VertexColor = Vector3.new(0.8, 1, 0.8)
		}
	},
	Bats = {
		{
			Size = Vector3.new(2.75, 0.5, 1),
			MeshId = "http://www.roblox.com/asset?id=178495237",
			TextureId = "http://www.roblox.com/asset?id=178495266",
			Scale = Vector3.new(1, 1, 1),
			VertexColor = Vector3.new(1, 1, 1)
		}
	},
}

PumpkinSplatterImages = {
	183686598,
	183686615,
	183686632,
	183686647,
	183686670
}

Equipped = false

Gravity = 196.20

ReloadTime = 3
RetractTime = 1

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local ByteKey = string.byte(Key)
			local Down = Value.Down
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
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
		s.Image = "http://www.roblox.com/asset/?id=" .. PumpkinSplatterImages[math.random(1, #PumpkinSplatterImages)]
		s.Parent = MainFrame
	
		Debris:AddItem(s, (5 + (math.random() * 2)))
	
		for i = 1, 20 do
			local s = Instance.new("ImageLabel")
			local size = ((math.random() * 0.05) + 0.05)
			s.Size = UDim2.new(size,0, size, 0)
			s.Position = UDim2.new((math.random() - (size / 2)), 0, (math.random() - (size / 2)), 0)
			s.SizeConstraint = Enum.SizeConstraint.RelativeXX
			s.Transparency = 1
			s.Image = "http://www.roblox.com/asset/?id=" .. PumpkinSplatterImages[math.random(1, #PumpkinSplatterImages)]
			s.Parent = MainFrame
			Debris:AddItem(s, (3 + (math.random() * 6)))
		end
	
		Debris:AddItem(ScreenGui, 10)
		
		ScreenGui.Parent = PlayerGui		
	
	end
end

function CreateAmmo()
	if AmmoPart and AmmoPart.Parent then
		AmmoPart:Destroy()
	end
	local Indexes = {}
	for i, v in pairs(Objects) do
		table.insert(Indexes, i)
	end
	local RandomIndex = Indexes[math.random(1, #Indexes)]
	local AmmoType = Objects[RandomIndex]
	local AmmoChosen = AmmoType[math.random(1, #AmmoType)]
	AmmoPart = BasePart:Clone()
	AmmoPart.Name = "LauncherAmmo"
	AmmoPart.Size = AmmoChosen.Size
	local AmmoMesh = Instance.new("SpecialMesh")
	AmmoMesh.MeshType = Enum.MeshType.FileMesh
	AmmoMesh.MeshId = AmmoChosen.MeshId
	AmmoMesh.TextureId = AmmoChosen.TextureId
	AmmoMesh.Scale = AmmoChosen.Scale
	AmmoMesh.VertexColor = AmmoChosen.VertexColor
	AmmoMesh.Parent = AmmoPart
	local AmmoWeld = Instance.new("Weld")
	AmmoWeld.Name = "AmmoWeld"
	AmmoWeld.Part0 = SkeletonHand
	AmmoWeld.Part1 = AmmoPart
	AmmoWeld.C0 = CFrame.new(0, ((SkeletonHand.Size.Y / 2) + (AmmoPart.Size.Y / 2) - (SkeletonHand.Size.Y / 2) - 0.05), ((SkeletonHand.Size.Z / 2) + (AmmoPart.Size.Z / 2) - AmmoPart.Size.Z))
	AmmoWeld.Parent = AmmoPart
	if Equipped then
		AmmoPart.Parent = Tool
	end
	return {Part = AmmoPart, Type = AmmoType}, AmmoWeld
end

function GetAmmo()
	AmmoPart, AmmoWeld = CreateAmmo()
end

function CreateCoffinWithHand()
	local Coffin = BasePart:Clone()
	Coffin.Name = "Coffin"
	Coffin.Size = Vector3.new(1.25, 1.125, 2.75)
	Coffin.CanCollide = false
	local CoffinMesh = Instance.new("SpecialMesh")
	CoffinMesh.MeshType = Enum.MeshType.FileMesh
	CoffinMesh.MeshId = "http://www.roblox.com/asset?id=178527856"
	CoffinMesh.TextureId = "http://www.roblox.com/asset?id=178528380"
	CoffinMesh.Scale = Vector3.new(1, 1, 1)
	CoffinMesh.Parent = Coffin
	
	local ConnectorPart = BasePart:Clone()
	ConnectorPart.Name = "ConnnectorPart"
	ConnectorPart.Transparency = 1
	ConnectorPart.Size = Vector3.new(0.2, 0.2, 0.2)
	ConnectorPart.CanCollide = false
	
	local SkeletonHand = BasePart:Clone()
	SkeletonHand.Name = "SkeletonHand"
	SkeletonHand.Size = Vector3.new(1.25, 0.25, 2.5)
	SkeletonHand.CanCollide = false
	local SkeletonHandMesh = Instance.new("SpecialMesh")
	SkeletonHandMesh.MeshType = Enum.MeshType.FileMesh
	SkeletonHandMesh.MeshId = "http://www.roblox.com/asset?id=178527811"
	SkeletonHandMesh.TextureId = "http://www.roblox.com/asset?id=178528380"
	SkeletonHandMesh.Scale = Vector3.new(1, 1, 1)
	SkeletonHandMesh.Parent = SkeletonHand
	
	local CoffinWeld = Instance.new("Weld")
	CoffinWeld.Name = "CoffinWeld"
	CoffinWeld.Part0 = Handle
	CoffinWeld.Part1 = Coffin
	CoffinWeld.C0 = CFrame.new(0, 0, 0)
	CoffinWeld.C1 = CFrame.new(0, 0.1, 0.025)
	CoffinWeld.Parent = Coffin
	
	local ConnectorWeld = Instance.new("Weld")
	ConnectorWeld.Name = "ConnectorWeld"
	ConnectorWeld.Part0 = Coffin
	ConnectorWeld.Part1 = ConnectorPart
	ConnectorWeld.C0 = CFrame.new(0, 0.5375, -0.9)
	ConnectorWeld.Parent = Coffin
	
	local SkeletonHandMotor = Instance.new("Motor6D")
	SkeletonHandMotor.Name = "SkeletonHandMotor"
	SkeletonHandMotor.Part0 = ConnectorPart
	SkeletonHandMotor.Part1 = SkeletonHand
	SkeletonHandMotor.C0 = CFrame.new(-0.0125, 0, 0) * CFrame.Angles(0, -(math.pi / 2), 0)
	SkeletonHandMotor.C1 = CFrame.new(-0.025, -0.1, -1.13) * CFrame.Angles(0, -(math.pi / 2), 0)
	SkeletonHandMotor.MaxVelocity = 0.1
	SkeletonHandMotor.Parent = Coffin
	
	Coffin.Parent = Tool
	ConnectorPart.Parent = Tool
	SkeletonHand.Parent = Tool
	
	return Coffin, ConnectorPart, SkeletonHand, SkeletonHandMotor
	
end

function CheckIfAlive()
	return (Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	SkeletonHandMotor.DesiredAngle = 1
	Sounds.Launch:Play()
	if AmmoPart and AmmoPart.Part.Parent and AmmoWeld and AmmoWeld.Parent then
		local CurrentCharacter = Character
		local CurrentAmmo = AmmoPart.Part
		local CurrentType = AmmoPart.Type
		local FirstHit = false
		CurrentAmmo.Touched:connect(function(Hit)
			if not Hit or not Hit.Parent then
				return
			end
			local character = Hit.Parent
			if character:IsA("Tool") or character:IsA("Hat") then
				character = character.Parent
			end
			if character == CurrentCharacter then
				return
			end
			if CurrentType == Objects.Pumpkins and not FirstHit then
				FirstHit = true
				if CurrentAmmo and CurrentAmmo.Parent then
					local Sound = Sounds.PumpkinSplat:Clone()
					Sound.Parent = CurrentAmmo
					Sound:Play()
					local AmmoCFrame = CurrentAmmo.CFrame
					if CurrentAmmo and CurrentAmmo.Parent then
						CurrentAmmo:Destroy()
					end
					local Radius = 2
					local Radius = (Radius * 10)
					local TouchConnections = {}
					for i = 1, 50 do
						local Splatter = Instance.new("Part")
						Splatter.Name = "PumpkinSplatter"
						Splatter.BrickColor = BrickColor.new("Br. yellowish orange")
						Splatter.Material = Enum.Material.Plastic
						Splatter.Shape = Enum.PartType.Block
						Splatter.FormFactor = Enum.FormFactor.Custom
						Splatter.TopSurface = Enum.SurfaceType.Smooth
						Splatter.BottomSurface = Enum.SurfaceType.Smooth
						Splatter.Size = Vector3.new(0.2, 0.2, 0.2)
						Splatter.CanCollide = true
						local BlockMesh = Instance.new("BlockMesh")
						BlockMesh.Parent = Splatter
						Debris:AddItem(Splatter, 2)
						local SplatterHit = Splatter.Touched:connect(function(Hit2)
							if not Hit2 or not Hit2.Parent then
								return
							end
							local character2 = Hit2.Parent
							if character2:IsA("Tool") or character:IsA("Hat") then
								character2 = character.Parent
							end
							if character2 == CurrentCharacter then
								return
							end
							local humanoid = character2:FindFirstChild("Humanoid")
							if humanoid and humanoid.Health > 0 then
								local player = Players:GetPlayerFromCharacter(character2)
								if player then
									CoverScreen(player)
								end
							end
						end)
						table.insert(TouchConnections, SplatterHit)
						Splatter.Parent = game:GetService("Workspace")
						Splatter.CFrame = AmmoCFrame + Vector3.new((math.random(Radius, Radius) / 100), (math.random(Radius, Radius) / 100), (math.random(Radius, Radius) / 100))
						Splatter.Velocity = Vector3.new((math.random(-1, 1) * math.random(5, 25)), (math.random(-1, 1) * math.random(5, 25)), (math.random(-1, 1) * math.random(5, 25)))
					end
					Delay(0.5, function()
						for i, v in pairs(TouchConnections) do
							if v then
								v:disconnect()
							end
						end
					end)
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoid and humanoid.Health > 0 then
					end
				end
			elseif CurrentType == Objects.Ghosts then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 then
					FirstHit = true
					CurrentAmmo.Anchored = true
					local Mesh = CurrentAmmo:FindFirstChild("Mesh")
					if Mesh then
						local Sound = Sounds.GhostScream:Clone()
						Sound.Parent = CurrentAmmo
						Sound:Play()
						local OriginalScale = Mesh.Scale
						if not character:FindFirstChild(FrightenScript.Name) then
							local FrightenScriptClone = FrightenScript:Clone()
							FrightenScriptClone.Disabled = false
							FrightenScriptClone.Parent = character
						end
						for i = 1, 25 do
							if CurrentAmmo and CurrentAmmo.Parent then
								Mesh.Scale = (OriginalScale + (Vector3.new(0.01, 0.01, 0.01) * i))
								wait(0.01)
							end
						end
					end
				end
			elseif CurrentType == Objects.Bats then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid and humanoid.Health > 0 then
					FirstHit = true
					if CurrentAmmo and CurrentAmmo.Parent then
						CurrentAmmo:Destroy()
					end
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(25)
				end
			end
		end)
		CurrentAmmo.Parent = game:GetService("Workspace")
		Debris:AddItem(CurrentAmmo, 5)
	
		local TargetPosition = InvokeClient("MousePosition", nil)
		
		AmmoWeld:Destroy()
		
		if CurrentType == Objects.Pumpkins then
			local Direction = (TargetPosition - CurrentAmmo.Position)
			Direction = Direction - Direction.unit * 5
			
			local DeltaXZSquared = (Direction.X * Direction.X + Direction.Z * Direction.Z)
			local DeltaXZ = math.sqrt(DeltaXZSquared)
			local DeltaY = Direction.Y
			local Alpha = (math.random() * math.pi / 4 + math.pi / 8)
			local Numerator = (-0.5 * Gravity * DeltaXZSquared)
			local Denominator = (math.cos(Alpha) * math.cos(Alpha) * (DeltaY - math.tan(Alpha) * DeltaXZ))
			if Denominator == 0 then
				return
			end
			local MissileSpeed = math.sqrt(Numerator / Denominator)
			if MissileSpeed > 80 then
				MissileSpeed = 80
			end
			local VectorXZ = (MissileSpeed * math.cos(Alpha))
			local VectorY = (MissileSpeed * math.sin(Alpha))
			local VectorX = (VectorXZ * Direction.X / DeltaXZ)
			local VectorZ = (VectorXZ * Direction.Z / DeltaXZ)
			CurrentAmmo.Velocity = Vector3.new(VectorX, VectorY, VectorZ)
		elseif CurrentType == Objects.Ghosts then
			CurrentAmmo.CanCollide = false
			local FlightSpeed = 50
			local Direction = CFrame.new(CurrentAmmo.Position, TargetPosition)
			local Mass = (CurrentAmmo:GetMass() * Gravity)
			CurrentAmmo.CFrame = Direction
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyVelocity.velocity = Direction.lookVector * FlightSpeed
			BodyVelocity.Parent = CurrentAmmo
			CurrentAmmo.Velocity = BodyVelocity.velocity
		elseif CurrentType == Objects.Bats then
			local Sound = Sounds.BatScreech:Clone()
			Sound.Parent = CurrentAmmo
			Sound:Play()
			CurrentAmmo.CanCollide = true
			local FlightSpeed = 100
			local Direction = CFrame.new(CurrentAmmo.Position, TargetPosition)
			local Mass = (CurrentAmmo:GetMass() * Gravity)
			CurrentAmmo.CFrame = Direction
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
			BodyVelocity.velocity = Direction.lookVector * FlightSpeed
			BodyVelocity.Parent = CurrentAmmo
			local BodyGyro = Instance.new("BodyGyro")
			BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			BodyGyro.cframe = Direction
			BodyGyro.Parent = CurrentAmmo
			CurrentAmmo.Velocity = BodyVelocity.velocity
		end
		
	end
	AmmoPart = nil
	AmmoWeld = nil
	wait(RetractTime)
	SkeletonHandMotor.DesiredAngle = 0
	wait(ReloadTime)
	GetAmmo()
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	Equipped = true
	Handle.Transparency = 1
	Spawn(function()
		Coffin, ConnectorPart, SkeletonHand, SkeletonHandMotor = CreateCoffinWithHand()
		if Tool.Enabled then
			if not AmmoPart or not AmmoWeld then
				GetAmmo()
			else
				AmmoWeld.Part0 = SkeletonHand
				AmmoWeld.Part1 = AmmoPart.Part
				AmmoWeld.Parent = AmmoPart.Part
				AmmoPart.Part.Parent = Tool
			end
		end
	end)
end

function Unequipped()
	if not Equipped then
		return
	end
	Equipped = false
	for i, v in pairs({SkeletonHand, ConnectorPart, Coffin}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	if AmmoPart and AmmoPart.Part.Parent and AmmoWeld then
		AmmoWeld.Parent = nil
		AmmoPart.Part.Parent = nil
	else
		AmmoPart = nil
		AmmoWeld = nil
	end
	Handle.Transparency = 0
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)