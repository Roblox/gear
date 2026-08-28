--Created by StarWars
local Tool = script.Parent

local GearService = require(1075123174)
local PunchArms = GearService:BindGear(Tool, "PunchArms")

local LeftArm = Tool:FindFirstChild("LeftArm")
local RightArm = Tool:FindFirstChild("RightArm")
local Handle = Tool:FindFirstChild("Handle")

if LeftArm then
	LeftArm:Destroy()
end
if RightArm then
	RightArm:Destroy()
end
if Handle then
	Handle:Destroy()
end

local LeftMesh = nil 
local RightMesh = nil

PunchArms:BindEquippedFunction("AddingMeshesToArms", function()
	if PunchArms.Humanoid.RigType == Enum.HumanoidRigType.R6 then
		LeftMesh = Instance.new("SpecialMesh")
		RightMesh = Instance.new("SpecialMesh")
		
		LeftMesh.Name = "LeftSpecialMesh"
		LeftMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
		LeftMesh.Offset = Vector3.new(-0.1, -0.7, 0)
		LeftMesh.MeshId = "rbxassetid://1084765677"		
		LeftMesh.TextureId = "rbxassetid://1084766128"
		LeftMesh.Parent = PunchArms.Character:FindFirstChild("Left Arm")
		
		RightMesh.Name = "RightSpecialMesh"
		RightMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
		RightMesh.Offset = Vector3.new(0.1, -0.7, 0)
		RightMesh.MeshId = "rbxassetid://1084765804"	
		RightMesh.TextureId = "rbxassetid://1084766128"
		RightMesh.Parent = PunchArms.Character:FindFirstChild("Right Arm")
	end	
end)

PunchArms:BindUnequippedFunction("RemovingMeshesFromArms", function()
	if LeftMesh and LeftMesh.Parent then
		LeftMesh:Destroy()
	end
	if RightMesh and RightMesh.Parent then
		RightMesh:Destroy()
	end
	
	LeftMesh = nil
	RightMesh = nil
end)