local LatestTouchedPart
local TicksWithoutMoving = 0
local AlreadyGrew = false
local HaltGrowing = false

local Treehouse = script.Parent
local Creator = Treehouse:FindFirstChild("Creator")
local Remove = Treehouse:FindFirstChild("Remove")
local BoundingBox = Treehouse.BoundingBox
local BodyGyro = BoundingBox:FindFirstChild("BodyGyro")

local SLOW_SPEED = 5
local MAX_SCALE = 4.0
local DELTA_SCALE = 0.1
local TICKS_UNTIL_GROW_STARTS = 3
local TICK_LENGTH = 0.1


-- ****************************
-- HotThoth's Model resize code (very slightly modified)
-- ****************************

local function findObjectHelper(model, objectName, className, listOfFoundObjects)
	if not model then return end
	local findStart, findEnd = string.find(model.Name, objectName)
	if findStart == 1 and findEnd == #(model.Name) then  -- must match entire name
		if not className or model.className == className or (pcall(model.IsA, model, className) and model:IsA(className)) then
			table.insert(listOfFoundObjects, model)
		end
	end
	if pcall(model.GetChildren, model) then
		local modelChildren = model:GetChildren()
		for i = 1, #modelChildren do
			findObjectHelper(modelChildren[i], objectName, className, listOfFoundObjects)
		end
	end
end

local function trueSizeResizeModelInternal(model, resizeFactor)
	local modelCFrame = model:GetModelCFrame()
	local modelSize = model:GetModelSize()
	local baseParts = {}
	local basePartCFrames = {}
	local joints = {}
	local jointParents = {}
	local meshes = {}
 
	findObjectHelper(model, ".*", "BasePart", baseParts)
	findObjectHelper(model, ".*", "JointInstance", joints)
 
	-- meshes don't inherit from anything accessible?
	findObjectHelper(model, ".*", "FileMesh", meshes)                    -- base class for SpecialMesh and FileMesh
	findObjectHelper(model, ".*", "CylinderMesh", meshes)
	findObjectHelper(model, ".*", "BlockMesh", meshes)
 
	-- store the CFrames, so our other changes don't rearrange stuff
	for _, basePart in pairs(baseParts) do
		basePartCFrames[basePart] = basePart.CFrame
	end
 
	-- scale meshes
	for _,mesh in pairs(meshes) do
		mesh.Scale = mesh.Scale * resizeFactor
	end
 
	-- scale joints
	for _, joint in pairs(joints) do
		joint.C0 = joint.C0 + (joint.C0.p) * (resizeFactor - 1)
		joint.C1 = joint.C1 + (joint.C1.p) * (resizeFactor - 1)
		jointParents[joint] = joint.Parent
	end
 
	-- scale parts and reposition them within the model
	for _, basePart in pairs(baseParts) do
		if pcall(function() basePart.FormFactor = "Custom" end) then basePart.FormFactor = "Custom" end
		basePart.TrueSize.Value = basePart.TrueSize.Value * resizeFactor
		basePart.Size =  basePart.TrueSize.Value
		local oldCFrame = basePartCFrames[basePart]
		local oldPositionInModel = modelCFrame:pointToObjectSpace(oldCFrame.p)
		local distanceFromCorner = oldPositionInModel + modelSize/2
		distanceFromCorner = distanceFromCorner * resizeFactor
		local newOffsetFromCenter = oldPositionInModel * resizeFactor
		local newOffsetFromCorner = distanceFromCorner - modelSize/2
 
		local newPositionInSpace = modelCFrame:pointToWorldSpace(
				Vector3.new(newOffsetFromCenter.x, newOffsetFromCorner.y, newOffsetFromCenter.z))
		basePart.CFrame = oldCFrame - oldCFrame.p + newPositionInSpace
	end
 
	-- pop the joints back, because they prolly got borked
	for _, joint in pairs(joints) do
		joint.Parent = jointParents[joint]
	end
 
	return model
end


-- ********************************
-- End HotThoth's Model resize code
-- ********************************

-- Functions:

function weldInPlace(part0, part1, name)
	local weld = Instance.new("ManualWeld")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = CFrame.new()
	weld.C1 = part1.CFrame:inverse() * part0.CFrame
	if name then
		weld.Name = name
	end
	weld.Parent = part0
end

function weldEverythingInPlace(model, part0)
	local weldCenter = part0
	for _, child in pairs(model:GetChildren()) do
		if child:IsA("BasePart") and child ~= weldCenter then
			weldInPlace(weldCenter, child, "WeldTo" .. child.Name)
		elseif child:IsA("Model") then
			weldEverythingInPlace(child, weldCenter)
		end
	end
