-------- OMG HAX

r = game:service("RunService")
local sword = script.Parent.Handle
local Tool = script.Parent

local damage = 5
local p = nil
local humanoid = nil

local slash_damage = 8
local lunge_damage = 12
local regularWalk = 23

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
SlashSound.Parent = sword
SlashSound.Volume = .7

local LungeSound = Instance.new("Sound")
LungeSound.SoundId = "http://www.roblox.com/asset/?id=26771744"
LungeSound.Parent = sword
LungeSound.Volume = .6

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1


function blow(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand

		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
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


function attack(humanoid)
	damage = slash_damage
	SlashSound:play()


	local animation = humanoid:LoadAnimation(Tool.twohandedswordhit)
	animation:Play()
	animation.KeyframeReached:connect(function(string)
		if string == "throwdown" then
			animation:Stop()
			animation:remove()
		end
	end)
end

function lunge(humanoid)
	damage = lunge_damage
	LungeSound:play()
	
	local anim = humanoid:LoadAnimation(Tool.bigtwohandhit)
	anim:Play(0.1,1,4)
	anim.KeyframeReached:connect(function(string)
		if string == "throwdown" then
			anim:Stop()
			anim:remove()
		end
	end)

	damage = slash_damage
end

function swordUp()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function swordOut()
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(1,0,0)
end

function swordAcross()
	-- parry
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

	last_attack = t

	Tool.Enabled = true
end

function onEquipped()
	
	UnsheathSound:play()
	local humanoid = Tool.Parent:FindFirstChild("Humanoid",false)
	animation = humanoid:loadAnimation(Tool.twohandedswordhit)
	p = game.Players:GetPlayerFromCharacter(Tool.Parent)

end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)

connection = sword.Touched:connect(blow)

