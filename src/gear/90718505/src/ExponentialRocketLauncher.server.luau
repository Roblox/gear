--[[
	Fixed by ArceusInator
	1/22/2015 Made it actually work, made it compatible with FE
--]]

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

------------------------------
--| Customizable Variables |--
------------------------------

local Cooldown = 3 -- Seconds until tool can be used again
local RocketSpeed = 75 -- Speed of the first rocket

-----------------------
--| Other Variables |--
-----------------------

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local Tool = script.Parent
local ToolHandle = Tool.Handle
local MotherRocket = WaitForChild(ToolHandle, 'MotherRocket')
local ChildRocket = WaitForChild(MotherRocket, 'ChildRocket')
local FirstRocketScript = WaitForChild(ToolHandle, 'FirstRocket')
local CreatorTag = WaitForChild(ToolHandle, 'creator')
local IconTag = WaitForChild(CreatorTag, 'icon')

local MyModel = nil
local MyPlayer = nil

-----------------------
--| Local Functions |--
-----------------------

local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
	CreatorTag.Value = MyPlayer
end

local function OnActivated(client, hit)
	if client.Character ~= Tool.Parent then return end
	if not Tool.Enabled or not MyModel or not MyModel:FindFirstChild('Humanoid') then return end
	Tool.Enabled = false

	-- Clone the rocket part
	local rocket = MotherRocket:Clone()
	MotherRocket.Transparency = 1
	DebrisService:AddItem(rocket, 30)
	rocket.Name = "Rocket"

	-- Add the tag
	local tagClone = CreatorTag:Clone()
	tagClone.Parent = rocket

	-- Add fire
	local fire = Instance.new('Fire', rocket)
	fire.Heat = 5
	fire.Size = 2

	-- Add antigravity
	local bodyForce = Instance.new('BodyForce', rocket)
	bodyForce.Name = 'Antigravity'
	bodyForce.force = Vector3.new(0, (MotherRocket:GetMass() + ChildRocket:GetMass()) * workspace.Gravity, 0)

	-- Arm the rocket with the FirstRocket script
	local firstScriptClone = FirstRocketScript:Clone()
	firstScriptClone.Parent = rocket
	firstScriptClone.Disabled = false

	-- Position the whole setup
	rocket.PermaWeld.MotherToHandle:Destroy()
	rocket.CFrame = CFrame.new(rocket.CFrame.p, hit.p) --NOTE: This must be set before assigning Parent
	rocket.Parent = Workspace

	-- Add sound
	if ToolHandle:FindFirstChild('Swoosh') then
		local swooshClone = ToolHandle.Swoosh:Clone()
		swooshClone.Parent = rocket
		wait(0)
		if swooshClone then swooshClone:Play() end
	end

	-- Launch!
	rocket.Velocity = rocket.CFrame.lookVector * RocketSpeed
	rocket.RotVelocity = Vector3.new(0, 0, 0)

	wait(Cooldown)

	MotherRocket.Transparency = 0
	Tool.Enabled = true
end

--------------------
--| Script Logic |--
--------------------

IconTag.Value = Tool.TextureId

Tool.Equipped:connect(OnEquipped)
--Tool.Activated:connect(OnActivated)
Tool.ClickyClick.OnServerEvent:connect(OnActivated)