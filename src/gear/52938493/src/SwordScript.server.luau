-- INFUSION BLADE
-- Does upto 48 Damage per hit if health gets lower -- 
-- Lunge is 30 damage
-- Slash is 24 damage


r = game:service("RunService") 

local Sword = script.Parent.Handle 
local Tool = script.Parent 

local damage = Tool.Damage
local tempDamage = 20

local slash_damage 
local lunge_damage 

local vCharacter 
local myHumanoid
local connection

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

function infuse()
	local ratio = myHumanoid.Health/myHumanoid.MaxHealth
	if ratio < 0.6 and myHumanoid.Health > 0 then 
		damage.Value = math.min(48, damage.Value /(1.6 * ratio))
		tempDamage = damage.Value
	else 	
		damage.Value = 24
		tempDamage = damage.Value
	end
end

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
			if (joint ~= nil and (joint.Part0 == Sword or joint.Part1 == Sword)) then 
				tagHumanoid(humanoid, vPlayer) 
				humanoid:TakeDamage(damage.Value)
			end 
		end 
	end 
end 

function tagHumanoid(humanoid, player) 
	local creator_tag = Instance.new("ObjectValue") 
	creator_tag.Value = player 
	creator_tag.Name = "creator" 
	creator_tag.Parent = humanoid 
	game.Debris:AddItem(creator_tag, 1) 
end 

function attack() 
	if tempDamage >= 48 then slash_damage = tempDamage else slash_damage = tempDamage * 1.2 end
	damage.Value = slash_damage 
	SlashSound:play() 
	local anim = Instance.new("StringValue") 
	anim.Name = "toolanim" 
	anim.Value = "Slash" 
	anim.Parent = Tool 
end 

function lunge() 
	if tempDamage >= 48 then lunge_damage = tempDamage else lunge_damage = tempDamage * 1.5 end
	damage.Value = lunge_damage 

	LungeSound:play() 

	local anim = Instance.new("StringValue") 
	anim.Name = "toolanim" 
	anim.Value = "Lunge" 
	anim.Parent = Tool 

	local force = Instance.new("BodyVelocity") 
	force.velocity = Vector3.new(0,80,0) 
	--force.Parent = Tool.Parent.Torso 
	wait(.25) 
	force.velocity = (Tool.Parent.HumanoidRootPart.CFrame.lookVector * 120) + Vector3.new(0, 60,0) 
	swordOut() 
	wait(.5) 
	force.Parent = nil 
	wait(.5) 
	swordUp() 

	damage.Value = tempDamage 
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
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid then 
		connection = myHumanoid.HealthChanged:connect(infuse)
	end
end 

function onUnequipped()
	if connection then connection:disconnect() end
end

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped)


Sword.Touched:connect(blow) 

