-----------------
--| Constants |--
-----------------

local HAT_ID = 36883367
local BODY_MESH_IDS = {36780113, 36780032, 36780156, 36780079, 36780195}
local BODY_TEXTURE_ID = 36780292

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local InsertService = Game:GetService('InsertService')
local DebrisService = Game:GetService('Debris')

local Ball = script.Parent

local CreatorTag = WaitForChild(Ball, 'creator')
local Fire = WaitForChild(Ball, 'Fire')

local Connection = nil

-----------------
--| Functions |--
-----------------

-- Returns the ancestor that contains a Humanoid, if it exists
local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

-- Removes any old creator tags and applies the new one to target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end
	local creatorTagClone = CreatorTag:Clone()
	creatorTagClone.Parent = target
	DebrisService:AddItem(creatorTagClone, 1.5)
end

-- Turns the character into a Skeleton!
local function Skeletonify(character)
	InsertService:LoadAsset(HAT_ID):GetChildren()[1].Parent = character
	for i, meshId in ipairs(BODY_MESH_IDS) do
		local characterMesh = Instance.new('CharacterMesh')
		characterMesh.BodyPart = i
		characterMesh.MeshId = meshId
		characterMesh.OverlayTextureId = BODY_TEXTURE_ID
		characterMesh.Parent = character
	end
end

-- Sets the character ablaze!
local function Ignite(character, fire)
	fire = fire or Instance.new('Fire')
	for _, child in pairs(character:GetChildren()) do
		if child:IsA('BasePart') then
			fire:Clone().Parent = child
		end
	end
end

-- When the ball touches an enemy, turn them into a dead skeleton
local function OnTouched(otherPart)
	if otherPart and otherPart.Name ~= Ball.Name then
		local character, humanoid = FindCharacterAncestor(otherPart.Parent)
		if character and humanoid and humanoid.Health > 0 then
			local myPlayer = CreatorTag.Value
			if character ~= myPlayer.Character and not (character:FindFirstChild('creator') and character.creator.Value ~= myPlayer) and not character:FindFirstChild'ForceField' then
				-- (Only do the following if the character isn't myPlayer and they haven't already been converted)
				ApplyTags(humanoid)
				Skeletonify(character)
				Ignite(character, Fire)
				character:BreakJoints()
				Ball:Destroy()
			end
		end
	end
end

--------------------
--| Script Logic |--
--------------------

Ball.Touched:connect(OnTouched)
