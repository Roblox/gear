---------------------------------------------------
					-- Tool Variables --
---------------------------------------------------
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Humanoid = nil
local ServerScript = Tool:WaitForChild('SoSScript')
local AbilityRemoteEvent = ServerScript:WaitForChild('AbilityRemoteEvent')
local EquipAnim = Tool:WaitForChild('EquipAnim')
local SpinAnim = Tool:WaitForChild('SpinAnim')
local UpSmashAnim = Tool:WaitForChild('UpSmashAnim')
local DownSmashAnim = Tool:WaitForChild('DownSmashAnim')
local AnimValue = Tool:WaitForChild('Anim')
local SoSGui = Tool:WaitForChild('SoSGui')

-- Animations
local SwingAnims = {
	[1] = Tool:WaitForChild('OverheadSwingAnim'),
	[2] = Tool:WaitForChild('SlashAnim')
}

--Sounds
local EquipSound = Handle:WaitForChild('EquipSound')

---------------------------------------------------
					-- Constants --
---------------------------------------------------
local SWING_DEBOUNCE = 0.9
local SWING_SPEED = 1.5
local SPIN_ATTACK_TIME = 2

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
			if val == 'SpinAnim' then
				anim = humanoid:LoadAnimation(SpinAnim)
				anim:Play(nil, nil, 1.75)
				wait(SPIN_ATTACK_TIME)
				anim:Stop()
			elseif val == 'UpSmashAnim' then
				anim = humanoid:LoadAnimation(UpSmashAnim)
				anim:Play()	
				wait(0.7)				
				anim:Stop()
				anim = humanoid:LoadAnimation(DownSmashAnim)
				anim:Play()
				wait(0.325)
				anim:Stop()
			elseif val == 'SwingAnim' then
				anim = humanoid:LoadAnimation(SwingAnims[math.random(1, #SwingAnims)])
				if anim then
					anim:Play()
				end
			end
		end
		AnimValue.Value = ''
	end
end

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
				SoSGui.Parent = playerGui
			end
		end
		
		if Tool.Parent then
			local character = Tool.Parent
			Humanoid = character:FindFirstChild('Humanoid')
			if Humanoid then
				local equipAnim = Humanoid:LoadAnimation(EquipAnim)
				if equipAnim then
					EquipSound:Play()
					equipAnim:Play(nil, nil, 1.5)
				end
			end
		end
	end
end

local function onUnequipped()
	Tool.Enabled = true
	SoSGui.Parent = Tool
end

AnimValue.Changed:connect(onAnimChanged)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
