-----------------------
--|    Variables    |--
-----------------------
local Tool = script.Parent
local MyMouse = nil

-----------------------
--|    Constants    |--
-----------------------
local RELOAD_TIME = 0.5
local RELOAD_CURSOR = 'rbxasset://textures\\GunWaitCursor.png'
local GUN_CURSOR = 'rbxasset://textures\\GunCursor.png'

-----------------------
--|    Animations   |--
-----------------------
local GunFireAnim = Tool:WaitForChild('GunFire')
local GunFireTrack = nil

-----------------------
--|      Events     |--
-----------------------
local IsEnabled = true
local function onButton1Down(mouse)
	if not IsEnabled then
		return
	end
	
	IsEnabled = false

	if MyMouse then MyMouse.Icon = RELOAD_CURSOR end
	local character = Tool.Parent
	local humanoid = character:FindFirstChild('Humanoid')
	if humanoid and humanoid.Health > 0 then
		if GunFireTrack then
			GunFireTrack:Play(0, nil, 1)
			wait(0.2)
			GunFireTrack:Stop()
		end
	end
	
	wait(RELOAD_TIME - 0.2)

	if MyMouse then MyMouse.Icon = GUN_CURSOR end

	IsEnabled = true
end

local function onEquipped(mouse)
	if not mouse then
		return 
	end

	MyMouse = mouse

	if Tool.Enabled then mouse.Icon = GUN_CURSOR
	else mouse.Icon = RELOAD_CURSOR end
	mouse.Button1Down:connect(onButton1Down)
	
	if Tool.Parent then
		local character = Tool.Parent
		local humanoid = character:FindFirstChild('Humanoid')
		if humanoid and humanoid.Health > 0 then
			GunFireTrack = humanoid:LoadAnimation(GunFireAnim)
		end
	end
end

local function onUnequipped()
	if GunFireTrack then GunFireTrack:Stop() end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
