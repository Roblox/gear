--Created by StarWars
local Tool = script.Parent

local GearService = require(1075123174)
local PunchArms = GearService:BindGear(Tool, "PunchArms")

local LeftArm = Tool:FindFirstChild("LeftArm")
local Handle = Tool:FindFirstChild("Handle")

if LeftArm then
	LeftArm:Destroy()
end
if Handle then
	Handle:Destroy()
end

local LeftMesh = nil 

PunchArms:BindEquippedFunction("AddingMeshesToArms", function()
	if PunchArms.Humanoid.RigType == Enum.HumanoidRigType.R6 then
		LeftMesh = Instance.new("SpecialMesh")
		
		LeftMesh.Name = "LeftSpecialMesh"
		LeftMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
		LeftMesh.Offset = Vector3.new(-0.1, -0.7, 0)
		LeftMesh.MeshId = "rbxassetid://2565635389"		
		LeftMesh.TextureId = "rbxassetid://2565635991"
		LeftMesh.Parent = PunchArms.Character:FindFirstChild("Left Arm")
	end	
end)

PunchArms:BindUnequippedFunction("RemovingMeshesFromArms", function()
	if LeftMesh and LeftMesh.Parent then
		LeftMesh:Destroy()
	end
	
	LeftMesh = nil
end)