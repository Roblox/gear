-----------------
--| Constants |--
-----------------

local DAMAGE = 55
local DAMAGE_TIME = 0.5
local COOLDOWN = 1

local HAT_ID = 36883367
local BODY_MESH_IDS = {36780113, 36780032, 36780156, 36780079, 36780195}
local BODY_TEXTURE_ID = 36780292

local BODY_PART_ENUM = { -- :[
	['Head'] = Enum.BodyPart.Head,
	['Torso'] = Enum.BodyPart.Torso,
	['Left Arm'] = Enum.BodyPart.LeftArm,
	['Right Arm'] = Enum.BodyPart.RightArm,
	['Left Leg'] = Enum.BodyPart.LeftLeg,
	['Right Leg'] = Enum.BodyPart.RightLeg
}

-----------------
--| Variables |--
-----------------

local PlayersService = Game:GetService('Players')
local InsertService = Game:GetService('InsertService')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local ToolHandle = Tool:WaitForChild('Handle')

local SlashAnimation = script:WaitForChild('SlashAnimation')
local SlashSound = ToolHandle:WaitForChild('SlashSound')

local Hat = InsertService:LoadAsset(HAT_ID):GetChildren()[1]

local MyCharacter = nil
local MyHumanoid = nil
local SlashAnimTrack = nil

local HitList = {} -- Used for debounce

-----------------
--| Functions |--
-----------------

-- Returns a character ancestor and its Humanoid, or nil
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

-- Removes any old creator tags and applies new ones to the specified target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end

	local creatorTag = Instance.new('ObjectValue')
	creatorTag.Value = MyPlayer
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats

	local iconTag = Instance.new('StringValue')
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	iconTag.Parent = creatorTag
	creatorTag.Parent = target
	DebrisService:AddItem(creatorTag, 4)
end

local function ChangeLimb(character, limb)
	if Hat and limb.Name == 'Head' and not limb:FindFirstChild('Swapped') then
		Instance.new('BoolValue', limb).Name = 'Swapped'
		limb.Transparency = 0.99 -- Skeleton-specific
		while limb:FindFirstChild('HeadWeld') do
			limb.HeadWeld:Destroy()
		end
		Spawn(function()
			local hatClone = Hat:Clone()
			local hatHandle = hatClone:WaitForChild('Handle')
			hatHandle.CFrame = limb.CFrame
			hatClone.Parent = character
		end)
	else
		local targetBodyPart = BODY_PART_ENUM[limb.Name]
		if targetBodyPart then
			local characterMesh = nil
			for _, child in pairs(character:GetChildren()) do
				if child:IsA('CharacterMesh') and child.BodyPart == targetBodyPart then
					characterMesh = child
				end
			end
			if not characterMesh then
				characterMesh = Instance.new('CharacterMesh')
				characterMesh.BodyPart = targetBodyPart
			end
			characterMesh.MeshId = BODY_MESH_IDS[targetBodyPart.Value]
			characterMesh.OverlayTextureId = BODY_TEXTURE_ID
			characterMesh.Parent = character
		end
	end
end

local function OnTouched(otherPart)
	local character, humanoid = FindCharacterAncestor(otherPart)
	if character and humanoid then
		ChangeLimb(character, otherPart)
		if not HitList[character] then
			HitList[character] = true
			ApplyTags(humanoid)
			humanoid:TakeDamage(DAMAGE)
		end
	end
end

local function OnEquipped()
	MyCharacter = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = MyCharacter:WaitForChild('Humanoid')
	SlashAnimTrack = MyHumanoid:LoadAnimation(SlashAnimation)
	MyHumanoid.WalkSpeed = 20
end

local function OnActivated()
	if Tool.Enabled and MyHumanoid and MyHumanoid.Health > 0 then
		Tool.Enabled = false

		HitList = {}
		local connection = ToolHandle.Touched:connect(OnTouched)

		if SlashAnimTrack then
			SlashAnimTrack:Play()
		end

		SlashSound:Play()

		wait(DAMAGE_TIME)

		connection:disconnect()

		wait(COOLDOWN - DAMAGE_TIME)

		Tool.Enabled = true
	end
end

local function OnUnequipped()
	MyHumanoid.WalkSpeed = 16
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)
