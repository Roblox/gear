--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Anchored = false
BasePart.CanCollide = true
BasePart.Locked = true
Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.FileMesh
Mesh.Scale = Vector3.new(1, 1, 1)
Mesh.Parent = BasePart

Animations = {
	ThrowCandy = {Animation = Tool:WaitForChild("ThrowCandy"), FadeTime = nil, Weight = nil, Speed = 1, Duration = 2.5},
}

Sounds = {
	Handle:WaitForChild("Hit1"),
	Handle:WaitForChild("Hit2"),
	Handle:WaitForChild("Hit3"),
	Handle:WaitForChild("Hit4")
}

Candy = {
	Meshes = {
		{Name = "BloxyDrops", MeshId = 179536104, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "BloxRoll", MeshId = 179536148, Size = Vector3.new(0.6, 0.4, 0.4)},
		{Name = "BlueDark", MeshId = 179536189, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "BlueLight", MeshId = 179536223, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "Green", MeshId = 179536243, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "Orange", MeshId = 179536282, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "Pink", MeshId = 179536309, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "Purple", MeshId = 179536326, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "Red", MeshId = 179536343, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "Yellow", MeshId = 179536364, Size = Vector3.new(0.4, 0.4, 0.4)},
		{Name = "Chocoblox", MeshId = 179536390, Size = Vector3.new(0.5, 0.4, 0.4)},
		{Name = "MrBloxBar", MeshId = 179536422, Size = Vector3.new(0.4, 0.4, 0.55)}
	},
	Texture = "http://www.roblox.com/asset?id=179535876"
}

Gravity = 196.20

ThrowableCandy = {}

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
	end
end)

