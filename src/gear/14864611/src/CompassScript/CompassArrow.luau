--Made by StarWars
local Debris = game:GetService("Debris")

local Mesh = Instance.new("SpecialMesh")
Mesh.MeshType = Enum.MeshType.FileMesh
Mesh.MeshId = "http://www.roblox.com/asset/?id=14656345" 
Mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
Mesh.Name = "Mesh"

local ACTIVE_TIME = 10

function CreateArrow()
	local Part = Instance.new("Part")
	Part.Size = Vector3.new(1, 0.4, 1)
	Part.Transparency = 0.5
	Part.BrickColor = BrickColor.new(21)
	Part.CanCollide = false
	Part.Locked = true
	Part.RotVelocity = Vector3.new(math.random(), math.random(), math.random()) * 10
	
	local NewMesh = Mesh:Clone()
	NewMesh.Parent = Part
	
	return Part
end

function ActivateArrow(Character)
	local NewArrow = CreateArrow()
	NewArrow.Parent = workspace
	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	local LookVector = Vector3.new(Torso.CFrame.lookVector.x, 0, Torso.CFrame.lookVector.z)
	NewArrow.CFrame = CFrame.new(Torso.CFrame.p + LookVector * 8, LookVector.unit)
	
	local BodyPosition = Instance.new("BodyPosition", NewArrow)
	BodyPosition.Position = NewArrow.Position
	
	local BodyGyro = Instance.new("BodyGyro", NewArrow)
	BodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 0, 1))
	BodyGyro.MaxTorque = Vector3.new(7e7, 7e7, 7e7)	
	
	Debris:AddItem(NewArrow, ACTIVE_TIME)
end

local module = {ActivateArrow = ActivateArrow}

return module
