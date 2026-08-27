-------- OMG HAX

r = game:service("RunService")


local damage = 3


local slash_damage = 6


sword = script.Parent.Handle
Tool = script.Parent


local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "http://www.roblox.com/Asset/?ID=12135982"
SlashSound.Parent = sword
SlashSound.Volume = .7

function isTurbo(character)
	return character:FindFirstChild("PaperHat") ~= nil
end


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
				local d = damage
				if (isTurbo(vCharacter) == true) then d = d * 2.5 end
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(d)
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


function swordUp()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function swordOut()
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripRight = Vector3.new(0,-1,0)
	Tool.GripUp = Vector3.new(-1,0,0)
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

	wait(.4)

	Tool.Enabled = true
end


function onEquipped()
	SlashSound:play()
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)


connection = sword.Touched:connect(blow)


