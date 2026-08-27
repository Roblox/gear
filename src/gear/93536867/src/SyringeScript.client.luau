-- Made By SolarCrane

-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-- This may be less typing if we made this a table index by their part names
local TORSO_MESH_ID = "http://www.roblox.com/asset/?id=37683263"
local LEFT_ARM_MESH_ID = "http://www.roblox.com/asset/?id=37683097"
local RIGHT_ARM_MESH_ID = "http://www.roblox.com/asset/?id=37683174"
local LEFT_LEG_MESH_ID = "http://www.roblox.com/asset/?id=37683150"
local RIGHT_LEG_MESH_ID = "http://www.roblox.com/asset/?id=37683227"

local MESHES = {["Torso"] = 64084303, ["Left Arm"] = 63252751, ["Right Arm"] = 63252810, ["Left Leg"] = 63252779, ["Right Leg"] = 63252837}
local TEXTURES = {["Torso"] = 63253121, ["Left Arm"] = 63253121, ["Right Arm"] = 63253121, ["Left Leg"] = 63253121, ["Right Leg"] = 63253121}

local INJECT_DAMAGE = 15

local Tool = script.Parent
local Handle = WaitForChild(Tool, "Handle")

local MyHumanoid
local MyCharacter 

local PlayersService = Game:GetService('Players')

local InjectTrack
local EnrageTrack

local InjectSound
local EnrageSound
local SwooshSound

local Hammer

local HammerC = Game:GetService('InsertService'):LoadAsset(93652837):GetChildren()[1]

local function DeleteExistingMeshes(part)
	for _, v in pairs(part:GetChildren()) do
		if v:IsA('FileMesh') or v:IsA('CylinderMesh') or v:IsA('BlockMesh') or v:IsA('CharacterMesh') then
			v:Destroy()
		end
	end
end

local function ParseBodyPartEnum(bodyPartName)
	local result = Enum.BodyPart.Head
	if bodyPartName == "Left Arm" then
		result = Enum.BodyPart.LeftArm
	elseif bodyPartName == "Right Arm" then
		result = Enum.BodyPart.RightArm
	elseif bodyPartName == "Left Leg" then
		result = Enum.BodyPart.LeftLeg
	elseif bodyPartName == "Right Leg" then
		result = Enum.BodyPart.RightLeg
	elseif bodyPartName == "Torso" then
		result = Enum.BodyPart.Torso
	end
	return result
end

local function CreateCharacterMesh(meshId, textureId, bodyPartName)
	local mesh = Instance.new('CharacterMesh')
	mesh.MeshId = meshId
	mesh.OverlayTextureId = textureId
	mesh.BodyPart = ParseBodyPartEnum(bodyPartName)
	return mesh
end

local function CreateSpecialMesh(meshId, textureId)
	if not meshId then return end
	local mesh = Instance.new('SpecialMesh')
	mesh.MeshId = "http://www.roblox.com/asset/?id=" .. meshId
	mesh.TextureId = "http://www.roblox.com/asset/?id=" .. textureId
	return mesh
end

local function DressCharacter(character)
	if not character then return end
	if character:FindFirstChild('WasDressedZombieHealer') then print('Already dressed up.') return end
	local wasDressed = Instance.new('BoolValue')
	wasDressed.Value = true
	wasDressed.Name = 'WasDressedZombieHealer'
	wasDressed.Parent = character
	DeleteExistingMeshes(character)
	for partName, meshId in pairs(MESHES) do
		if character:FindFirstChild(partName) and TEXTURES[partName] then
			DeleteExistingMeshes(character:FindFirstChild(partName))
			CreateSpecialMesh(meshId, TEXTURES[partName]).Parent = character:FindFirstChild(partName)
			CreateCharacterMesh(meshId, TEXTURES[partName], partName).Parent = character
		end
	end
end


-------------------------------- AWESOME CODE EXCEPT FROM HOTTHOTH COMMANDS; MORE TO COME -------------------------

