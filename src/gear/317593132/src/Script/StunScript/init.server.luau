--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Head = Character:FindFirstChild("Head")

Duration = script:FindFirstChild("Duration")

BaseUrl = "http://www.roblox.com/asset/?id="

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

Stars = BasePart:Clone()
Stars.Name = "Stars"
Stars.CanCollide = false
StarMesh = Instance.new("SpecialMesh")
StarMesh.Name = "Mesh"
StarMesh.MeshType = Enum.MeshType.FileMesh
StarMesh.MeshId = (BaseUrl .. "65464100")
StarMesh.TextureId = (BaseUrl .. "65464185")
StarMesh.Scale = Vector3.new(0.1, 0.1, 0.1)
StarMesh.VertexColor = Vector3.new(1, 1, 1)
StarMesh.Offset = Vector3.new(0, 0, 0)
StarMesh.Parent = Stars
StarMotor = Instance.new("Motor6D")
StarMotor.Name = "Motor"
StarMotor.Part0 = nil
StarMotor.Part1 = Stars
StarMotor.C0 = (CFrame.new(0, 0.7, 0) * CFrame.Angles((math.pi / 2), 0, 0))
StarMotor.C1 = CFrame.new(0, 0, 0)
StarMotor.CurrentAngle = 0
StarMotor.DesiredAngle = -999999999
StarMotor.MaxVelocity = 0.05
StarMotor.Parent = Stars

Destroying = false

function DestroyScript()
	if Destroying then
		return
	end
	Destroying = true
	if Humanoid then
		Humanoid.WalkSpeed = 16
		Humanoid.AutoRotate = true
	end
	if PreventTools then
		PreventTools:disconnect()
	end
	if Stars and Stars.Parent then
		Stars:Destroy()
	end
	Debris:AddItem(script, 0.5)
end

if not Duration or Duration.Value <= 0 or not Humanoid or Humanoid.Health == 0 or not Head then
	DestroyScript()
	return
end

StarMotor.Part0 = Head
Stars.Parent = Character

Humanoid:UnequipTools()

PreventTools = Character.ChildAdded:connect(function(Child)
	wait()
	if Child:IsA("Tool") and Child.Parent == Character then
		Humanoid:UnequipTools()
	end
end)

Humanoid.WalkSpeed = 0
Humanoid.AutoRotate = false

while Duration.Value > 0 do
	local Time = wait()
	Duration.Value = (Duration.Value - Time)
end

DestroyScript()