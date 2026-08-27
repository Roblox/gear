-----------------
--| Constants |--
-----------------

local Tool = script.Parent
while Tool:FindFirstChild('Handle') == nil do wait() end 
local ToolHandle = Tool.Handle

local MOUSE_ICON = 'rbxasset://textures/GunCursor.png'
local RELOADING_ICON = 'rbxasset://textures/GunWaitCursor.png'

local COOLDOWN = 6 -- Seconds until tool can be used again

-----------------
--| Variables |--
-----------------

local MyPlayer = game:GetService'Players'.LocalPlayer

local Mouse = nil
local ClickTime = 0

local SoundTable = {}
local Holding = false

-----------------
--| Functions |--
-----------------

local function StartInfiniteChargeSound()
	local chargeSound = ToolHandle:FindFirstChild('Charge')
	local lastPlayTime = 0
	repeat -- Start a new charge sound every second
		if chargeSound and time() - lastPlayTime >= 1 then
			local chargeSoundClone = chargeSound:Clone()
			chargeSoundClone.Parent = ToolHandle
			chargeSoundClone:Play()
			lastPlayTime = time()
			table.insert(SoundTable, chargeSoundClone)
		end
		wait(1/30)
	until not Holding

	-- Play fire sound
	local fireSound = ToolHandle:FindFirstChild('Fire')
	if fireSound then
		fireSound:Play()
	end

	-- Stop all charge sounds
	for _, sound in pairs(SoundTable) do
		sound:Stop()
		sound:Destroy()
	end
	SoundTable = {}
end

local function OnButton1Down()
	local myModel = MyPlayer.Character
	if Tool.Enabled and myModel and myModel:FindFirstChild('Humanoid') and myModel.Humanoid.Health > 0 then
		ClickTime = time()
		Holding = true
		
		Tool.MouseButton1Down:FireServer(Mouse.Hit.p)
		StartInfiniteChargeSound()
	end
end

local function OnButton1Up()
	Tool.MouseButton1Up:FireServer(Mouse.Hit)
	
	Holding = false
end

local function OnEquipped(mouse)
	Mouse = mouse
	if Tool.Enabled then
		Mouse.Icon = MOUSE_ICON
	else
		Mouse.Icon = RELOADING_ICON
	end
	Mouse.Button1Down:connect(OnButton1Down)
	Mouse.Button1Up:connect(OnButton1Up)
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)


Tool.Changed:connect(function(prop)
	if prop == 'Enabled' then
		if Mouse then
			Mouse.Icon = Tool.Enabled and MOUSE_ICON or RELOADING_ICON
		end
	end
end)
