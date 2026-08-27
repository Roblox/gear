---------------------------------------------------
					-- Tool Variables --
---------------------------------------------------
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local ServerScript = Tool:WaitForChild('StPunkScript')
local AbilityRemoteEvent = ServerScript:WaitForChild('AbilityRemoteEvent')
local EquipAnim = Tool:WaitForChild('EquipAnim')
local AnimValue = Tool:WaitForChild('Anim')
local StPunkGui = Tool:WaitForChild('StPunkGui')

-- Animations
local SwingAnims = {
	[1] = Tool:WaitForChild('OverheadSwingAnim'),
	[2] = Tool:WaitForChild('SlashAnim')
}
local CastAnim = Tool:WaitForChild('CastAnim')

--Sounds
local EquipSound = Handle:WaitForChild('EquipSound')

---------------------------------------------------
					-- Constants --
---------------------------------------------------
local SWING_DEBOUNCE = 0.9
local SWING_SPEED = 1.5

---------------------------------------------------
					-- Effects --
---------------------------------------------------
local function createSteamEffect(parent)
	local smoke = Instance.new('Smoke')
	smoke.RiseVelocity = 10
	smoke.Size = 2
	smoke.Parent = parent
	Delay(1, function()
		smoke:Destroy()
		smoke.Parent = nil
	end)
end

---------------------------------------------------
					-- Events --
---------------------------------------------------
local function onAnimChanged(val)
	if val == '' then
		return
	end
	
	local anim = nil	
	if Tool.Parent then
		local character = Tool.Parent
		local humanoid = character:FindFirstChild('Humanoid')
		if humanoid and humanoid.Health > 0 then
			if val == 'SwingAnim' then
				anim = humanoid:LoadAnimation(SwingAnims[math.random(1, #SwingAnims)])
				if anim then
					anim:Play()
				end
			elseif val == 'CastAnim' then
				anim = humanoid:LoadAnimation(CastAnim)
				if anim then
					anim:Play(nil, nil, 4)
				end
			end
		end
		AnimValue.Value = ''
	end
end

AnimValue.Changed:connect(onAnimChanged)

local function onKeyDown(key)
	local lkey = string.lower(key)
	
	if lkey == 'q' then
		AbilityRemoteEvent:FireServer(lkey)
	elseif lkey == 'e' then
		AbilityRemoteEvent:FireServer(lkey)
	end
end

local function onMouse1Down()
	if Tool.Enabled then
		Tool.Enabled = false
		createSteamEffect(Handle)
		wait(SWING_DEBOUNCE)
		Tool.Enabled = true
	end
end

local function onEquipped(mouse)
	if mouse then
		mouse.KeyDown:connect(onKeyDown)
		mouse.Button1Down:connect(onMouse1Down)
		
		local player = game.Players.LocalPlayer
		if player then
			local playerGui = player:FindFirstChild('PlayerGui')
			if playerGui then
				StPunkGui.Parent = playerGui
			end
		end
		
		if Tool.Parent then
			local character = Tool.Parent
			local humanoid = character:FindFirstChild('Humanoid')
			if humanoid then
				local equipAnim = humanoid:LoadAnimation(EquipAnim)
				if equipAnim then
					EquipSound:Play()
					equipAnim:Play(nil, nil, 1.5)
					createSteamEffect(Handle)
				end
			end
		end
	end
end

local function onUnequipped()
	Tool.Enabled = true
	StPunkGui.Parent = Tool
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
