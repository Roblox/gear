local COOLDOWN = 0.75 -- Seconds until another can be thrown
local TIME_TO_LIVE = 10 -- Seconds until each old one is destroyed
local THROW_SPEED = 100

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local ThrowSound = WaitForChild(ToolHandle, 'Throw')

--[[
-- {PoisonApple, PoisonCake, PoisonPorkChop}
local BaseIdUrl = 'http://www.roblox.com/asset/?id='
local IconIds = {'87862872', '87863072', '87871704'}
local MeshIds = {'87862943', '87863104', '87863169'}
local TextureIds = {'87862921', '87863090', '87863148'}
local HandleSizes = {Vector3.new(1.2, 1.2, 1.2), Vector3.new(1.08, 1.11, 1.14), Vector3.new(0.45, 1.82, 1.33)}
--]]

local MyModel = nil
local MyPlayer = nil

local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
end

local function OnActivated()
	if not MyModel or not MyModel:FindFirstChild('Humanoid') or not Tool.Enabled then return end
	Tool.Enabled = false
	ToolHandle.Transparency = 1

	ThrowSound:Play()

	local handleClone = ToolHandle:Clone()
	DebrisService:AddItem(handleClone, 30)
	handleClone.Velocity = (MyModel.Humanoid.TargetPoint - ToolHandle.CFrame.p).unit * THROW_SPEED
	handleClone.Name = 'Food'
	handleClone.Parent = Workspace
	handleClone.Transparency = 0
	handleClone.CanCollide = true
	Instance.new('BodyGyro', handleClone) -- Keeps it upright
	local selfDestructScript = handleClone:FindFirstChild('SelfDestruct')
	if selfDestructScript and selfDestructScript:FindFirstChild('TimeToLive') then
		selfDestructScript.TimeToLive.Value = TIME_TO_LIVE
		selfDestructScript.Disabled = false
	end
	local foodScript = handleClone:FindFirstChild('PoisonedFood')
	if foodScript then
		local creator = Instance.new('ObjectValue', foodScript)
		creator.Name = 'Creator'
		creator.Value = MyPlayer
		foodScript.Disabled = false
	end

	--[[ Load new item (while we wait)
	local index = math.random(3)
	ToolHandle.Mesh.MeshId = BaseIdUrl .. MeshIds[index]
	ToolHandle.Mesh.TextureId = BaseIdUrl .. TextureIds[index]
	ToolHandle.Size = HandleSizes[index] -- This breaks the weld
	MyWeld.Parent = Game.JointsService -- Fix the weld
	Tool.TextureId = BaseIdUrl .. IconIds[index] -- Change the tool icon
	--]]

	wait(COOLDOWN)

	ToolHandle.Transparency = 0
	Tool.Enabled = true
end

local function OnUnequipped()
	ToolHandle.Transparency = 0
end

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)
