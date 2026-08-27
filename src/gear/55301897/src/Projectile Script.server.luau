math.randomseed(tick())

-- First make some standard variable declarations and checks
local Tool = script.Parent
local myCharacter = Tool.Parent
if not myCharacter then script:Remove() end
local myHumanoid = myCharacter:FindFirstChild("Humanoid")
local Torso = myCharacter:FindFirstChild("Torso")
if myHumanoid and Torso then

	LookVector = Torso.CFrame.lookVector.unit

	local Baseball = Instance.new("Part")
	Baseball.Name = "Baseball"
	Baseball.formFactor = 3	--Custom
	Baseball.Size = Vector3.new(0.3, 0.3, 0.3)
	Baseball.Locked = true
	Baseball.Material = "Grass"
	Baseball.RotVelocity = Vector3.new(math.random(), math.random(), math.random())
	Baseball.Position = Torso.Position + 2 * LookVector  + Vector3.new(LookVector.Z, 0, -LookVector.X)
	Baseball.Parent = game.Workspace

	local BaseballMesh = Instance.new("SpecialMesh")
	BaseballMesh.MeshId = "http://www.roblox.com/asset/?id=55021861"
	BaseballMesh.TextureId = "http://www.roblox.com/asset/?id=55021914"
	BaseballMesh.Parent = Baseball

	local Loft = Instance.new("BodyForce")
	Loft.force = Baseball:GetMass() * Vector3.new(LookVector.Z*2000, 1000, -LookVector.X*2000)
	Loft.Parent = Baseball

	wait()
	wait()
	Loft:Remove()
	wait(5)
	Baseball:Remove()
end
script:Remove()
