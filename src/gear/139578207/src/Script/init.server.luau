--[[
	Fixed by ArceusInator 2/18/2015
	- Made it FE-compatible
	- No longer ignores forcefields
	- No longer damages teammates
	- No longer damages the user when you shoot something dangerous
--]]

-----------------
--| Constants |--
-----------------

local SHOT_SPEED = 100
local SHOT_TIME = 1

local NOZZLE_OFFSET = Vector3.new(0, 0.4, -1.1)

local DEBOUNCE_TAG_NAME = 'Busy'

local GLib = require(206209239)

-----------------
--| Variables |--
-----------------

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')

local FireSound = Handle:WaitForChild('Fire')
local ReloadSound = Handle:WaitForChild('Reload')
local HitFadeSound = script:WaitForChild('HitFade')

local PointLight = Handle:WaitForChild('PointLight')

local Character = nil
local Humanoid = nil
local Player = nil

local BaseShot = nil

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
	creatorTag.Value = Player
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats

	local iconTag = Instance.new('StringValue')
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	iconTag.Parent = creatorTag
	creatorTag.Parent = target
	DebrisService:AddItem(creatorTag, 4)
end

-- Returns all objects under instance with Transparency
local function GetTransparentsRecursive(instance, partsTable)
	local partsTable = partsTable or {}
	for _, child in pairs(instance:GetChildren()) do
		if child:IsA('BasePart') or child:IsA('Decal') then
			table.insert(partsTable, child)
		end
		GetTransparentsRecursive(child, partsTable)
	end
	return partsTable
end

local function SelectionBoxify(instance)
	local selectionBox = Instance.new('SelectionBox')
	selectionBox.Adornee = instance
	selectionBox.Color = BrickColor.new('Toothpaste')
	selectionBox.Parent = instance
	return selectionBox
end

local function Light(instance)
	local light = PointLight:Clone()
	light.Range = light.Range + 2
	light.Parent = instance
end

local function FadeOutObjects(objectsWithTransparency, fadeIncrement)
	repeat
		local lastObject = nil
		for _, object in pairs(objectsWithTransparency) do
			object.Transparency = object.Transparency + fadeIncrement
			lastObject = object
		end
		wait()
	until lastObject.Transparency >= 1 or not lastObject
end

local function Dematerialize(character, humanoid, firstPart)
	local debounceTag = Instance.new('Configuration')
	debounceTag.Name = DEBOUNCE_TAG_NAME
	debounceTag.Parent = character
	
	humanoid.WalkSpeed = 0

	local parts = {}
	for _, child in pairs(character:GetChildren()) do
		if child:IsA('BasePart') then
			child.Anchored = true
			table.insert(parts, child)
		elseif child:IsA('LocalScript') or child:IsA('Script') then
			child:Destroy()
		end
	end

	local selectionBoxes = {}

	local firstSelectionBox = SelectionBoxify(firstPart)
	Light(firstPart)
	wait(0.05)

	for _, part in pairs(parts) do
		if part ~= firstPart then
			table.insert(selectionBoxes, SelectionBoxify(part))
			Light(part)
		end
	end

	local objectsWithTransparency = GetTransparentsRecursive(character)
	FadeOutObjects(objectsWithTransparency, 0.1)

	wait(0.5)

	humanoid.Health = 0
	DebrisService:AddItem(character, 2)

	local fadeIncrement = 0.05
	Delay(0.2, function()
		FadeOutObjects({firstSelectionBox}, fadeIncrement)
		if character then
			character:Destroy()
		end
	end)
	FadeOutObjects(selectionBoxes, fadeIncrement)
end

local function OnTouched(shot, otherPart)
	local character, humanoid = FindCharacterAncestor(otherPart)
	if character and humanoid and character ~= Character and not character:FindFirstChild(DEBOUNCE_TAG_NAME) and not character:FindFirstChild'ForceField' then
		local isTeammate = GLib.IsTeammate(GLib.GetPlayerFromPart(Tool), GLib.GetPlayerFromPart(Character))
		
		if not isTeammate then
			ApplyTags(humanoid)
			if shot then
				local hitFadeSound = shot:FindFirstChild(HitFadeSound.Name)
				if hitFadeSound then
					hitFadeSound.Parent = humanoid.Torso
					hitFadeSound:Play()
				end
				shot:Destroy()
			end
			Dematerialize(character, humanoid, otherPart)
		end
	end
end

local function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:WaitForChild('Humanoid')
	Player = PlayersService:GetPlayerFromCharacter(Character)
end

local function OnActivated(hit)
	if Tool.Enabled and Humanoid.Health > 0 then
		Tool.Enabled = false

		for i = 1, 3 do
			FireSound:Play()
	
			local handleCFrame = Handle.CFrame
			local firingPoint = handleCFrame.p + handleCFrame:vectorToWorldSpace(NOZZLE_OFFSET)
			local shotCFrame = CFrame.new(firingPoint, hit)
	
			local laserShotClone = BaseShot:Clone()
			laserShotClone.CFrame = shotCFrame + (shotCFrame.lookVector * (BaseShot.Size.Z / 2))
			local bodyVelocity = Instance.new('BodyVelocity')
			bodyVelocity.velocity = shotCFrame.lookVector * SHOT_SPEED
			bodyVelocity.Parent = laserShotClone
			laserShotClone.Touched:connect(function(otherPart)
				OnTouched(laserShotClone, otherPart)
			end)
			DebrisService:AddItem(laserShotClone, SHOT_TIME)
			laserShotClone.Parent = workspace
	
			wait(0.15)
		end
		wait(0.6) -- FireSound length

		ReloadSound:Play()
		wait(0.75) -- ReloadSound length

		Tool.Enabled = true
	end
end

local function OnUnequipped()
	
end

--------------------
--| Script Logic |--
--------------------

BaseShot = Instance.new('Part')
BaseShot.Name = 'Effect'
BaseShot.FormFactor = Enum.FormFactor.Custom
BaseShot.Size = Vector3.new(0.2, 0.2, 3)
BaseShot.CanCollide = false
BaseShot.BrickColor = BrickColor.new('Toothpaste')
SelectionBoxify(BaseShot)
Light(BaseShot)
HitFadeSound:Clone().Parent = BaseShot

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Click.OnServerEvent:connect(function(client, hit)
	if client.Character == Tool.Parent then
		OnActivated(hit)
	end
end)
