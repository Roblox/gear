local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local AbilityRemoteEvent = script:WaitForChild('AbilityRemoteEvent')
local DebrisService = game:GetService('Debris')
local AnimValue = Tool:WaitForChild('Anim')
local IsGroundSwordDebounce = false
local IsSpinAttackDebounce = false
local IsAbilityInUse = false
local IsSwinging = false
local CanHit = false
local ThisCharacter = nil
local SoSGui = Tool:WaitForChild('SoSGui')
local Frame = SoSGui:WaitForChild('Frame')
local cdSmash = Frame:WaitForChild('cdSmash')
local cdSpin = Frame:WaitForChild('cdSpin')
local SlashSound = Handle:WaitForChild('SlashSound')
local GroundSound = Handle:WaitForChild('GroundSound')

---------------------------------------------------
				-- Constants --
---------------------------------------------------
-- Ground Swords
local CONE_OUTTER_RADIUS = 50
local CONE_INNER_RADIUS = 10
local GROUND_SWORD_NUM = 100
local GROUND_SWORD_DURATION = 0.1
local GROUND_SWORD_END_POSITION = 5
local GROUND_SWORD_DMG = 20
local GROUND_SWORD_COOLDOWN = 5
-- Spin Attack
local SPIN_ATTACK_COOLDOWN = 8
local SPIN_ATTACK_TIME = 2
local SPIN_SWORD_DMG = 15
-- General
local SWORD_DMG = 30
local SWING_SPEED = 1.5
local SWING_DEBOUNCE = 0.9

local GroundSwordMeshes = {
	[1] = { ['meshId'] = 'http://www.roblox.com/asset/?id=124121136',
		['textureId'] = 'http://www.roblox.com/asset/?id=124121617',
		['scale'] = Vector3.new(2, 2, 2) },
	[2] = { ['meshId'] = 'http://www.roblox.com/asset/?id=68377852',
		['textureId'] = 'http://www.roblox.com/asset/?id=68377863',
		['scale'] = Vector3.new(1.2, 1.2, 1.2) },
	[3] = { ['meshId'] = 'http://www.roblox.com/asset/?id=103838505',
		['textureId'] = 'http://www.roblox.com/asset/?id=103838996',
		['scale'] = Vector3.new(1, 1, 1) },
}

local SpinSwordMeshes = {
	[1] = { ['meshId'] = 'http://www.roblox.com/asset/?id=11439778',
		['textureId'] = 'http://www.roblox.com/asset/?id=11439794', },
	[2] = { ['meshId'] = 'http://www.roblox.com/asset/?id=73012411',
		['textureId'] = 'http://www.roblox.com/asset/?id=73012458' },
	[3] = { ['meshId'] = 'http://www.roblox.com/asset/?id=139126981',
		['textureId'] = 'http://www.roblox.com/asset/?id=139127068' }
}

---------------------------------------------------
				-- Helper Functions --
---------------------------------------------------
local function getRandomPointInCircle()
	local x, z = 0, 0
	while true do
		x = 2 * CONE_OUTTER_RADIUS * math.random() - CONE_OUTTER_RADIUS
		z = 2 * CONE_OUTTER_RADIUS * math.random() - CONE_OUTTER_RADIUS
		local magnitude = x * x + z * z
		if magnitude < CONE_OUTTER_RADIUS * 2 and magnitude > CONE_INNER_RADIUS * 2 then
			return Vector3.new(x, 0, z)
		end
	end	
end

local function lerp(t, start, finish, duration)
	t = t / duration
	return (1 - t) * start + t * finish
end

local function clamp(val, low, high)
	if val < low then
		return low
	elseif val > high then
		return high
	end	
	return val
end

local function doCooldown(duration, cooldownGui)
	local t = 0
	local deltaTime = tick()
	cooldownGui.Text = duration
	while t < duration do
		t = t + (tick() - deltaTime)
		cooldownGui.Text = string.format('%.1f', clamp(duration - t, 0, duration))
		deltaTime = tick()
		wait()
	end
	cooldownGui.Text = ''
end

local function guiFlash(cooldownGui)
	cooldownGui.BackgroundColor3 = Color3.new(236 * 0.004, 209 * 0.004, 53 * 0.004)
	local t = 0
	local deltaTime = tick()
	while t < 0.2 do
		cooldownGui.BackgroundTransparency = lerp(t, 0.25, 1, 0.2)
		t = t + (tick() - deltaTime)		
		deltaTime = tick()
		wait()
	end
	cooldownGui.BackgroundTransparency = 0.25
	cooldownGui.BackgroundColor3 = Color3.new(1, 1, 1)
end

---------------------------------------------------
				-- Hit Events --
