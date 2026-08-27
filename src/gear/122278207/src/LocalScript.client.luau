local Tool = script.Parent
local Character

local Anims = {}
local EQUIP_ANIM_LENGTH = 1

local OriginalOutfit = {}
local OriginalHeadMesh = nil
local OriginalDecalParents = {}
local NewAssets = {}

local Handle = Tool:WaitForChild('Handle')
local Sparkles = Handle:WaitForChild('Sparkles')
local Riff = nil

-- Morph constants
local LEFT_LEG_ID = 81727815
local RIGHT_LEG_ID = 81727872
local LEFT_ARM_ID = 81727774
local RIGHT_ARM_ID = 81727718
local TORSO_ID = 81727651
local HAT_ID = 11721339
local FACE_ID = 13038375
local HEAD_MESH_ID = 6340269

local CHARACTER_CHILDREN_IDS = {LEFT_LEG_ID, RIGHT_LEG_ID, 
		LEFT_ARM_ID, RIGHT_ARM_ID, TORSO_ID, HAT_ID}

local InsertService = game:GetService('InsertService')


---------------
-- Utilities --
---------------
local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid.ClassName == 'Humanoid' then
			local unloadedAnim = Tool:FindFirstChild(animationName)
			if unloadedAnim then
				Anims[animationName] = humanoid:LoadAnimation(unloadedAnim)
			end
		end
	end
	if Anims[animationName] then
		Anims[animationName]:Play()
	end
end

local function Stop(animationName)
	if Anims[animationName] then 
		Anims[animationName]:Stop()
	end
end

local function ApplyToModelDecals(func, model, ...)
	for _, child in pairs(model:GetChildren()) do
		if child:IsA('Decal') then
			func(child, ...)
		elseif child:IsA('Model') or child:IsA('BasePart') then
			ApplyToModelDecals(func, child, ...)
		end
	end
end

local function GetAsset(assetID)
	local newAsset = InsertService:LoadAsset(assetID):GetChildren()[1]
	print(tostring(newAsset))
	table.insert(NewAssets, newAsset)
	return newAsset
end

-------------------
-- Other Helpers --
-------------------

local function Punkify()
	Spawn(function()
		Character = Tool.Parent
		if Character and Character:FindFirstChild('Humanoid') and not Character:FindFirstChild('PunkBraceletUserIsMidPunkify') then
			-- Add tag
			local tag = Instance.new('BoolValue')
			tag.Name = 'PunkBraceletUserIsMidPunkify'
			tag.Parent = Character
			
			-- Get rid of existing outfit
			for _, child in pairs(Character:GetChildren()) do
				if child:IsA('Accoutrement') or child:IsA('CharacterMesh') then
					child.Parent = nil
					table.insert(OriginalOutfit, child)
				end
			end
			-- ... and add in new one.
			for _, assetID in pairs(CHARACTER_CHILDREN_IDS) do
				GetAsset(assetID).Parent = Character
			end
			
			-- Make existing decals (e.g. face) transparent
			ApplyToModelDecals(function(decal) 
				OriginalDecalParents[decal] = decal.Parent
				decal.Parent = nil
			end, Character)
			
			-- Get rid of existing head mesh and add in new one
			-- Also add new face
			local head = Character:FindFirstChild('Head')
			if head then
				local headMesh = head:FindFirstChild('Mesh')
				if headMesh then
					headMesh.Parent = nil
					OriginalHeadMesh = headMesh
				end
				GetAsset(HEAD_MESH_ID).Parent = head
				GetAsset(FACE_ID).Parent = head
			end
		end
	end)
end

local function Unpunkify()
	Spawn(function()
		if Character then
			local tag = Character:FindFirstChild('PunkBraceletUserIsMidPunkify')
			if tag then			
				for _, newAsset in pairs(NewAssets) do
					newAsset:Destroy()
				end
				
				for _, outfitPiece in pairs(OriginalOutfit) do
					outfitPiece.Parent = Character
				end
				
				local head = Character:FindFirstChild('Head')
				if head and OriginalHeadMesh then OriginalHeadMesh.Parent = head end
				
				for decal, parent in pairs(OriginalDecalParents) do
					decal.Parent = parent
				end
	
				tag:Destroy()
			end
		end
	end)
end

------------------------
-- Attached Functions --
------------------------

function OnEquipped()
	if Riff then Riff:Stop() end
	Sparkles.Enabled = false
	Stop('HeadbangAnim')
	Stop('EquipAnim')	
	
	Play('EquipAnim')
	wait(EQUIP_ANIM_LENGTH)
	if Tool.Parent:FindFirstChild('Humanoid') then
		Riff = Handle:FindFirstChild('Riff')
		if Riff then Riff:Play() end
		Sparkles.Enabled = true
		Play('HeadbangAnim')
		Punkify()
	end
end

function OnUnequipped()
	Unpunkify()
	if Riff then Riff:Stop() end
	Sparkles.Enabled = false
	Stop('HeadbangAnim')
	Stop('EquipAnim')
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
