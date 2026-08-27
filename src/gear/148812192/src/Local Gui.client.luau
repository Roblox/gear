--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

SpecialReady = true
SpecialCoolDown = 10

Pies = {
	{MeshId = 18417911, TextureId = 18417918, Name = "ApplePie", Scale = Vector3.new(0.35, 0.35, 0.35), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(0, math.pi,0)},
	{MeshId = 40312463, TextureId = 40311968, Name = "CherryPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(0, 0, 0)},
	{MeshId = 40312463, TextureId = 40311869, Name = "BlueberryPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(0, 0, 0)},
	{MeshId = 143518445, TextureId = 143499030, Name = "CherryPie", Scale = Vector3.new(0.5, 0.35, 0.5), Size = Vector3.new(1, 0.25, 1), Angle = CFrame.Angles(0, -(math.pi / 2), -(math.pi / 2))},
	{MeshId = 65950268, TextureId = 65950352, Name = "PumpkinPie", Scale = Vector3.new(0.9, 0.9, 0.9), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(0, 0, 0)},
	{MeshId = 18453224, TextureId = 18453205, Name = "PumpkinPi", Scale = Vector3.new(0.35, 0.35, 0.35), Size = Vector3.new(1, 1, 0.25), Angle = CFrame.Angles(0, math.pi, 0)},
	{MeshId = 125732887, TextureId = 125728597, Name = "PizzaPie", Scale = Vector3.new(0.6, 0.6, 0.6), Size = Vector3.new(1, 0.25, 1), Angle = CFrame.Angles(0, -(math.pi / 2), -(math.pi / 2))}
}

BaseUrl = "http://www.roblox.com/asset?id="

function TagHumanoid(Humanoid, Player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Value = Player
	Creator_Tag.Name = "creator"
	Creator_Tag.Parent = Humanoid
end

function UntagHumanoid(Humanoid)
	if Humanoid and Humanoid.Parent then
		for i, v in pairs(Humanoid:GetChildren()) do
			if v.Name == "creator" then
				v:Destroy()
			end
		end
	end
end

function MakeCircle(Diameter, Consistency, Size, Position)
	local Parts = {}
	for i = 1, 360, Consistency do
		local Part = Instance.new("Part")
		Part.FormFactor = Enum.FormFactor.Custom
		Part.Size = Size
		Part.TopSurface = Enum.SurfaceType.Smooth
		Part.BottomSurface = Enum.SurfaceType.Smooth
		Part.CFrame = CFrame.new(Position) * CFrame.Angles(0, math.rad(i), 0) * CFrame.new(0, 0, Diameter)
		table.insert(Parts, Part)
	end
	return Parts
end

function Fire(v, Part)

	Part.Velocity = v * 200

	local Force = Instance.new("BodyForce")
	Force.force = Vector3.new(0, (Part:GetMass() * 9.81 * 20), 0)
	Force.Parent = Part

	Debris:AddItem(Part, 5)
	
	Part.Parent = game:GetService("Workspace")

end

Tool.Equipped:connect(function(Mouse)
	Mouse.Icon = "rbxasset://textures\\GunCursor.png"
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:WaitForChild("Torso")
	EquipTime = tick()
	Swing = Humanoid:LoadAnimation(Tool.TwoHandSwing)
	Equip = Humanoid:LoadAnimation(Tool.Equip)
	Hold = Humanoid:LoadAnimation(Tool.TwoHandAnim)
	Hold:Play()
	Equip:Play(nil, nil, 0.7)
	Mouse.Button1Down:connect(function()
		if Tool.Enabled and (tick() - EquipTime) > 1.7 then
			Tool.Enabled = false
			Mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			Swing:Play()
			wait(0.75)
			Swing:Stop()
			Mouse.Icon = "rbxasset://textures\\GunCursor.png"
			Tool.Enabled = true
		end
	end)
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == "q" then
			if SpecialReady then
				SpecialReady = false

				local TargetPos = Mouse.Hit.p				
				local LookAt = (TargetPos - Handle.Position).unit
				
				local Circle = MakeCircle(3, 60, Vector3.new(1, 1, 1), Torso.Position)
				
				local TorsoClone = Torso:Clone()
				local TorsoCloneY = TorsoClone:Clone()
				TorsoCloneY.CFrame = TorsoCloneY.CFrame * CFrame.Angles(math.rad(90), 0, 0)

				for i, v in pairs(Circle) do
					v.CanCollide = false
					v.Anchored = true
					v.Parent = Workspace
					v.CFrame = v.CFrame - TorsoCloneY.CFrame.lookVector * ((Torso.Size.y * 2))
					local ChosenPie = Pies[math.random(1, #Pies)]
					v.Name = ChosenPie.Name
					v.Size = ChosenPie.Size
					v.CFrame = v.CFrame * ChosenPie.Angle
					local Mesh = Instance.new("SpecialMesh")
					Mesh.MeshType = Enum.MeshType.FileMesh
					Mesh.MeshId = BaseUrl .. ChosenPie.MeshId
					Mesh.TextureId = BaseUrl .. ChosenPie.TextureId
					Mesh.Scale = ChosenPie.Scale
					Mesh.Parent = v
				end
				
				for i = 0.1, ((((Torso.Position.y + (Torso.Size.y / 2)) - Circle[1].Position.y) - 0.1) * 4) do
					for i, v in pairs(Circle) do
						v.CFrame = v.CFrame + TorsoCloneY.CFrame.lookVector * 0.25
					end
					wait(0.05)
				end
				
				for i,v in pairs(Circle) do
					v.Touched:connect(function(Hit)
						if Hit and Hit.Parent and Hit.Parent ~= Character then
							local humanoid = Hit.Parent:FindFirstChild("Humanoid")
							if humanoid and humanoid.Health > 0 then
								TagHumanoid(humanoid, Player)
								humanoid:TakeDamage(15)
								wait(1)
								UntagHumanoid(humanoid)
							end
						end
					end)
					v.Anchored = false
					Fire(LookAt, v)
				end
				
				wait(SpecialCoolDown)
				
				SpecialReady = true
				
			end
		end
	end)
end)

Tool.Unequipped:connect(function()
	Swing:Stop()
	Equip:Stop()
	Hold:Stop()
end)