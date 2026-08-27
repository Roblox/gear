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

local FireAndReloadAnimation = WaitForChild(script, 'FireAndReload')

local FireAndReloadTrack = nil

-----------------
--| Functions |--
-----------------

local function OnEquipped()
	local myModel = Tool.Parent
	local humanoid = myModel:FindFirstChild('Humanoid')
	if humanoid then -- Preload animations
		FireAndReloadTrack = humanoid:LoadAnimation(FireAndReloadAnimation)
	end
end

local function OnChanged(property)
	if property == 'Enabled' and Tool.Enabled == false then
		-- Play fire and reload animation
		if FireAndReloadTrack then
			FireAndReloadTrack:Play()
		end
	end
end

local function OnUnequipped()
	-- Stop animations
	if FireAndReloadTrack then FireAndReloadTrack:Stop() end
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Changed:connect(OnChanged)
Tool.Unequipped:connect(OnUnequipped)
