-----------------
--| Constants |--
-----------------

local COOLDOWN = 30

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
local ToolHandle = Tool.Handle

local DisruptorScript = WaitForChild(script, 'DisruptorScript')

local ReleaseAnimation = WaitForChild(script, 'Release')

local ChargeSound = WaitForChild(ToolHandle, 'Charge')

local MyModel = nil
local MyHumanoid = nil

local BaseDevice = nil

local ReleaseTrack = nil

local OriginalWalkSpeed = 0

local StillEquipped = false

-----------------
--| Functions |--
-----------------

local function MakeBaseDevice()
	local baseDevice = ToolHandle:Clone()
	baseDevice.Name = 'Effect'
	baseDevice.FormFactor = Enum.FormFactor.Custom
	baseDevice.Size = Vector3.new() -- As small as possible
	baseDevice.Anchored = true

	local childScriptClone = DisruptorScript:Clone()
	childScriptClone.Parent = baseDevice
	childScriptClone.Disabled = false

	return baseDevice
end

local function Freeze()
	if MyHumanoid and MyHumanoid.Torso then
		MyHumanoid.WalkSpeed = 0
	end
end

local function UnFreeze()
	if MyHumanoid and MyHumanoid.Torso then
		MyHumanoid.WalkSpeed = OriginalWalkSpeed
	end
end

local function OnEquipped()
	MyModel = Tool.Parent
	MyHumanoid = MyModel:FindFirstChild('Humanoid')

	OriginalWalkSpeed = MyHumanoid.WalkSpeed

	-- Preload animation
	ReleaseTrack = MyHumanoid:LoadAnimation(ReleaseAnimation)

	StillEquipped = true
end

local function OnActivated()
	if Tool.Enabled and MyModel and MyHumanoid and MyHumanoid.Torso and MyHumanoid.Health > 0 then
		Tool.Enabled = false

		if ReleaseTrack then
			ReleaseTrack:Play()
		end

		Freeze()

		ChargeSound:Play()

		wait(1.4) -- Wait for animation to get to release part

		if StillEquipped then
			ToolHandle.Transparency = 1
			local cloneDevice = BaseDevice:Clone()
			cloneDevice.CFrame = ToolHandle.CFrame
			cloneDevice.Parent = Workspace

			wait(1.6) -- Wait for animation to finish

			UnFreeze()

			wait(COOLDOWN)

			ToolHandle.Transparency = 0
		end

		Tool.Enabled = true
	end
end

local function OnUnequipped()
	StillEquipped = false

	UnFreeze()
	ToolHandle.Transparency = 0

	-- Stop all animations
	if ReleaseTrack then ReleaseTrack:Stop() end
end

--------------------
--| Script Logic |--
--------------------

BaseDevice = MakeBaseDevice()

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)