function InvokeClient(Mode, Value)
	local ReturnValue = nil
	pcall(function()
		ReturnValue = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ReturnValue
end


function WeldTo(PrimaryPart, SecondaryPart, SecondaryCFrame)
	if not PrimaryPart or not SecondaryPart then
		return
	end
	local Weld = Instance.new("Weld")
	Weld.Name = "Weld"
	Weld.Part0 = PrimaryPart
	Weld.Part1 = SecondaryPart
	Weld.C0 = PrimaryPart.CFrame:inverse()
	Weld.C1 = ((SecondaryCFrame and SecondaryCFrame) or SecondaryPart.CFrame):inverse()
	Weld.Parent = PrimaryPart
	return Weld
end

function PositionPart(Part, X, Y, Z)
	local PartClone = Part:Clone()
	local PartCloneY = PartClone:Clone()
	PartCloneY.CFrame = PartCloneY.CFrame * CFrame.Angles(-math.rad(90), 0, 0)		
	PartCloneY.CFrame = PartCloneY.CFrame - PartCloneY.CFrame.lookVector * Y
	local PartCloneZ = PartCloneY:Clone()
	PartCloneZ.CFrame = PartCloneZ.CFrame + PartClone.CFrame.lookVector * Z
	local PartCloneX = PartCloneZ:Clone()
	PartCloneX.CFrame = PartCloneZ.CFrame * CFrame.Angles(0, math.rad(90), 0)
	PartCloneX.CFrame = PartCloneX.CFrame - PartCloneX.CFrame.lookVector * X
	return PartCloneX.CFrame
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Activated()
	if not Tool.Enabled or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 then
		return
	end
	local LeftArm = Character:FindFirstChild("Left Arm")
	if not LeftArm then
		return
	end
	local CurrentlyEquipped = true
	local ToolUnequipped
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
		if ToolEquipped then
			ToolEquipped:disconnect()
		end
	end)
	Tool.Enabled = false
	local AnimationChosen = Animations.ThrowCandy
	InvokeClient("PlayAnimation", AnimationChosen)
	Delay(1, function()
		if CurrentlyEquipped then
			for i = 1, math.random(5, 15) do
				local CandyChosen = Candy.Meshes[math.random(1, #Candy.Meshes)]
				local CandyPart = BasePart:Clone()
				CandyPart.Name = CandyChosen.Name
				local CandyMesh = CandyPart:FindFirstChild("Mesh")
				CandyMesh.MeshId = tostring("http://www.roblox.com/asset?id=" .. CandyChosen.MeshId)
				CandyMesh.TextureId = tostring("http://www.roblox.com/asset?id=" .. Candy.Texture)
				CandyPart.Size = CandyChosen.Size
				local ArmSizeX, ArmSizeY, ArmSizeZ = ((LeftArm.Size.X / 4) * 100), LeftArm.Size.Y, ((LeftArm.Size.Z / 4) * 100)
				local RandomPositionX = (math.random(-ArmSizeX, ArmSizeX) / 100)
				local RandomPositionY = -(((ArmSizeY / 2) + (CandyPart.Size.Y / 2)) + (math.random(-25, 0) / 100))
				local RandomPositionZ = (math.random(-ArmSizeZ, ArmSizeZ) / 100)
				local CandyCFrame = PositionPart(LeftArm, RandomPositionX, RandomPositionY, RandomPositionZ)
				local Weld = WeldTo(LeftArm, CandyPart, CandyCFrame)
				Delay(0, function()
					if CandyPart and CandyPart.Parent and CurrentlyEquipped then
						Weld.Parent = CandyPart
					end
				end)
				table.insert(ThrowableCandy, {Candy = CandyPart, Weld = Weld})
				Debris:AddItem(CandyPart, 5)
				CandyPart.Parent = game:GetService("Workspace")
			end
			Delay(0.5, function()
				if CurrentlyEquipped then
					local MouseTarget = InvokeClient("MousePosition", nil)
					local CandyWeld = BasePart:Clone()
					CandyWeld.Name = "CandyPart"
					local CurrentCandy = {}
					for i, v in pairs(ThrowableCandy) do
						if v and v.Candy.Parent then
							local CandyPart = v.Candy
							table.insert(CurrentCandy, CandyPart)
							local SoundChosen = Sounds[math.random(1, #Sounds)]
							local Sound = SoundChosen:Clone()
							Sound.Parent = CandyPart
							local Mass = (CandyPart:GetMass() * Gravity) * 100
							local BodyGyro = Instance.new("BodyGyro")
							BodyGyro.maxTorque = Vector3.new(Mass, Mass, Mass)
							BodyGyro.cframe = CandyPart.CFrame
							BodyGyro.Parent = CandyPart
							local BodyVelocity = Instance.new("BodyVelocity")
							BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass)
							BodyVelocity.velocity = CFrame.new(CandyPart.Position, MouseTarget).lookVector * 50
							Debris:AddItem(BodyVelocity, 0.25)
							BodyVelocity.Parent = CandyPart
							if v.Weld and v.Weld.Parent then
								v.Weld:Destroy()
							end
							local CandyHit = false
							CandyPart.Touched:connect(function(Hit)
								if not Hit or not Hit.Parent or CandyHit then
									return
								end
								if not CheckTableForInstance(CurrentCandy, Hit) and Hit ~= LeftArm then
									CandyHit = true
									if Sound and Sound.Parent then
										InvokeClient("PlaySound", Sound)
									end
									for i, v in pairs({BodyGyro, BodyVelocity}) do
										if v and v.Parent then
											v:Destroy()
										end
									end
									CandyPart.Velocity = Vector3.new(0, 0, 0)
									CandyPart.RotVelocity = Vector3.new(0, 0, 0)
								end
							end)
						end
					end
					ThrowableCandy = {}
				end
			end)
		end
	end)
	wait(AnimationChosen.Duration)
	InvokeClient("StopAnimation", AnimationChosen)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Active = false
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	for i, v in pairs(Animations) do
		InvokeClient("Preload", v.Animation.AnimationId)
	end
end

function Unequipped()
	for i, v in pairs(ThrowableCandy) do
		if v and v.Candy.Parent then
			v:Destroy()
		end
	end
	ThrowableCandy = {}
	for i, v in pairs(Animations) do
		if v and v.Parent then
			InvokeClient("StopAnimation", v)
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			InvokeClient("StopSound", v)
		end
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)