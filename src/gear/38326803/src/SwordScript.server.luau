-------- OMG HAX

r = game:service("RunService")
local sword = script.Parent.Handle
local Tool = script.Parent

local damage = 3
local p = nil
local humanoid = nil

local slash_damage = 6
local regularWalk = 23

--local SlashSound = Instance.new("Sound")
--SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
--SlashSound.Parent = sword
--SlashSound.Volume = .7
--
--local LungeSound = Instance.new("Sound")
--LungeSound.SoundId = "rbxasset://sounds\\swordlunge.wav"
--LungeSound.Parent = sword
--LungeSound.Volume = .6

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1

-- magical sword sound has id of 25256253...  for fast slashes, like swordslash.wav (SlashSound)


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

function attack()
	vCharacter = Tool.Parent
	damage = slash_damage
	wait(.75)
	SlashSound = sword:FindFirstChild("SlashSound")
	--if SlashSound == nil then
	--	SlashSound = Instance.new("Sound")
	--	SlashSound.Volume = .7
	--	SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
	--	SlashSound.Name = "SlashSound"
	--	SlashSound.Parent = sword
	--end
	if SlashSound ~= nil then SlashSound:play() end
	wait(.5)
	SlashSound = sword:FindFirstChild("SlashSound")
	if SlashSound ~= nil then SlashSound:play() end
	wait(1.25)
	SlashSound = sword:FindFirstChild("SlashSound")
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


Tool.Enabled = true
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

	attack()

	wait(.5)
	Tool.Enabled = true
end

function onEquipped()
	SlashSound = sword:FindFirstChild("SlashSound")
	if SlashSound == nil then
		SlashSound = Instance.new("Sound")
		SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
		SlashSound.Parent = sword
		SlashSound.Volume = .7
		SlashSound.Name = "SlashSound"
	end

	UnsheathSound:play()
end

function onUnequipped()
	SlashSound = sword:FindFirstChild("SlashSound")
	if SlashSound ~= nil then
		SlashSound:Stop()
		SlashSound.Parent = nil
		SlashSound = nil
	end
end	

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)

