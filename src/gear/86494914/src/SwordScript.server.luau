-------- Ultra Katana ---------

r = game:service("RunService")


local damage = 4


local slash_damage = 5
local lunge_damage = 6


local Tool = script.Parent
local sword = Tool.Handle


local leftSword

local leftSwordWeld
local leftSwordConnection

local bodyGyro

local vCharacter
local vTorso
local vHumanoid


local vJumpForce


local attackList = nil


Tool.Enabled = true



local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
SlashSound.Parent = sword
SlashSound.Volume = .7

local LungeSound = Instance.new("Sound")
LungeSound.SoundId = "rbxasset://sounds\\swordlunge.wav"
LungeSound.Parent = sword
LungeSound.Volume = .6

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1

local lastHitTarget = nil

function blow(hit)
	if not hit.Parent then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand
		--[[for index, child in pairs(vTorso:GetChildren()) do
		    if child.Name == 'BodyVelocity' then
				child.Parent = nil
				end
		end]]
		--if vJumpForce then vJumpForce.maxForce = Vector3.new(0, 0, 0) end
		
		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				lastHitTarget = humanoid
				--if humanoid and humanoid.Health > 0 then
				--	lunge()
				--end
				wait(1)
				untagHumanoid(humanoid)
			end
		end


	end
	
end


function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end


function attack()
	damage = slash_damage
	SlashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end

function slamdown()


	bothSwordsDown()
	wait(1.5)
	swordUp()
	

end

function lunge()
	if Tool:FindFirstChild('Lunging').Value then return end
	Tool:FindFirstChild('Lunging').Value = true
	attackList = {}
	local lungeDir

	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)					
	local players = game.Players:GetChildren()
	local maxDistance = 48
	--local neareastDist = maxDistance
	--local nearestCharacter = nil
	if #players > 1 then 
		for i = 1, #players do 
			local currPlayer = players[i]
			if currPlayer ~= vPlayer then 
				local tempChar = players[i].Character
				if tempChar then
					local tempTorso = tempChar:FindFirstChild("Torso")
					if tempTorso then
						local distance = (tempTorso.Position - vTorso.Position).magnitude
						--print('distance is' .. distance)
						if distance < maxDistance then --and distance < nearestDist then
							if distance > 10 then
								table.insert(attackList, tempChar)

								--nearestDist = distance
								--neareastCharacter = tempChar
								--print('nearestPlayer is' .. neareastCharacter.Name)
							end
						end
					end
				end
			end
		end
	end


	damage = lunge_damage

	LungeSound:play()

	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = Tool
	
	if vJumpForce == nil then
		vJumpForce = Instance.new("BodyVelocity")
		vJumpForce.Parent = Tool.Parent.Torso

		vJumpForce.Name = "JumpForce"
	end

	print(#attackList .. 'enemies in the list')
	if attackList and #attackList > 0 then

		for _, v in ipairs(attackList) do
			local nextVictim = v
			local nextVictimTorso = nextVictim:FindFirstChild("Torso")
			-- get the direction to the next target and normalize it to a velocity of 80
			--print("lunging from " .. vTorso.Position .. " to " .. nextTorsoPosition)
			lungeDir = (nextVictimTorso.Position - vTorso.Position).unit * 80
			vTorso.CFrame = CFrame.new(vTorso.CFrame.p, nextVictimTorso.Position)
			vJumpForce.velocity = lungeDir --Vector3.new(0,10,0) --Tool.Parent.Torso.CFrame.lookVector * 80
			-- Let it apply a large amount of force
			vJumpForce.maxForce = Vector3.new(1000000, 1000000, 1000000)
			wait(0.6)
			if vJumpForce ~= nil then
				vJumpForce.maxForce = Vector3.new()
			end
			wait(0.25)
		end
		
	else
		lungeDir = vTorso.CFrame.lookVector * 80
		vJumpForce.velocity = lungeDir --Vector3.new(0,10,0) --Tool.Parent.Torso.CFrame.lookVector * 80
		-- Let it apply a large amount of force
		vJumpForce.maxForce = Vector3.new(1000000, 1000000, 1000000)
		wait(1.0)
		if vJumpForce ~= nil then
			vJumpForce.maxForce = Vector3.new()
		end
		wait(.2)
	end		

	wait(.2)
	swordUp()
	

	damage = slash_damage
	Tool:FindFirstChild('Lunging').Value = false
end

function swordUp()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
	if leftSwordWeld then
		--leftSwordWeld.C1 = leftSwordWeld.C1 * CFrame.Angles(180, 0, 0)
		-- CFrame for pointing the sword down
		leftSwordWeld.C1 = CFrame.new(0, 0, -2.1, 0, 0, 1, 1, 0, 0, 0, 1, 0)
	end
end

function bothSwordsDown()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,-1)
	if leftSwordWeld then
		--leftSwordWeld.C1 = leftSwordWeld.C1 * CFrame.Angles(180, 0, 0)
		-- CFrame for pointing the sword down
		leftSwordWeld.C1 = CFrame.new(0, 0, -2.1, 0, 0, 1, -1, 0, 0, 0, -1, 0)
	end
end

