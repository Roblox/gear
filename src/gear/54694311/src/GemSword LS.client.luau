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
local Whoosh1Sound
local Whoosh2Sound

local SlashAnim
local SpecialAnim

local lastAttackTime = 0
local thisAttackTime

local TOUCH_DAMAGE = 0	-- C'mon, people, it's a wooden sword. It doesn't do touch damage.
local SLASH_DAMAGE = 10
local SPECIAL_DAMAGE = 13

local damage = TOUCH_DAMAGE

local damageCo	--Coroutine to ensure that slash damage actually gets applied sometimes.

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
					hitHumanoid:TakeDamage(damage)
					wait(1)
					untagHumanoid(hitHumanoid)
				end
			end
		end
	end
end

function damageChanger()
	damage = SLASH_DAMAGE
	wait(1)
	damage = TOUCH_DAMAGE
end

function slash()
	-- We actually want to recreate the coroutine every time, since otherwise we'd have multiple functions
	--   trying to switch back and forth between the different damages constantly if we slashed multiple
	--   times.
	damageCo = coroutine.create(damageChanger)
	coroutine.resume(damageCo)

	if Whoosh1Sound then Whoosh1Sound:Stop() end
	if Whoosh2Sound then Whoosh2Sound:Stop() end
	if SpecialAnim then SpecialAnim:Stop() end
	
	if SlashSound then SlashSound:Play() end
	if SlashAnim then SlashAnim:Play() end
end

function special()
	damageCo = nil
	damage = SPECIAL_DAMAGE

	if SlashSound then SlashSound:Stop() end
	if SlashAnim then SlashAnim:Stop() end
	
	if SpecialAnim then SpecialAnim:Play() end

	wait(.4)
	if Whoosh1Sound then Whoosh1Sound:Play() end
	wait(.7)
	if Whoosh2Sound then Whoosh2Sound:Play() end
	wait(.1)
	
	damage = TOUCH_DAMAGE
	
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

	-- Get the time, to determine whether it was a double click or not.
	thisAttackTime = runServ.Stepped:wait()

	if (thisAttackTime - lastAttackTime < 0.2) then	-- It was a double click.
		SpecialAnim = myHumanoid:LoadAnimation(Tool.SlashNStabAttempt2)
		Whoosh1Sound = Tool:FindFirstChild("Whoosh1")
		Whoosh2Sound = Tool:FindFirstChild("Whoosh2")
		special()
	else	-- It was a single click.
		SlashAnim = myHumanoid:LoadAnimation(Tool.Slash)
		slash()
	end
	
	lastAttackTime = thisAttackTime
	Tool.Enabled = true
end

function onUnequipped()	
	if SlashSound then SlashSound:Stop() end
	if SlashAnim then SlashAnim:Stop() end
	if Whoosh1Sound then Whoosh1Sound:Stop() end
	if Whoosh2Sound then Whoosh2Sound:Stop() end
	if SpecialAnim then SpecialAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)
