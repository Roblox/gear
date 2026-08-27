-----------------
--| Constants |--
-----------------

--NOTE: These must be the names of animation objects under this script
local ANIMATION_NAMES = {
	'BeginSmash',
	'EndSmash'
}

-----------------
--| Variables |--
-----------------

local Tool = script.Parent

local Animations = {}
local AnimTracks = {}

local Character = nil
local Humanoid = nil

-----------------
--| Functions |--
-----------------

local function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:WaitForChild('Humanoid')

	-- Load all the Animations into AnimationTracks
	for animationName, animation in pairs(Animations) do
		AnimTracks[animationName] = Humanoid:LoadAnimation(animation)
	end
end

local function OnChanged(property)
	if property == 'Enabled' and Tool.Enabled == false then
		AnimTracks['BeginSmash']:Play()
		wait(1)
		if Tool.Parent == Character then
			AnimTracks['BeginSmash']:Stop()
			AnimTracks['EndSmash']:Play()

			wait(1)
			AnimTracks['EndSmash']:Stop()
		end
	end
end

-- When unequipped, stop all animations
local function OnUnequipped()
	for _, animTrack in pairs(AnimTracks) do
		animTrack:Stop()
	end
	AnimTracks = {}
end

--------------------
--| Script Logic |--
--------------------

-- First, get the animations
for _, animationName in pairs(ANIMATION_NAMES) do
	local animation = script:WaitForChild(animationName)
	if animation:IsA('Animation') then
		Animations[animationName] = animation
	end
end

Tool.Equipped:connect(OnEquipped)
Tool.Changed:connect(OnChanged)
Tool.Unequipped:connect(OnUnequipped)
