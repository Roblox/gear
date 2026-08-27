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

local Tool = script.Parent

local ScytheEquipAnimation = WaitForChild(script, 'ScytheEquip2')
local ScytheIdleAnimation = WaitForChild(script, 'ScytheIdle2')
local ScytheSlashAnimation = WaitForChild(script, 'ScytheSlash')

local ScytheEquipTrack = nil
local ScytheIdleTrack = nil
local ScytheSlashTrack = nil

-----------------
--| Functions |--
-----------------

local function OnEquipped()
	local myModel = Tool.Parent
	local humanoid = myModel:FindFirstChild('Humanoid')
	if humanoid then -- Preload animations
		ScytheEquipTrack = humanoid:LoadAnimation(ScytheEquipAnimation)
		if ScytheEquipTrack then ScytheEquipTrack:Play() end

		ScytheIdleTrack = humanoid:LoadAnimation(ScytheIdleAnimation)
		if ScytheIdleTrack then ScytheIdleTrack:Play() end

		ScytheSlashTrack = humanoid:LoadAnimation(ScytheSlashAnimation)
	end
end

local function OnChanged(property)
	if property == 'Enabled' and Tool.Enabled == false then
		if ScytheSlashTrack then ScytheSlashTrack:Play() end
	end
end

local function OnUnequipped()
	-- Stop all animations
	if ScytheEquipTrack then ScytheEquipTrack:Stop() end
	if ScytheIdleTrack then ScytheIdleTrack:Stop() end
	if ScytheSlashTrack then ScytheSlashTrack:Stop() end
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Changed:connect(OnChanged)
Tool.Unequipped:connect(OnUnequipped)