function swordOut()
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripRight = Vector3.new(0,-1,0)
	Tool.GripUp = Vector3.new(-1,0,0)
end

function swordAcross()
	-- parry
end


function findNearestPlayer()
	local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)					
	local players = game.Players:GetChildren()
	local maxDistance = 100
	local neareastDist = maxDistance
	local nearestCharacter = nil
	if #players > 1 then 
		for i = 1, #players do 
			local currPlayer = players[i]
			if currPlayer ~= vPlayer then 
				local tempChar = players[i].Character
				if tempChar then
					local tempTorso = tempChar:FindFirstChild("Torso")
					if tempTorso then
						local distance = (tempTorso.Position - vTorso.Position).magnitude
						print('distance is' .. distance)
						if distance < maxDistance then --and distance < nearestDist then

							nearestDist = distance
							neareastCharacter = tempChar
							print('nearestPlayer is' .. neareastCharacter.Name)
							return Vector3.new(tempTorso.Position.x, tempTorso.Position.y, tempTorso.Position.z)
						end
					end
				end
			end
		end
	end
	return nearestCharacter
end

Tool.Enabled = true
local last_attack = 0
function onActivated()
	--[[
	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false
	]]
	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end
	
	-- Pull out the swords on first use
	if Tool:FindFirstChild('JustEquipped').Value then
		wait(0.3)
	

		--wait(0.1)
		local rightHandWeld = vCharacter:FindFirstChild('Right Arm'):FindFirstChild('RightGrip')
		-- These numbers grip to the hand
		rightHandWeld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		rightHandWeld.C1 = CFrame.new(0, 0, -2.1, 0, 0, 1, 1, 0, 0, 0, 1, 0)
		rightHandWeld.Part0 = Tool.Parent:FindFirstChild("Right Arm")
		rightHandWeld.Part1 = sword
		--wait(0.1)
		if not Tool.Parent:FindFirstChild("Left Arm"):FindFirstChild("LeftGrip") then
			-- These numbers grip to the hand
			leftSwordWeld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			leftSwordWeld.C1 = CFrame.new(0, 0, -2.1, 0, 0, 1, 1, 0, 0, 0, 1, 0)
			leftSwordWeld.Name = 'LeftGrip'
			leftSwordWeld.Parent = Tool.Parent:FindFirstChild("Left Arm")
			leftSwordWeld.Part0 = Tool.Parent:FindFirstChild("Left Arm")
			leftSwordWeld.Part1 = leftSword
		end

		return
	end

	print('Attacking')
	t = r.Stepped:wait()
	
	if (t - last_attack < 0.2) then
		lastHitTarget = nil
		lunge()
	else
		attack()
	end

	last_attack = t

	--wait(.5)

	--Tool.Enabled = true
end


function onEquipped()
	--print('onEquip Called')
	UnsheathSound:play()
	lunging = false
	vCharacter = Tool.Parent
	vTorso = vCharacter:FindFirstChild("Torso")
	bodyGyro = vTorso:FindFirstChild('BodyGyro')
	if not bodyGyro then
		bodyGyro = Instance.new('BodyGyro', vTorso)
		bodyGyro.maxTorque = Vector3.new(50000000, 0, 50000000)
	end
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	local vLeftArm = vCharacter:FindFirstChild("Left Arm")
	if vTorso and vLeftArm and vCharacter:FindFirstChild("LeftSword") == nil and leftSwordWeld == nil then 
		leftSword = sword:Clone()
		leftSword.Name = "LeftSword"
		leftSword.Parent = vCharacter
		leftSwordWeld = Instance.new("Weld")		
		leftSwordWeld.Part0 = vTorso
		leftSwordWeld.Part1 = leftSword
		-- This CFrame grips the sword to the back at a 45 degree angle
		leftSwordWeld.C0 = CFrame.new(-0.4, 0.45, 0.65) * CFrame.Angles(math.pi / 2, math.pi / 6, math.pi)
		leftSwordWeld.Parent = vTorso 
		leftSwordWeld.Name = "LeftGrip"

		leftSwordConnection = leftSword.Touched:connect(blow)
	end
	--wait(0.1)
	-- Set the Right Weapon to weld on the back
	local rightWeld = vCharacter:FindFirstChild('Right Arm'):FindFirstChild('RightGrip')
	rightWeld.C1 = CFrame.new()
	rightWeld.Part0 = vTorso
	-- This CFrame grips the sword to the back at a 45 degree angle
	rightWeld.C0 = CFrame.new(0.4, 0.45, 0.65) * CFrame.Angles(math.pi / 2, -math.pi / 6, 0)
	rightWeld.Part1 = sword
	
end

function onUnequipped()
	-- RightGrip is remove automagically, but we have to remember to clean
	-- the left sword and grip that we added
	if leftSword then leftSword:Remove() leftSword = nil end
	if leftSwordWeld then leftSwordWeld:Remove() leftSwordWeld = nil end
	if vJumpForce then vJumpForce:Remove() vJumpForce = nil end
	bodyGyro = vTorso:FindFirstChild('BodyGyro')
	if bodyGyro then
		bodyGyro:Remove()
		bodyGyro = nil
	end
	--if slashSound then slashSound:Stop() end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)