---------------------------------------------------
local function onSwordHit(hit)	
	if IsSwinging or not CanHit then
		return
	end
	IsSwinging = true
	if hit.Parent then
		local hitCharacter = hit.Parent
		if hitCharacter == ThisCharacter then
			return
		end
		local hitHumanoid = hitCharacter:FindFirstChild('Humanoid')
		if hitHumanoid then
			hitHumanoid:TakeDamage(SWORD_DMG)
			wait(SWING_DEBOUNCE)
		end
	end
	IsSwinging = false
end

Handle.Touched:connect(onSwordHit)

local function onGroundSwordRegion(midPoint, ignoreModel)
	local regionHalfSize = Vector3.new(15, 2.5, 15)
	local startPoint = midPoint - regionHalfSize
	local endPoint = midPoint + regionHalfSize
	
	local hitRegion = Region3.new(startPoint, endPoint)
	
	local ignoreList = {ignoreModel, ThisCharacter}
	local partsInRegion = game.Workspace:FindPartsInRegion3WithIgnoreList(
		hitRegion, ignoreList, 100
	)
	
	local hitHumanoids = {}
	for _,part in pairs(partsInRegion) do
		local isValidCharacter = true
		if part.Parent then
			local hitCharacter = part.Parent
			local hitHumanoid = hitCharacter:FindFirstChild('Humanoid')
			if hitHumanoid then
				for _,hum in pairs(hitHumanoids) do
					if hum == hitHumanoid then
						isValidCharacter = false
						break
					end
				end
				if isValidCharacter then
					table.insert(hitHumanoids, hitHumanoid)
				end
			end
		end
	end
	
	for _,hitHumanoid in pairs(hitHumanoids) do
		hitHumanoid:TakeDamage(GROUND_SWORD_DMG)
		local hitCharacter = hitHumanoid.Parent
		local hitTorso = hitCharacter:FindFirstChild('Torso')
		if hitTorso then
			hitTorso.Velocity = Vector3.new(0, 60, 0)
		end
	end
end

---------------------------------------------------
				-- Create Functions --
