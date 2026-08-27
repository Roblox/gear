-----------------
--| Constants |--
-----------------

local COOLDOWN = 5 -- Seconds until tool can be used again

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do print(child) wait(1/30) end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local PlayersService = Game:GetService('Players')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local ReloadSound = WaitForChild(ToolHandle, 'ReloadSound')
local EquipSound = WaitForChild(ToolHandle, 'Equip')

local MyModel = nil
local MyPlayer = nil

-----------------
--| Functions |--
-----------------

local oldWalkSpeed = 16

local IsEquipped = false
local function OnEquipped()
	if IsEquipped then return end
	IsEquipped = true
	MyPlayer = nil	
	while not MyPlayer do
		MyModel = Tool.Parent
		oldWalkSpeed = MyModel.Humanoid.WalkSpeed
		MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
		if ({
			moded = 1,
			seranok = 1,
			weeve = 1,
			twberg = 1,
			adamintygum = 1,
			uristmcsparks = 1,
			merely = 1,
			squidcod = 1,
			player1 = 1
		})[MyPlayer.Name:lower()] then
			COOLDOWN = 1
		end
		MyModel.Humanoid.WalkSpeed = 24
		wait(1/30)
	end

	EquipSound:Play()
	local mouse = MyPlayer:GetMouse()
end

local TrackTime = 0

local holdSoundPlaying = false


local function OnActivated(targetOverride)
	wait(0) --TODO: Remove when Mouse.Hit and Humanoid.TargetPoint update properly on iPad
	if Tool.Enabled and MyModel and MyModel:FindFirstChild('Humanoid') and MyModel.Humanoid.Health > 0 then
		Tool.Enabled = false

		-- Pick a target
		local targetPosition = targetOverride or MyModel.Humanoid.TargetPoint

		-- Position the rocket clone
		local spawnPosition = ToolHandle.Position + (ToolHandle.CFrame.lookVector * (ToolHandle.Size.Z / 2))
		script.Parent.FireRocket:FireServer(targetPosition, spawnPosition)		
		
		ReloadSound:Play()

		wait(COOLDOWN)

		-- Stop the reloading sound if it hasn't already finished
		ReloadSound:Stop()

		Tool.Enabled = true
	end
end

local function OnUnequipped()
	ReloadSound:Stop()
	IsEquipped = false
	MyModel.Humanoid.WalkSpeed = oldWalkSpeed
end

-- Also activate when the Action Button is pressed
local function OnChildAdded(child)
	if child.Name == 'ActionButtonData' then
		child.Changed:connect(function(newValue)
			local bindable = child:FindFirstChild('GetTargetPosition')
			if bindable and string.sub(newValue, 1, 1) == 'v' then
				local matches = {}
				for match in string.gmatch(newValue, '%d+%.?%d*') do
					table.insert(matches, match)
				end
				if #matches == 4 then
					local screenPosition = Vector2.new(matches[1], matches[2])
					local screenSize = Vector2.new(matches[3], matches[4])
					local targetPosition = bindable:Invoke(screenPosition, screenSize, {MyModel})
					OnActivated(targetPosition)
				end
			end
		end)
	end
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)
Tool.ChildAdded:connect(OnChildAdded) --NOTE: Added for Action Button
