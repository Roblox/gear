local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local AbilityRemoteEvent = script:WaitForChild('AbilityRemoteEvent')
local GyserEffectScript = Tool:WaitForChild('GyserEffect')
local StunScript = script:WaitForChild('StunScript')
local ThisCharacter = nil
local AnimValue = Tool:WaitForChild('Anim')
local IsAbilityInUse = false
local IsGyserInUse = false
local CanHit = false -- only let sword hit if player used it
local PlayersService = game:GetService('Players')
local DebrisService = game:GetService('Debris')

-- Debounce Variables
local IsHitDebounce = false

-- Sounds
local SlashSound = Handle:WaitForChild('SlashSound')
local ChargeSound = Handle:WaitForChild('ChargeSound')

---------------------------------------------------
				-- Constants --
---------------------------------------------------
-- General
local SWORD_DMG = 40
local SWING_SPEED = 1.5
local SWING_DEBOUNCE = 0.9
-- Steam Gyser
local GYSER_NUM = 4
local GYSER_DISTANCE_THRESHOLD = 30
local GYSER_EFFECT_LEN = 5
-- Mist Charge
local CHARGE_TIME = 0.5
local CAHRGE_MIN_SPEED = 50
local MIST_CHARGE_THRESHOLD = 50
local CHARGE_STUN_DMG = 15

---------------------------------------------------
				-- Helper Functions --
---------------------------------------------------
local function clamp(val, low, high)
	if val < low then
		val = low
	elseif val > high then
		val = high
	end
	return val
end

