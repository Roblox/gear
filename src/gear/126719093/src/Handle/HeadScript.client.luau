local ATTACK_RANGE = 40
local TURN_RATE = 3*math.pi/1 -- (half turn per second)
local MOVE_RATE = 50/1
local DIVE_RANGE = 10
local DAMAGE_RANGE = 4
local DURATION = 35
local RELOAD_TIME = 2

local PlacedAt = tick()

--
local Head = script.Parent
local Mesh = Head:WaitForChild('Mesh')
Head:WaitForChild('Light').Enabled = true
local Sound = Head:WaitForChild('SOUND_Laugh')
local Character = Head.Parent
local CharacterHead = Character:WaitForChild('Head')
local CharacterTorso = Character:WaitForChild('Torso')
local CharacterHumanoid = Character:WaitForChild('Humanoid')
local Mover = Head:WaitForChild('Mover')
local Gyro = Head:WaitForChild('Gyro')

--
local CurrentState = 'Idle' -- Idle | Dive | Recover
local CurrentHeading = Character.Head.CFrame.lookVector
local CurrentPos = CharacterHead.Position
local CurrentTargetCharacter = nil
local DiveStarted = nil
local RecoverStarted = nil
local LastDamager;
local DiveDamaged = false
local LastAttack = 0
local LastTime = tick()
local ThisTime = tick()
local dt = 0

--
local Mouse = game.Players:GetPlayerFromCharacter(Character):GetMouse()

-- Returns a character ancestor and its Humanoid, or nil
local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

-- 
local function Targetable(target)
	if not target then return false end
	local torso = target:FindFirstChild('Torso')
	local hum   = target:FindFirstChild('Humanoid')
	return torso and hum and target ~= Character and target.Humanoid.Health > 0 and (torso.Position-CharacterTorso.Position).magnitude < ATTACK_RANGE
end

-- When our character is damaged, attack the damager
CharacterHumanoid.ChildAdded:connect(function(ch)
	if ch.Name == 'creator' then
		local damager = ch.Value
		if damager and damager.Character then
			LastDamager = damager.Character
		end
	end
end)

--
local function SwitchTarget(target)
	CurrentTargetCharacter = target
	CurrentState = 'Idle'
	Mesh.Scale = Vector3.new(1,1,1)
end

--
local function Slerp(t, a, b)
	local om = math.acos(math.min(1, a:Dot(b)))
	if om < 0.01 then
		return (1-t)*a +
		          t *b
	else
		return (math.sin((1-t)*om)/math.sin(om))*a +
		       (math.sin(   t *om)/math.sin(om))*b
	end
end

--
local function MoveTowards(pos)
	if CurrentPos ~= pos then
		local vecTo = (pos - CurrentPos)
		local dirTo = vecTo.unit
		local thetaBetween = math.acos(math.min(1, dirTo:Dot(CurrentHeading)))
		local maxTurn = dt*TURN_RATE
		if thetaBetween > maxTurn then
			CurrentHeading = Slerp(maxTurn / thetaBetween, CurrentHeading, dirTo)
		else
			CurrentHeading = dirTo
		end
		CurrentPos = CurrentPos + CurrentHeading*MOVE_RATE*dt
	end
end