---------------------------------------------------
local function createGroundSword(spawnPoint, torsoPosition)	
	local finalSpawnPoint = Vector3.new(
		spawnPoint.x + torsoPosition.x,
		torsoPosition.y - 5.5,
		spawnPoint.z + torsoPosition.z
	)
	local sword = Instance.new('Part')
	sword.FormFactor = Enum.FormFactor.Custom
	sword.Size = Vector3.new(0.2, 5, 0.2)
	sword.Anchored = true
	sword.CanCollide = false
	sword.CFrame = CFrame.new(finalSpawnPoint + Vector3.new(0, 1.5, 0))
	
	local randomMesh = math.random(1, #GroundSwordMeshes)
	local mesh = Instance.new('SpecialMesh')
	mesh.Scale = GroundSwordMeshes[randomMesh]['scale']
	mesh.MeshId = GroundSwordMeshes[randomMesh]['meshId']
	mesh.TextureId = GroundSwordMeshes[randomMesh]['textureId']
	mesh.Parent = sword
	
	return sword
end

local function createSpinSword(torso)
	local randomMesh = math.random(1, #SpinSwordMeshes)
	local sword = Instance.new('Part')
	sword.FormFactor = Enum.FormFactor.Custom
	sword.Size = Vector3.new(0.2, 0.2, 5)
	sword.CanCollide = false
	sword.CFrame = CFrame.new(torso.Position + torso.CFrame.lookVector * 2) * (torso.CFrame - torso.CFrame.p)
	if randomMesh < 3 then
		sword.CFrame = sword.CFrame * CFrame.Angles(0, math.pi, 0)
	else
		sword.CFrame = sword.CFrame * CFrame.Angles(0, -math.pi * 0.5, math.pi * 0.5)
	end
	
	local mesh = Instance.new('SpecialMesh')
	mesh.Scale = Vector3.new(2, 2, 2)
	mesh.MeshId = SpinSwordMeshes[randomMesh]['meshId']
	mesh.TextureId = SpinSwordMeshes[randomMesh]['textureId']
	mesh.Parent = sword
	
	local hasHit = false
	sword.Touched:connect(function(hit)
		if hasHit then
			return
		end
		hasHit = true
		if hit.Parent then
			local hitCharacter = hit.Parent
			if hitCharacter == ThisCharacter then
				hasHit = false
				return
			end
			local hitHumanoid = hitCharacter:FindFirstChild('Humanoid')
			if hitHumanoid and hitHumanoid.Health > 0 then
				print('spin sword hit', hitCharacter.Name)
				hitHumanoid:TakeDamage(SPIN_SWORD_DMG)
				wait(0.5)
			end
		end
		hasHit = false
	end)
	
	local bodyVelocity = Instance.new('BodyVelocity')
	bodyVelocity.velocity = torso.CFrame.lookVector * 50
	bodyVelocity.Parent = sword
	
	return sword
end

---------------------------------------------------
				-- Ability Helper Functions --
---------------------------------------------------
local function doJump(torso, humanoid)
	local bodyVelocity = Instance.new('BodyVelocity')
	bodyVelocity.maxForce = Vector3.new(1, 1, 1) * 1000000
	bodyVelocity.velocity = Vector3.new(0, 3, 0) * 10
	DebrisService:AddItem(bodyVelocity, 4)
	bodyVelocity.Parent = torso
	AnimValue.Value = 'UpSmashAnim'
	
	Tool.GripUp = Vector3.new(0, -1, 0)	
	wait(0.35 * SWING_SPEED)
	
	if bodyVelocity then
		bodyVelocity.velocity = Vector3.new(0, -80, 0)
	end
	
	wait(0.1 * SWING_SPEED)
	
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity.Parent = nil
	end
	
	wait(0.2)
	Tool.GripUp = Vector3.new(0, 1, 0)
end

local function translateSwords(model, direction)
	local offset = 0
	local t = 0
	local deltaTime = tick()
	while t < GROUND_SWORD_DURATION do
		local d = lerp(t, 0, GROUND_SWORD_END_POSITION, GROUND_SWORD_DURATION)
		local step = d - offset
		offset = d
		model:TranslateBy(Vector3.new(0, step * direction, 0))
		t = t + (tick() - deltaTime)
		deltaTime = tick()
		wait()
	end
end

local function doGroundSwordEffect(swordsModel, regionMidPoint)
	GroundSound:Play()
	translateSwords(swordsModel, 1)
	onGroundSwordRegion(regionMidPoint, swordsModel)
	wait(0.25)
	translateSwords(swordsModel, -1)
	swordsModel:Destroy()
	swordsModel.Parent = nil
end

local function shootBlades(torso)
	local t = 0
	local deltaTime = tick()
	while t < SPIN_ATTACK_TIME do
		local sword = createSpinSword(torso)
		sword.Parent = game.Workspace
		DebrisService:AddItem(sword, 2)
		
		t = t + (tick() - deltaTime)
		deltaTime = tick()
		wait()
	end
end

---------------------------------------------------
				-- Abilities --
---------------------------------------------------
local function ringOfSwords(character, humanoid)
	if IsGroundSwordDebounce then
		return
	end
	IsGroundSwordDebounce = true
	local torso = character:FindFirstChild('Torso')
	if torso then
		IsAbilityInUse = true
		local spawnPosition = torso.Position
		doJump(torso, humanoid)
		local model = Instance.new('Model')
		
		for i = 1, GROUND_SWORD_NUM do
			local sword = createGroundSword(getRandomPointInCircle(), spawnPosition)
			sword.Parent = model
		end
		model.Parent = game.Workspace
		doGroundSwordEffect(model, spawnPosition)
		IsAbilityInUse = false
		doCooldown(GROUND_SWORD_COOLDOWN, cdSmash)
		guiFlash(cdSmash)
		cdSmash.Text = 'Q'
	end
	IsGroundSwordDebounce = false
end

local function spiningBladesAttack(character, humanoid)
	if IsSpinAttackDebounce then
		return
	end
	IsSpinAttackDebounce = true
	
	local torso = character:FindFirstChild('Torso')
	if torso then
		IsAbilityInUse = true
		AnimValue.Value = 'SpinAnim'
		
		local spinForce = Instance.new('BodyAngularVelocity')
		spinForce.P = 1000000
		spinForce.angularvelocity = Vector3.new(0, 20, 0)
		spinForce.maxTorque = Vector3.new(spinForce.P, spinForce.P, spinForce.P)
		spinForce.Parent = torso
		
		Tool.GripUp = Vector3.new(0, 0.5, 1)
		if SlashSound.IsPlaying then
			SlashSound:Stop()
		end
		SlashSound.Pitch = 1.1
		SlashSound.Looped = true
		SlashSound:Play()
		shootBlades(torso)
		SlashSound:Stop()
		SlashSound.Pitch = 1
		SlashSound.Looped = false
		
		Tool.GripUp = Vector3.new(0, 1, 0)
		spinForce:Destroy()
		spinForce.Parent = nil
		
		IsAbilityInUse = false
		doCooldown(SPIN_ATTACK_COOLDOWN, cdSpin)
		guiFlash(cdSpin)
		cdSpin.Text = 'E'
	end
	IsSpinAttackDebounce = false
end

---------------------------------------------------
				-- Remote Events --
---------------------------------------------------
local function onServerEvent(player, key)
	if IsAbilityInUse then
		return
	end
	if player then
		if ThisCharacter then
			local humanoid = ThisCharacter:FindFirstChild('Humanoid')
			if humanoid and humanoid.Health > 0 then
				if key == 'q' then
					ringOfSwords(ThisCharacter, humanoid)
				elseif key == 'e' then
					spiningBladesAttack(ThisCharacter, humanoid)
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

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
