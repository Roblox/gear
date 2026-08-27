----------------------
--| Tool Variables |--
----------------------
local Tool = script.Parent
Tool.Enabled = true
local IsCheckValue = Tool:WaitForChild('IsCheck')
local Mouse = nil

----------------------
--|   Constants    |--
----------------------
local SWING_TIME = 0.85
local CHECK_TIME = 0.5
local CHECK_SPEED = 50

----------------------
--|   Animations   |--
----------------------
local IdleAnim = Tool:WaitForChild('Idle')
local IdleTrack = nil
local SwingAnim = Tool:WaitForChild('Swing')
local SwingTrack = nil
local CheckAnim = Tool:WaitForChild('Check')
local CheckTrack = nil

----------------------
--|Helper Functions|--
----------------------
local function doCheck(torso)
	local bodyVelocity = Instance.new('BodyVelocity')
	bodyVelocity.Name = 'CheckVelocity'
	bodyVelocity.maxForce = Vector3.new(40000, 0, 40000) --Fix implemented by Luckymaxer
	bodyVelocity.velocity = torso.CFrame.lookVector * CHECK_SPEED
	bodyVelocity.Parent = torso
end

----------------------
--|     Events     |--
----------------------
local function onMouse1Down()
	if not Tool.Enabled then return end
	
	Tool.Enabled = not Tool.Enabled
	
	local character = Tool.Parent
	local humanoid = character:FindFirstChild('Humanoid')
	if humanoid and humanoid.Health > 0 then
		SwingTrack = humanoid:LoadAnimation(SwingAnim)
		if SwingTrack then SwingTrack:Play() end
		wait(SWING_TIME)
		if SwingTrack then SwingTrack:Stop() end
	end
	
	Tool.Enabled = not Tool.Enabled
end

local function onMouse2Up()
	if not Tool.Enabled then return end
	
	Tool.Enabled = not Tool.Enabled
	IsCheckValue.Value = true
	
	local character = Tool.Parent
	local humanoid = character:FindFirstChild('Humanoid')
	local torso = character:FindFirstChild('Torso')
	if humanoid and humanoid.Health > 0 and torso then
		CheckTrack = humanoid:LoadAnimation(CheckAnim)
		doCheck(torso)
		if CheckTrack then CheckTrack:Play() end
		wait(CHECK_TIME)
		if CheckTrack then CheckTrack:Stop() end
		if torso then
			local bodyVelocity = torso:FindFirstChild('CheckVelocity')
			if bodyVelocity then
				bodyVelocity:Destroy()
				bodyVelocity.Parent = nil
			end
		end
	end
	
	IsCheckValue.Value = false
	Tool.Enabled = not Tool.Enabled
end

local function onEquipped(mouse)
	if Tool.Parent then
		local character = Tool.Parent
		local humanoid = character:FindFirstChild('Humanoid')
		if humanoid then
			IdleTrack = humanoid:LoadAnimation(IdleAnim)
			if IdleTrack then wait(0.25) IdleTrack:Play() end
		end
	end
	
	if mouse then
		Mouse = mouse
		Mouse.Button1Down:connect(onMouse1Down)
		Mouse.Button2Up:connect(onMouse2Up)
	end
end

local function onUnequipped()
	if IdleTrack then IdleTrack:Stop() end
	if SwingTrack then SwingTrack:Stop() end
	if CheckTrack then CheckTrack:Stop() end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
