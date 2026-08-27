-------- OMG HAX

r = game:service("RunService")
local sword = script.Parent.Handle
local Tool = script.Parent

local damage = 15
local p = nil
local humanoid = nil
local hitCoolDown = 0

local slashSounds = {"28144268 ","28144277","28144291","28144295"}

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "http://www.roblox.com/asset/?id=" .. slashSounds[math.random(1,#slashSounds)]
SlashSound.Parent = sword
SlashSound.Volume = .7

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "http://www.roblox.com/asset/?id=28257433"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1


local hitting = false

function blow(hit)

	if hitting then
		return
	end

	hitting = true

	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand

		local right_arm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(0.5)
				untagHumanoid(humanoid)
			end
		end


	end

	hitting = false

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


function attack(humanoid)
	SlashSound.SoundId = "http://www.roblox.com/asset/?id=" .. slashSounds[math.random(1,#slashSounds)]
	SlashSound:play()
	Tool.AnimationValue.Value = "changed"
	Tool.AnimationValue.Value = "standardAttack"
end

function lunge(humanoid)
	SlashSound.SoundId = "http://www.roblox.com/asset/?id=" .. slashSounds[math.random(1,#slashSounds)]
	SlashSound:play()
	Tool.AnimationValue.Value = "changed"
	Tool.AnimationValue.Value = "doubleAttack"
	wait(0.5)
	SlashSound:play()
end

function spin(humanoid)

	Tool.AnimationValue.Value = "changed"
	Tool.AnimationValue.Value = "spinAttack"
	
end

Tool.Enabled = true
local last_attack = 0

function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	t = r.Stepped:wait()

	
	if (t - last_attack < .2) then
		lunge(humanoid)
	else
		attack(humanoid)
	end

	first_attack = last_attack
	last_attack = t

	Tool.Enabled = true
end

function onEquipped()
	
	UnsheathSound:play()
	local humanoid = Tool.Parent:FindFirstChild("Humanoid",false)
	p = game.Players:GetPlayerFromCharacter(Tool.Parent)

end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)

connection = sword.Touched:connect(blow)