local foundObjectList = {}
local foundObjectIndex = 1
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
			-- make sure not to resize tools, things tend to get complicated if we do
			if not (pcall(modelChildren[i].IsA, modelChildren[i], 'Tool') and modelChildren[i]:IsA('Tool')) then
				findObjectHelper(modelChildren[i], objectName, className, listOfFoundObjects)
			end
		end
	end
end

local function resizeModelInternal(model, resizeFactor)
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
		-- This is a nasty hack because head meshes scale relative to the part's size
		-- thus scaling the mesh and the head gives u 2x the size
		if mesh.Parent.Name ~= "Head" then
			mesh.Scale = mesh.Scale * resizeFactor
		end
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
		basePart.Size = basePart.Size * resizeFactor
		local oldCFrame = basePartCFrames[basePart]
		local oldPositionInModel = modelCFrame:pointToObjectSpace(oldCFrame.p)
		local distanceFromCorner = oldPositionInModel + modelSize/2
		distanceFromCorner = distanceFromCorner * resizeFactor

		local newPositionInSpace = modelCFrame:pointToWorldSpace(distanceFromCorner - modelSize/2)
		basePart.CFrame = oldCFrame - oldCFrame.p + newPositionInSpace
	end

	-- pop the joints back, because they prolly got borked
	for _, joint in pairs(joints) do
		joint.Parent = jointParents[joint]
	end

	return model
end

local function resizeImplementation(modelList, resizeFactor)
	if type(modelList) ~= "table" then modelList = {modelList} end

	for _, model in pairs(modelList) do
		--if model.Name ~= "BackPack" then
			resizeModelInternal(model, resizeFactor)
		--end
	end
	return modelList
end

------------------------------------------------------------------------------------------------------------------
local attacking = false
local HitCharacters = {}

function Blow(hit)
	if not attacking then return end
	if hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') and hit.Parent ~= MyCharacter then
		if HitCharacters[hit.Parent] then return end
		HitCharacters[hit.Parent] = true
		hit.Parent.Humanoid:TakeDamage(INJECT_DAMAGE)
		if InjectSound then
			InjectSound:Play()
		end
		wait(0.2)
		if EnrageTrack then
			EnrageTrack:Play()
		end
		Delay(0.2, (function() if EnrageSound then EnrageSound:Play() end end))
		
		local character = PlayersService.localPlayer.Character
		if character:FindFirstChild('WasDressedZombieHealer') then
			print('Already dressed up.')
			wait(0.1)
		else
			DressCharacter(character)
			--for i = 1, 10 do
				resizeImplementation(character, 1.42)
				wait(0.03)
			--	end
		end
		if not character:FindFirstChild('Hammer') and not PlayersService:GetPlayerFromCharacter(character).Backpack:FindFirstChild('Hammer') then
			MyHumanoid:UnequipTools() 
			HammerC:Clone().Parent = character
		end
	end
end


function OnActivate()
	if (MyHumanoid and MyHumanoid.Health <= 0) or attacking then return end
	attacking = true
	HitCharacters = {}
	if InjectTrack then
		InjectTrack:Play()
	end
	wait(0.5)
	if SwooshSound then
		SwooshSound:Play()
	end
	wait(0.2)
	attacking = false
end

local Equipping = false

function OnEquipped( mouse )
	if Equipping then return end
	Equipping = true
	MyCharacter = Tool.Parent
	MyHumanoid = WaitForChild(Tool.Parent, 'Humanoid')
	InjectTrack = MyHumanoid:LoadAnimation(WaitForChild(Tool, 'Inject'))
	EnrageTrack = MyHumanoid:LoadAnimation(WaitForChild(Tool, 'Enrage'))
	InjectSound = WaitForChild(Handle, 'Absorb')
	EnrageSound = WaitForChild(Handle, 'Rage')
	SwooshSound = WaitForChild(Handle, 'Swoosh')
	Handle.Touched:connect(Blow)
	if not Hammer then
		wait(0.1)
		Hammer = Game:GetService('InsertService'):LoadAsset(93652837):GetChildren()[1]
	end
	print('Equip done')
	Equipping = false
end

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivate)
