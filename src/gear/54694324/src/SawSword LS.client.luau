math.randomseed(tick())

local Tool = script.Parent
local Sword = Tool.Handle

local myCharacter
local myPlayer
local myHumanoid
local myTorso
local myRightArm
local myRightGrip

local debris = game:GetService("Debris")
local runServ = game:GetService("RunService")

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\SwordSlash.wav"
SlashSound.Parent = Tool
SlashSound.Volume = .7
local unsheathSound = Instance.new("Sound")
unsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
unsheathSound.Parent = Sword
unsheathSound.Volume = 0.7

local activeAnim
local activeSound

local lastAttackTime = 0
local thisAttackTime

local randNum

local DamageDeterminer	-- Keeping track of which damage to apply is hard; I'm using an IntValue to do it.

local TOUCH_DAMAGE = 5
local SLASH_DAMAGE = 9
local SPIKES_DAMAGE = 12
local SAW_DAMAGE = 10
local allDamages = {}
allDamages[1] = SLASH_DAMAGE
allDamages[2] = SPIKES_DAMAGE
allDamages[3] = SAW_DAMAGE

Tool.Enabled = true

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creator = Instance.new("ObjectValue")
		creator.Name = "creator"
		creator.Value = player
		creator.Parent = humanoid
		debris:addItem(creator, 1)
	end	
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local creatorTag = humanoid:FindFirstChild("creator")
	if creatorTag then creatorTag:Remove() end
	end
end

function slow(humanoid)
	if humanoid.Parent == nil then return end
	local slowScript = humanoid.Parent:FindFirstChild("SawSlowScript")
	if slowScript == nil then
		if Tool:FindFirstChild("SawSlowScript") ~= nil then
			slowScript = Tool.SawSlowScript:Clone()
			slowScript.Parent = humanoid.Parent
			slowScript.Disabled = false
		end
	end
end

function instantiateDamageDet(value)
	DamageDeterminer = Tool:FindFirstChild("DamageDeterminer")
	if DamageDeterminer then DamageDeterminer:Remove() end

	DamageDeterminer = Instance.new("IntValue")
	DamageDeterminer.Name = "DamageDeterminer"
	DamageDeterminer.Parent= Tool
	DamageDeterminer.Value = value

	if (value == 1 or value == 2) then
		debris:AddItem(DamageDeterminer, 0.5)
	else	--value == 3, i.e. it's a saw
		debris:AddItem(DamageDeterminer, 2.5)
	end
end

function damageHumanoid(humanoid)
	DamageDeterminer = Tool:FindFirstChild("DamageDeterminer")
	if (DamageDeterminer == nil) then
		humanoid:TakeDamage(TOUCH_DAMAGE)
	else
		humanoid:TakeDamage(allDamages[DamageDeterminer.Value])
		slow(humanoid)
	end
end

function blow(hit)
	if hit.Parent then 
		local hitHumanoid = hit.Parent:FindFirstChild("Humanoid")
		myCharacter = Tool.Parent
		myHumanoid = myCharacter:FindFirstChild("Humanoid")
		myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
		if hitHumanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= hitHumanoid then
			myRightArm = myCharacter:FindFirstChild("Right Arm")
			if myRightArm then 
				myRightGrip = myRightArm:FindFirstChild("RightGrip")
				if myRightGrip and (myRightGrip.Part0 == Sword or myRightGrip.Part1 == Sword) then 
					tagHumanoid(hitHumanoid, myPlayer)
					damageHumanoid(hitHumanoid)
					wait(1)
					untagHumanoid(hitHumanoid)
				end
			end
		end
	end
end

function slash()
	instantiateDamageDet(1)

	if activeSound then activeSound:Play() end
	if activeAnim then activeAnim:Play() end

end

function spikes()
	instantiateDamageDet(2)

	if activeAnim then activeAnim:Play() end
	if activeSound then activeSound:Play() end

end

function saw()
	instantiateDamageDet(3)
	
	if activeSound then activeSound:Play() end
	if activeAnim then activeAnim:Play() end
	wait(2.5)

end

function onActivated()
	-- Checking for double clicks is based on the sword standard.

	-- Check that tool is enabled,
	if not Tool.Enabled then return end
	Tool.Enabled = false
	-- And that character has use of his right arm.
	myCharacter = Tool.Parent
	if not myCharacter then return end
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	if not myHumanoid then return end
	RightArm = myCharacter:FindFirstChild("Right Arm")
	if not RightArm then return end

	if activeAnim then activeAnim:Stop() end
	if activeSound then activeSound:Stop() end

	-- Get the time, to determine whether it was a double click or not.
	thisAttackTime = runServ.Stepped:wait()

	if (thisAttackTime - lastAttackTime < 0.2) then	-- It was a double click.
		activeAnim = myHumanoid:LoadAnimation(Tool.Bonesaw)
		activeSound = Tool:FindFirstChild("SawSound")
		saw()
	else	-- It was a single click.
		randNum = math.random(1, 3)
		if (randNum < 3) then
			if (randNum < 2) then
				activeAnim = myHumanoid:LoadAnimation(Tool.Slash)
			else
				activeAnim = myHumanoid:LoadAnimation(Tool.RightSlash)
			end
			activeSound = SlashSound
			slash()
		else
			activeAnim = myHumanoid:LoadAnimation(Tool.SpikesToFace)
			activeSound = Tool:FindFirstChild("SpikePunchSound")
			spikes()
		end
	end
	
	lastAttackTime = thisAttackTime
	Tool.Enabled = true
end

function onEquipped()
	if unsheathSound then unsheathSound:Play() end
end

function onUnequipped()	
	if activeSound then activeSound:Stop() end
	if unsheathSound then unsheathSound:Stop() end
	if activeAnim then activeAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)
