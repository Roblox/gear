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
local ButtonPressAni = WaitForChild(Tool, 'ButtonPress')
local ThrowAni = WaitForChild(Tool, 'Toss')


local MyModel = nil
local MyPlayer = nil
local MyHumanoid = nil
local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
	MyHumanoid = WaitForChild(MyModel,'Humanoid')
end

local function OnActivated()
	if not MyModel or not MyModel:FindFirstChild('Humanoid') or not Tool.Enabled then return end
	Tool.Enabled = false
	
	local anitrack = MyHumanoid:LoadAnimation(ButtonPressAni)
	anitrack:Play()
	wait(1.6)
	wait(1.1)
	
	anitrack = MyHumanoid:LoadAnimation(ThrowAni)
	anitrack:Play()
	wait(.5)
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
	local nangular = Instance.new('BodyAngularVelocity')
	nangular.maxTorque = Vector3.new(0,math.huge,0)
	nangular.angularvelocity = Vector3.new(0,15,0)
	nangular.Parent = handleClone
	local nsparkles = Instance.new('Sparkles')
	nsparkles.SparkleColor = Color3.new(0,.7,0)
	nsparkles.Parent = handleClone
	local selfDestructScript = handleClone:FindFirstChild('SelfDestruct')
	if selfDestructScript and selfDestructScript:FindFirstChild('TimeToLive') then
		selfDestructScript.TimeToLive.Value = TIME_TO_LIVE
		selfDestructScript.Disabled = false
	end
	local foodScript = handleClone:FindFirstChild('PoisonedFood')
	if foodScript then
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