local function CreateStunnedGui(player, character)
	if not player or not character or not character:FindFirstChild('Head') then
		return
	end
	
	local bg = Instance.new("BillboardGui")
	bg.Parent = character.Head
	bg.Adornee = character.Head
	-- Same size as Head
	bg.Size = UDim2.new(1, 0, 1, 0)
	-- Above (defaults to inside)
	bg.StudsOffset = Vector3.new(0, 2.5, 0)
	 
	local frame = Instance.new("Frame")
	frame.Parent = bg
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	 
	local text = Instance.new("TextLabel")
	text.Parent = frame
	text.Position = UDim2.new(0.25, 0, 0.25, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.TextColor3 = Color3.new(1, 39/255, 20/255)
	text.TextStrokeColor3 = Color3.new(1, 225/255, 73/255)
	text.TextStrokeTransparency = 0
	text.BackgroundTransparency = 1
	text.Text = "Stunned!"
	text.FontSize = Enum.FontSize.Size18
	DebrisService:AddItem(bg, 0.75)
end

---------------------------------------------------
				-- Hit Events --
---------------------------------------------------
local function onSwordHit(hit)	
	if IsHitDebounce or not CanHit then
		return
	end
	IsHitDebounce = true
	if hit.Parent then
		local hitCharacter = hit.Parent
		if hitCharacter == ThisCharacter then
			return
		end
		local hitHumanoid = hitCharacter:FindFirstChild('Humanoid')
		if hitHumanoid then
			local isStunned = hitCharacter:FindFirstChild('StunScript')
			local dmg = SWORD_DMG
			if isStunned then
				dmg = dmg + CHARGE_STUN_DMG
			end
			print(dmg)
			hitHumanoid:TakeDamage(dmg)
			wait(SWING_DEBOUNCE)
		end
	end
	IsHitDebounce = false
end

Handle.Touched:connect(onSwordHit)

---------------------------------------------------
				-- Helper Functions --
---------------------------------------------------
local function getClosestCharacters(originPosition, thisCharacter)
	local gyseredCharacters = {}
	for _,player in pairs(PlayersService:GetChildren()) do
		local character = player.Character
		local torso = character:FindFirstChild('Torso')
		local humanoid = character:FindFirstChild('Humanoid')
		if torso and humanoid and humanoid.Health > 0 and character ~= thisCharacter then
			if (torso.Position - originPosition).magnitude <= GYSER_DISTANCE_THRESHOLD then
				table.insert(gyseredCharacters, character)
			end
		end
		if #gyseredCharacters >= GYSER_NUM then
			break
		end
	end
	
	return gyseredCharacters
end

local function getClosestCharacter(originPosition, thisCharacter)
	local closestDistance = math.huge
	local closestCharacter = nil
	for _,player in pairs(PlayersService:GetChildren()) do
		local character = player.Character
		local torso = character:FindFirstChild('Torso')
		local humanoid = character:FindFirstChild('Humanoid')
		if torso and humanoid and humanoid.Health > 0 and character ~= thisCharacter then
			local distance = (torso.Position - originPosition).magnitude
			if distance <= MIST_CHARGE_THRESHOLD and distance < closestDistance then
				closestDistance = distance
				closestCharacter = character
			end
		end
	end
	
	return closestCharacter, closestDistance
end

-- Returns all objects under instance with Transparency
local function GetTransparentsRecursive(instance, partsTable)
	local partsTable = partsTable or {}
	for _, child in pairs(instance:GetChildren()) do
		if child:IsA('BasePart') or child:IsA('Decal') then
			if child.Name ~= 'HumanoidRootPart' then
				table.insert(partsTable, child)
			end
		end
		GetTransparentsRecursive(child, partsTable)
	end
	return partsTable
end

---------------------------------------------------
				-- Abilities --
---------------------------------------------------
-- Steam Gyser
local function doGyserEffect(characters)
	if #characters < 1 then
		return
	end
	IsGyserInUse = true
	for _,character in pairs(characters) do
		-- add script to player
		if not character:FindFirstChild('GyserEffect') then
			local gyserScript = GyserEffectScript:Clone()			
			gyserScript.Disabled = false
			gyserScript.Parent = character
		end
	end
end

local function steamGyser(character)
	if IsGyserInUse then
		return
	end
	IsAbilityInUse = true
	Delay(GYSER_EFFECT_LEN + 1, function()
		IsGyserInUse = false
	end)
	local torso = character:FindFirstChild('Torso')
	local humanoid = character:FindFirstChild('Humanoid')
	
	if humanoid and humanoid.Health > 0 and torso then
		AnimValue.Value = 'CastAnim'
		doGyserEffect(getClosestCharacters(torso.Position, character))
	end
	IsAbilityInUse = false
end

-- Mist Charge
local function doMistCharge(targetCharacter, character, start, distance)
	local target = targetCharacter:FindFirstChild('Torso')
	if target then
		local transparentParts = GetTransparentsRecursive(character)
		local mist = nil
		if #transparentParts > 0 then
			mist = Instance.new('Smoke')
			mist.RiseVelocity = 20
			mist.Size = 5
			mist.Parent = start
			
			for _,part in pairs(transparentParts) do
				part.Transparency = 1
			end
		end
		
		wait()
		
		local speed = clamp(distance / CHARGE_TIME, CAHRGE_MIN_SPEED, 1000000)
		local direction = (target.Position - start.Position).unit
		local bodyVelocity = Instance.new('BodyVelocity')
		bodyVelocity.velocity = direction * speed
		bodyVelocity.P = 4000
		bodyVelocity.maxForce = Vector3.new(1000000, 1000000, 1000000)
		bodyVelocity.Parent = start
		DebrisService:AddItem(bodyVelocity, CHARGE_TIME + 0.2)
		start.CFrame = CFrame.new(start.CFrame.p, start.CFrame.p + bodyVelocity.velocity)
		local bodyGyro = Instance.new('BodyGyro')
		bodyGyro.Parent = start
		DebrisService:AddItem(bodyGyro, 0.3)
		
		-- fail safe in case they don't hit a player with charge
		local connection = nil
		Delay(CHARGE_TIME + 0.2, function()
			if bodyVelocity then
				bodyVelocity.velocity = Vector3.new()
				bodyVelocity:Destroy()
				bodyVelocity.Parent = nil
			end
			if connection then
				connection:disconnect()
			end
			if #transparentParts > 0 then
				for _,part in pairs(transparentParts) do
					part.Transparency = 0
				end
			end
			if mist then
				mist:Destroy()
				mist.Parent = nil
			end
		end)
		
		local hasHitWithCharge = false
		connection = start.Touched:connect(function(hit)
			if hasHitWithCharge then
				return
			end
			if hit.Parent and hit.Parent ~= character then
				local hitCharacter = hit.Parent
				local hitHumanoid = hitCharacter:FindFirstChild('Humanoid')
				if hitHumanoid and hitHumanoid.Health > 0 and hitCharacter == targetCharacter then
					hasHitWithCharge = true
					bodyVelocity.velocity = Vector3.new()
					bodyVelocity:Destroy()
					bodyVelocity.Parent = nil
					if #transparentParts > 0 then
						for _,part in pairs(transparentParts) do
							part.Transparency = 0
						end
					end
					if mist then
						mist:Destroy()
						mist.Parent = nil
					end
					CreateStunnedGui(PlayersService:GetPlayerFromCharacter(hitCharacter), hitCharacter)
					CreateStunnedGui(PlayersService:GetPlayerFromCharacter(ThisCharacter), hitCharacter)
					if not hitCharacter:FindFirstChild('StunScript') then
						local stun = StunScript:Clone()						
						stun.Disabled = false
						stun.Parent = hitCharacter
					end
				end
			end
		end)
	end
end

local function mistCharge(character)
	IsAbilityInUse = true
	Delay(CHARGE_TIME, function()
		IsAbilityInUse = false
	end)
	local torso = character:FindFirstChild('Torso')
	local humanoid = character:FindFirstChild('Humanoid')
	
	if humanoid and humanoid.Health > 0 and torso then
		local closestCharacter, distance = getClosestCharacter(torso.Position, character)
		if closestCharacter then
			ChargeSound:Play()
			doMistCharge(closestCharacter, character, torso, distance)
		end
	end
end

---------------------------------------------------
				-- Remote Events --
---------------------------------------------------
local function onServerEvent(player, key)
	if IsAbilityInUse then
		return
	end
	if player then
		character = player.Character
		if character then
			local humanoid = character:FindFirstChild('Humanoid')
			if humanoid and humanoid.Health > 0 then
				if key == 'q' then
					steamGyser(character)
				elseif key == 'e' then
					mistCharge(character)
				end
			end
		end
	end
end

AbilityRemoteEvent.OnServerEvent:connect(onServerEvent)

---------------------------------------------------
				-- Events --
---------------------------------------------------
local function onActivated()
	if CanHit or IsAbilityInUse then
		return
	end
	CanHit = true
	SlashSound:Play()
	AnimValue.Value = 'SwingAnim'
	wait(SWING_DEBOUNCE)
	CanHit = false
end

local function onEquipped()
	ThisCharacter = Tool.Parent
end

local function onUnequipped()
	IsAbilityInUse = false
end

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)
