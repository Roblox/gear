-- PIERCING SWORD --

r = game:service("RunService")
local sword = script.Parent.Handle
local Tool = script.Parent

local vCharacter

local damage = 10

local slash_damage = Tool.SlashDamage
local lunge_damage = Tool.LungeDamage

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
	tempDamage = lunge_damage
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
				print(damage)
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
	damage = slash_damage.Value
	SlashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end

function lunge()
	damage = lunge_damage.Value
	LungeSound:play()


	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = Tool
	
	force = Instance.new("BodyVelocity")
	force.velocity = Vector3.new(0, 5, 0) --Tool.Parent.Torso.CFrame.lookVector * 80
	force.Parent = Tool.Parent.HumanoidRootPart
	wait(.2)
	swordOut()
	wait(.2)
	force.Parent = nil
	wait(.4)
	swordUp()
	damage = slash_damage.Value
end

function swordUp()
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(0, 1, 0)	
end

function swordOut()
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1, 0)	
	Tool.GripForward = Vector3.new(0, 0, 1)
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

	local vCharacter = Tool.Parent;
	local humanoid = vCharacter:FindFirstChild("Humanoid")
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

	--wait(0.5)

	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent
	UnsheathSound:play()	
end

function onUnequipped()
	if vCharacter then 
		berserkScript = vCharacter:FindFirstChild("BerserkerScript")
		if berserkScript then 
			berserkScript:Remove() 
		end
	end
	if Tool then 
		Tool.SlashDamage.Value = 16.0
		Tool.LungeDamage.Value = 20.0
	end	

	eye = sword:FindFirstChild("Eye")
	if eye then eye:Remove() end
end



Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)

