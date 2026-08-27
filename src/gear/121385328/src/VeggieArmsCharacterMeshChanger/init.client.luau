-- Temporarily removes existing arm meshes, replacing 
-- them with AWESOME VEGGIE ARMS
local OldCharacterMeshes = {}

local TIME_WITH_AWESOME_ARMS = 15
local NEW_WALK_SPEED = 20
local DEFAULT_WALK_SPEED = 16



local LeftArmMesh = script:WaitForChild('LeftArmMesh')
local RightArmMesh = script:WaitForChild('RightArmMesh')
local RepelScript = script:WaitForChild('RepelScript')
local LeftArmRepelScript = nil
local RightArmRepelScript = nil

-- Delete old meshes...
local character = script.Parent
for _, child in pairs(character:GetChildren()) do
	if child.ClassName == 'CharacterMesh' and (child.BodyPart == 'LeftArm' or child.BodyPart == 'RightArm') then
		OldCharacterMeshes[child.BodyPart] = child
		child.Parent = nil
	end
end

-- ... and add new ones
LeftArmMesh.Parent = character
RightArmMesh.Parent = character

-- also change walkspeed because why not
local humanoid = character:FindFirstChild('Humanoid')
if humanoid and humanoid.ClassName == 'Humanoid' then
	print("Changing walk speeed")
	humanoid.WalkSpeed = NEW_WALK_SPEED
end

-- make arms "awesome"
local leftArm = character:FindFirstChild('Left Arm')
print("Left arm is " .. tostring(leftArm))
if leftArm then
	print("Adding script to left arrrm")
	LeftArmRepelScript = RepelScript:Clone()
	LeftArmRepelScript:WaitForChild('CharacterToIgnore').Value = character
	LeftArmRepelScript.Disabled = false
	LeftArmRepelScript.Parent = leftArm
end
local rightArm = character:FindFirstChild('Right Arm')
if rightArm then
	print("addad sfr right armm")
	RightArmRepelScript = RepelScript:Clone()
	RightArmRepelScript:WaitForChild('CharacterToIgnore').Value = character
	RightArmRepelScript.Disabled = false
	RightArmRepelScript.Parent = rightArm
end

wait(TIME_WITH_AWESOME_ARMS)

LeftArmMesh:Remove()
RightArmMesh:Remove()
if LeftArmRepelScript then LeftArmRepelScript:Remove() end
if RightArmRepelScript then RightArmRepelScript:Remove() end

if OldCharacterMeshes['LeftArm'] then
	OldCharacterMeshes['LeftArm'].Parent = script.Parent
end
if OldCharacterMeshes['RightArm'] then
	OldCharacterMeshes['RightArm'].Parent = script.Parent
end
if script.Parent then
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid.ClassName == "Humanoid" then
		humanoid.WalkSpeed = DEFAULT_WALK_SPEED
	end
end

script:Remove()