end

local function RemakeWelds()
	weldEverythingInPlace(Treehouse, BoundingBox)
end

function applyToModelParts(func, model, ...)
	for _, child in pairs(model:GetChildren()) do
		if child:IsA("BasePart") then
			func(child, ...)
		elseif child:IsA("Model") then
			applyToModelParts(func, child, ...)
		end
	end
end

local function Grow()
	AlreadyGrew = true
	
	applyToModelParts(function(part)
		part.Transparency = 0.0
	end, Treehouse.HouseInterior)

	local rootC1 = LatestTouchedPart.CFrame:inverse() * BoundingBox.CFrame
	
	local scale = Treehouse.TreeMeshPart.Mesh.Scale.x + DELTA_SCALE
	local originalPosition = Treehouse:GetModelCFrame().p
	while scale <= MAX_SCALE do
		local growthFactor = scale / (scale - DELTA_SCALE)
		local prevModelSize = Treehouse:GetModelSize()
		trueSizeResizeModelInternal(Treehouse, growthFactor)
		local rootWeld = Instance.new("ManualWeld")
		rootWeld.Part0 = BoundingBox
		rootWeld.Part1 = LatestTouchedPart
		rootWeld.C0 = CFrame.new()
		rootWeld.C1 = rootC1 * CFrame.new(0, prevModelSize.y/2, 0)
		rootWeld.Name = "RootWeld"
		rootWeld.Parent = BoundingBox
		scale = scale + DELTA_SCALE
		wait()
	end
	
	applyToModelParts(function(part) 
		part.Velocity = Vector3.new(0,0,0)
		part.RotVelocity = Vector3.new(0,0,0)
	 end, Treehouse)
end

-- Actual script:

BoundingBox.Touched:connect(function(Hit) --Fixed by Luckymaxer
	if not Hit or not Hit.Parent then
		return
	end
	local Character = Hit.Parent
	if Character:IsA("Tool") or Character:IsA("Hat") then
		Character = Character.Parent
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		return
	end
	if AlreadyGrew then
		HaltGrowing = true
	else
		LatestTouchedPart = Hit
	end
end)

function RemoveVelocity(Parent)
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") then
			v.Velocity = Vector3.new(0, 0, 0)
			v.RotVelocity = Vector3.new(0, 0, 0)
		end
		RemoveVelocity(v)
	end
end

while not AlreadyGrew do
	if LatestTouchedPart then 
		if (BoundingBox.Velocity - LatestTouchedPart.Velocity).magnitude < SLOW_SPEED then
			TicksWithoutMoving = TicksWithoutMoving + 1
		else
			TicksWithoutMoving = 0
		end
	else
		if BoundingBox.Velocity.magnitude < SLOW_SPEED then
			TicksWithoutMoving = TicksWithoutMoving + 1
		else
			TicksWithoutMoving = 0
		end
	end
	
	if TicksWithoutMoving >= TICKS_UNTIL_GROW_STARTS and LatestTouchedPart then
		applyToModelParts(function(part)
			part.Anchored = true
		end, Treehouse)
		Grow()
		RemakeWelds()
		applyToModelParts(function(part)
			part.Anchored = false
		end, Treehouse)
	end
	
	if Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player") then
		local Character = Creator.Value.Character
		if Character and Character.Parent then
			local Torso = Character:FindFirstChild("Torso")
			if Torso then
				if BodyGyro and BodyGyro.Parent then
					BodyGyro.cframe = CFrame.new(Treehouse:GetModelCFrame().p, Vector3.new(Torso.Position.X, Treehouse:GetModelCFrame().p.Y, Torso.Position.Z))
				end
			end
		end
	end
	
	wait(TICK_LENGTH)
end

RemoveVelocity(Treehouse)

BoundingBox = Treehouse:FindFirstChild("BoundingBox")
WeldToHouseMeshPart = BoundingBox:FindFirstChild("WeldToHouseMeshPart")
WeldToTreeMeshPart = BoundingBox:FindFirstChild("WeldToTreeMeshPart")
if not WeldToHouseMeshPart or not WeldToTreeMeshPart then
	if Remove and Remove.Parent then
		Remove.Value = true
	end
	return
end

for i, v in pairs({WeldToHouseMeshPart, WeldToTreeMeshPart}) do
	if v and v.Parent then
		v.Changed:connect(function()
			if not v.Parent or not v.Part0 or not v.Part0.Parent or not v.Part1 or not v.Part1.Parent then
				if Remove and Remove.Parent then
					Remove.Value = true
				end
			end
		end)
	end
end