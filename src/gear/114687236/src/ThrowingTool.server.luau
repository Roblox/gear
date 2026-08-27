local COOLDOWN = 0.75 -- Seconds until another can be thrown
local TIME_TO_LIVE = 10 -- Seconds until each old one is destroyed
local THROW_SPEED = 100

local PlayersService = game:GetService('Players')
local DebrisService = game:GetService('Debris')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local ThrowSound = ToolHandle:WaitForChild("Throw")

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
	handleClone.Parent = workspace
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