--
while tick()-PlacedAt < DURATION do
	LastTime = ThisTime
	ThisTime = tick()
	dt = ThisTime - LastTime
	
	-- Do targeting
	local desiredTarget;
	
	-- Mouse targeting
	local mouseRay = Ray.new(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction*999)
	local hit, at = game.Workspace:FindPartOnRay(mouseRay, Character)
	local overrideTarget;
	if hit then
		local ch, hum = FindCharacterAncestor(hit)
		if Targetable(ch) then
			-- Target this character
			overrideTarget = ch
		end
	end
	
	-- Apply target
	if overrideTarget then
		-- Target the override first
		if overrideTarget ~= CurrentTargetCharacter then
			SwitchTarget(overrideTarget)
		end
		
	elseif not Targetable(CurrentTargetCharacter) then
		if Targetable(LastDamager) then
			-- Target last damager
			SwitchTarget(LastDamager)
		else			
			-- Target nearby humanoids
			local hsz = Vector3.new(ATTACK_RANGE, 3, ATTACK_RANGE)
			local region = Region3.new(CharacterTorso.Position - hsz, CharacterTorso.Position + hsz)
			local parts = Workspace:FindPartsInRegion3(region, Character)
			--
			local found = false
			for _, part in pairs(parts) do
				local ch, hum = FindCharacterAncestor(part)
				if ch and ch ~= Character then
					SwitchTarget(ch)
					found = true
					break
				end
			end
			-- Target other players
			if not found then
				for _, player in pairs(game.Players:GetChildren()) do
					if Targetable(player.Character) then
						SwitchTarget(player.Character)
					end
				end
			end
		end
	end
	
	-- Do we have a target?
	local byCharacterPos = (CharacterHead.CFrame*CFrame.Angles(0, (ThisTime%(2*math.pi))*10, 0)*CFrame.new(0, 0, -2-2*math.sin(ThisTime%(2*math.pi)))).p
	if Targetable(CurrentTargetCharacter) then
		local targetLoc = (CurrentTargetCharacter.Torso.CFrame*CFrame.new(0,2,0)).p
		if CurrentState == 'Idle' then
			-- Move towards target, and see if we can begin dive
			MoveTowards(targetLoc)
			if (CurrentPos - targetLoc).magnitude < DIVE_RANGE and (tick()-LastAttack) > RELOAD_TIME then
				CurrentState = 'Dive'
				DiveStarted = tick()
				DiveDamaged = false
				--
				CurrentHeading = (targetLoc - CurrentPos).unit
				Sound:Play()
			end
		elseif CurrentState == 'Dive' then
			local timeIntoDive = tick()-DiveStarted
			local frac = math.sin(timeIntoDive*math.pi)^2
			local mfrac = 1-frac
			local tickMod = tick()%(2*math.pi)
			local xMess = (math.sin(tickMod*10+1)+math.sin(tickMod*15+8))*4 + 1
			local yMess = (math.cos(tickMod*6 +6)+math.sin(tickMod*13+3))*4 + 1
			local zMess = (math.sin(tickMod*9 +4)+math.cos(tickMod*4 +7))*4 + 1
			Mesh.Scale = Vector3.new(mfrac+frac*xMess, mfrac+frac*yMess, mfrac+frac*zMess)
			if (CurrentPos - targetLoc).magnitude < DAMAGE_RANGE and not DiveDamaged then
				LastAttack = tick()
				DiveDamaged = true
				CurrentTargetCharacter.Humanoid:TakeDamage(40)
			end
			if timeIntoDive > 1 then
				CurrentState = 'Recover'
				RecoverStarted = tick()
			end
			MoveTowards(targetLoc + CurrentHeading*4)
		elseif CurrentState == 'Recover' then
			local timeIntoRecover = tick()-RecoverStarted
			if timeIntoRecover > 3 then
				CurrentState = 'Idle'
			else
				local frac = timeIntoRecover/3
				frac = math.sqrt(frac)
				local mfrac = 1-frac
				MoveTowards(mfrac*targetLoc + frac*byCharacterPos)
			end
		end
	else	
		MoveTowards(byCharacterPos)
	end
	--
	Mover.position = CurrentPos
	if Head.Position ~= CurrentPos then
		Gyro.cframe = CFrame.new(Vector3.new(), CurrentHeading)
	end
	wait()
end

-- fade
local speed = MOVE_RATE
for i = 0, 1, 0.02 do
	wait()
	i = i*i
	local m = 1-i
	--
	CurrentPos = CurrentPos + CurrentHeading*MOVE_RATE*(i*i)*0.03
	Mesh.Scale = Vector3.new(m, 1+(i*i)*200*m^3, m)
end

Head:Destroy()