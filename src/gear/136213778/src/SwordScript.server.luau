local Tool = script.Parent
local RunService = game:service('RunService')
local DebrisService = game:GetService('Debris')
local Handle = Tool:WaitForChild('Handle')
local IsFreezing = Tool:WaitForChild('IsFreezing')
IsFreezing.Value = false
local RunAnim = Tool:WaitForChild('RunAnim')
local NumHits = Tool:WaitForChild('NumHits')
local CanBreath = Tool:WaitForChild('CanBreath')

local Anims = {'RightSlash', 'LeftSlash', 'OverHeadSwing'}

-- CONSTANTS --
local MAX_HITS_TO_FREEZE = 3
local SWING_RATE = 1.0
local BASE_DMG = 35
local SLASH_DMG = 35
local SWING_DMG = 35

local Damage = BASE_DMG

local SlashSound = Instance.new('Sound')
SlashSound.SoundId = 'rbxasset://sounds\\swordslash.wav'
SlashSound.Parent = Handle
SlashSound.Volume = 0.7

local UnsheathSound = Instance.new('Sound')
UnsheathSound.SoundId = 'rbxasset://sounds\\unsheath.wav'
UnsheathSound.Parent = Handle
UnsheathSound.Volume = 0.5

local function rndm()
	return (math.random() - 0.5) * 2
end

local function tagHumanoid(hitHumanoid, player)
	for i,v in ipairs(hitHumanoid:GetChildren()) do
		if v.Name == 'creator' then
			v:remove()
		end
	end
	local creator_tag = Instance.new('ObjectValue')
	creator_tag.Value = player
	creator_tag.Name = 'creator'
	creator_tag.Parent = hitHumanoid
	DebrisService:AddItem(creator_tag, 1)
end

local function makeIcePart(hitLocationCFrame, sizeValue)
	local part = Instance.new('Part')
	part.Name = 'Effect'
	part.BrickColor = BrickColor.new('Pastel light blue')
	part.FormFactor = 'Custom'
	part.Size = Vector3.new(sizeValue * math.random(), sizeValue * math.random(), sizeValue * math.random())
	part.Transparency = 0.3
	part.Reflectance = 0.3
	part.TopSurface = 'Smooth'
	part.BottomSurface = 'Smooth'
	part.CFrame = hitLocationCFrame * CFrame.new(rndm() * 5, rndm() * 8, rndm() * 5)
	part.Velocity = Vector3.new(rndm(), rndm(), rndm()) * 100
	part.RotVelocity=Vector3.new(rndm(), rndm(), rndm()) * 10
	DebrisService:AddItem(part, 3 + 7 * math.random())
	part.Parent = game.Workspace
end

local function setNumHits()
	NumHits.Value = NumHits.Value + 1
	if NumHits.Value > MAX_HITS_TO_FREEZE then
		NumHits.Value = MAX_HITS_TO_FREEZE
	end
	if NumHits.Value == MAX_HITS_TO_FREEZE then
		CanBreath.Value = true
	end
end

local IsDebounce = false
local function blow(hit)
	if IsDebounce or Tool.Enabled then
		print('Debounce ' .. tostring(IsDebounce))
		print('ToolEnabled ' .. tostring(Tool.Enabled))
		return
	end
	IsDebounce = true
	if hit.Parent then
		print'hit.Parent is true'
		local attackingCharacter = Tool.Parent
		
		if attackingCharacter then
			print'attacking char is true'
			local attackingPlayer = game.Players:GetPlayerFromCharacter(attackingCharacter)
			if attackingPlayer then
				print'attackin player is true'
				local attackingHumanoid = attackingCharacter:FindFirstChild('Humanoid')
				local hitHumanoid = hit.Parent:FindFirstChild('Humanoid')
				print(hitHumanoid)
				if hitHumanoid and hitHumanoid.Health > 0 then
					print'hit hum is true'
					if attackingHumanoid and hitHumanoid ~= attackingHumanoid and attackingHumanoid.Health > 0 then
						local rightArm = attackingCharacter:FindFirstChild('Right Arm')
						print'stuff is true'
						if rightArm then
							print'right arm is true'
							local joint = rightArm:FindFirstChild('RightGrip')
							if joint and (joint.Part0 == Handle or joint.Part1 == Handle) then
								print'joints are true'
								tagHumanoid(hitHumanoid, attackingPlayer)
								local hitTorso = hit.Parent:FindFirstChild('Torso')
								local isKill = false
								if hitTorso then
									print'hit torso is true'
									-- other player is frozen
									local iceWeld = hitTorso:FindFirstChild('IceWeld')
									if iceWeld then
										print'iceWeld is true'
										if iceWeld.Part1 then
											local sound = Handle:FindFirstChild('ShatterSound')
											if sound then
												sound:Stop()
												sound:Play()
											end
											for i = 1, 15 do
												makeIcePart(iceWeld.Part1.CFrame, 3)
											end
											iceWeld.Part1:remove()
										end
										hitTorso:BreakJoints()
										isKill = true
									end
								end
								for i = 1, 10 do
									makeIcePart(hit.CFrame, 0.5)
								end
								hitHumanoid:TakeDamage(Damage)
								if not isKill then
									setNumHits()
								end
								wait(0.9)
							end
						end
					end
				end
			end
		end
	end
	IsDebounce = false
end

Tool.Enabled = true
local function onActivated()
	if Tool.Enabled and not Tool.IsFreezing.Value then
		Tool.Enabled = false
		local character = Tool.Parent
		local humanoid = character:FindFirstChild('Humanoid')
		if not humanoid then
			print('Humanoid not found')
			return 
		end
		
		SlashSound:Play()
		local newAnim = Anims[math.random(1, #Anims)]
		while newAnim == RunAnim.Value do
			newAnim = Anims[math.random(1, #Anims)]
		end
		
		RunAnim.Value = newAnim
		if newAnim == 'OverHeadSwing' then
			Damage = SWING_DMG
		else
			Damage = SLASH_DMG
		end
		
		wait(SWING_RATE)
		Damage = BASE_DMG
		Tool.Enabled = true
	end
end

function onEquipped()
	UnsheathSound:Play()
	NumHits.Value = 0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)

Handle.Touched:connect(blow)
