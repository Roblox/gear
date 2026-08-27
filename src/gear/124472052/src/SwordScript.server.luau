-------- OMG HAX

r = game:service("RunService")


local damage = 5


local slash_damage = 6
local lunge_damage = 8

sword = script.Parent.Handle
Tool = script.Parent


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


function blow(hit)
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
			end
		end


	end
end


function tagHumanoid(humanoid,player)

	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=player
	creator_tag.Name="creator"
	
	local weapon_tag = Instance.new('StringValue')
	weapon_tag.Name = 'weapon'
	weapon_tag.Value = script.Parent.Name
	weapon_tag.Parent = creator_tag
	
	creator_tag.Parent=humanoid
	game.Debris:AddItem(creator_tag,4)
end



function attack()
	damage = slash_damage
	SlashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end

function lunge()
	damage = lunge_damage

	LungeSound:play()

	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = Tool
	
	
	force = Instance.new("BodyVelocity")
	force.velocity = Vector3.new(0,10,0) --Tool.Parent.Torso.CFrame.lookVector * 80
	force.Parent = Tool.Parent.Torso
	wait(.2)
	swordOut()
	wait(.2)
	force.Parent = nil
	wait(.4)
	swordUp()

	damage = slash_damage
end

function swordUp()
	Tool.Grip = CFrame.Angles(0,0,0)+Vector3.new(0,-2,0)
end

function swordOut()
	Tool.Grip = CFrame.Angles(-math.pi/2,-math.pi,math.pi/2)+Vector3.new(0,-1.5,0)
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
		lunge()
	else
		attack()
	end

	last_attack = t

	--wait(.5)

	Tool.Enabled = true
end


function onEquipped()
	UnsheathSound:play()
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)


connection = sword.Touched:connect(blow)


