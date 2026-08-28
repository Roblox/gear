-- PIERCING SWORD --

r = game:service("RunService")
local sword = script.Parent.Handle
local Tool = script.Parent

local damage = 10

local debris = game:GetService("Debris")

local flareDamage = 5

local co -- Coroutine

local slash_damage = 14
local lunge_damage = 20

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
SlashSound.Parent = sword2
SlashSound.Volume = .7

local LungeSound = Instance.new("Sound")
LungeSound.SoundId = "rbxasset://sounds\\swordlunge.wav"
LungeSound.Parent = sword
LungeSound.Volume = .6

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1


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

function infuse(humanoid)		
	local torso = humanoid.Parent:FindFirstChild("Torso") or humanoid.Parent:FindFirstChild("UpperTorso")
	for i = 1, 3 do
		local fireOne = Instance.new("Fire")
		fireOne.Color = Color3.new(0,0,0)
		if i == 1 then
			fireOne.SecondaryColor = Color3.new(100/255,0,0)
		elseif i == 2 then
			fireOne.SecondaryColor = Color3.new(0,100/255,0)
		else
			fireOne.SecondaryColor = Color3.new(0,0,100/255)
		end
		fireOne.Heat = 0
		fireOne.Size = 15
		fireOne.Parent = torso
	end
	if humanoid then
		for i = 1, 3 do 
			humanoid:TakeDamage(flareDamage)
			wait(1.0)
			if humanoid.Health <= 30 then 
				e = Instance.new("Explosion")
				e.Parent = game.Workspace
				e.Name = "BOOM"
				if torso then 
					e.Position = torso.Position
					print(e.Position)
					e.BlastRadius = 1.0
					e.BlastPressure = 1000000
					debris:addItem(e, 1.5)
					
					local sound = Instance.new("Sound") 
					sound.SoundId = "rbxasset://sounds\\Rocket shot.wav" 
					sound.Parent = script.Parent 
					sound.Volume = 1 
					sound:Play()

					break
				end
			end
		end
		if humanoid then 
			untagHumanoid(humanoid) 
			if torso then 
				children = torso:GetChildren()
				for i = 1, #children do if children[i].className == "Fire" then children[i]:Remove() end end
			end
		end			
	end
end

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
				if co == nil or coroutine.status(co) == "dead" then 					
					co = coroutine.create(infuse)
					coroutine.resume(co, humanoid)
				end				
				humanoid:TakeDamage(damage)								
			end
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

function lunge()
	damage = lunge_damage
	LungeSound:play()


	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = Tool
	
	force = Instance.new("BodyVelocity")
	force.velocity = Vector3.new(0,5,0) --Tool.Parent.Torso.CFrame.lookVector * 80
	force.Parent = Tool.Parent.HumanoidRootPart
	wait(.2)
	swordOut()
	wait(.2)
	force.Parent = nil
	wait(.4)
	swordUp()
	damage = slash_damage
end

function swordUp()
	Tool.GripForward = Vector3.new(1,0,0)
	Tool.GripRight = Vector3.new(0,0,1)
	Tool.GripUp = Vector3.new(0, 1, 0)
end

function swordOut()
	Tool.GripForward = Vector3.new(0, -1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(-1, 0, 0)
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

	--wait(0.5)

	Tool.Enabled = true
end

function onEquipped()	
	UnsheathSound:play()	
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)

connection = sword.Touched:connect(blow)

