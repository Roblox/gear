-------- OMG HAX

r = game:service("RunService")
debris = game:GetService("Debris")

local damage = 3

local myHumanoid = nil

local slash_damage = 6

sword = script.Parent.Handle
Tool = script.Parent



local SmashSound = Instance.new("Sound")
--SmashSound.SoundId = "http://www.roblox.com/asset/?id=21433696"
SmashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
SmashSound.Parent = sword
SmashSound.Volume = .7
SmashSound.Pitch = 1

local SmashSound2 = Instance.new("Sound")
--SmashSound2.SoundId = "http://www.roblox.com/asset/?id=21433711"
SmashSound2.SoundId = "rbxasset://sounds\\swordlunge.wav"
SmashSound2.Parent = sword
SmashSound2.Volume = .7
SmashSound2.Pitch = .4

local SmashSound3 = Instance.new("Sound")
SmashSound3.SoundId = "rbxasset://sounds\\swordslash.wav"
SmashSound3.Parent = sword
SmashSound3.Volume = .2
SmashSound3.Pitch = 2

local sounds = {SmashSound, SmashSound2, SmashSound3}

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = .5
UnsheathSound.Pitch = 1.5


function blow(hit)

	if (Tool.Enabled) then return end -- only damages on a swing
	if hit == nil or hit.Parent == nil then return end

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

	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end

function swordUp()
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripRight = Vector3.new(-1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function swordOut(angle)
	Tool.GripForward = Vector3.new(math.sin(angle),-math.cos(angle),0)
	Tool.GripRight = Vector3.new(-math.cos(angle),math.sin(angle),0)
	Tool.GripUp = Vector3.new(0,0,1)

	--Tool.GripForward = Vector3.new(0,-math.cos(angle),-math.sin(angle))
	--Tool.GripUp = Vector3.new(0,-math.sin(angle),math.cos(angle))
end

function swordAcross()
	-- parry
end


Tool.Enabled = true
local last_attack = -5
local charge = 0
local dragonFire = nil
function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	print(charge)

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	swordOut(math.pi/40 * charge)

	t = r.Stepped:wait()

	if (t - last_attack < .5) then
		sounds[3]:Play()
		attack()
		if charge < 60 then
			wait(.05)
			swordOut(math.pi/40 * (charge + 1))
			wait(.05)
			swordOut(math.pi/40 * (charge + 2))
			wait(.05)
			swordOut(math.pi/40 * (charge + 3))
			charge = charge + 4

		if dragonFire == nil or dragonFire.Parent == nil then
			dragonFire = Instance.new("Part")
			dragonFire.Name = "DragonFire"
			dragonFire.CanCollide = false
			dragonFire.Shape = 0
			dragonFire.Size = Vector3.new(charge/15,charge/15,charge/15)
			dragonFire.Transparency = 0
			dragonFire.CFrame = Tool.Handle.CFrame
			dragonFire.Material = "Corroded Metal"
			dragonFire.BrickColor = BrickColor.new("Bright red")
			dragonFire.TopSurface = 0
			dragonFire.BottomSurface = 0

			dragonWeld = Instance.new("Weld")
			dragonWeld.Name = "DragonWeld"
			dragonWeld.Part0 = dragonFire
			dragonWeld.Part1 = Tool.Handle
			dHeat = Instance.new("Fire")
			dHeat.Color = Color3.new(1,0,0)
			dHeat.SecondaryColor = Color3.new(0,1,0)
			dHeat.Heat = charge / 3
			dHeat.Name = "DragonHeat"
			dHeat.Size = charge / 10
			dHeat.Parent = dragonFire
			dragonFire.Parent = Tool
			dragonWeld.Parent = dragonFire
		end

		dHeat = dragonFire.DragonHeat
		dHeat.Heat = charge / 3
		dHeat.Size = charge / 10
		dragonFire.Size = Vector3.new(charge/15, charge/15, charge/15)
		dragonWeld = Instance.new("Weld")
		dragonWeld.Name = "DragonWeld"
		dragonWeld.Part0 = dragonFire
		dragonWeld.C1 = CFrame.new(0,0,5)
		dragonWeld.Part1 = Tool.Handle
		dragonWeld.Parent = dragonFire

		else wait(.15) end

	else
		
	

		attack()

		if charge > 0 and myHumanoid ~= nil then 
			sounds[2]:Play()
			-- fireball!!
			dweld = dragonFire:FindFirstChild("DragonWeld")
			newNV = Instance.new("NumberValue")
			newNV.Name = "Damage"
			newNV.Value = charge
			newNV.Parent = dragonFire
			if dweld ~= nil then dweld:remove() end
			lookAt = myHumanoid.TargetPoint - dragonFire.Position
			dragonFire.Velocity = lookAt.unit*50
			dragonFire.Position = dragonFire.Position + lookAt.unit*5
			dragonFire.Parent = game.Workspace
			dragonFire.CanCollide = true
			dFloat = Instance.new("BodyForce")
			dFloat.force = Vector3.new(0, dragonFire:GetMass()*workspace.Gravity, 0)
			dFloat.Name = "DFloat"
			dFloat.Parent = dragonFire

			dScript = Tool.FireballScript:Clone()
			dScript.Parent = dragonFire
			dScript.Disabled = false

			dragonFire = nil
		end
		if charge <= 0 then
			sounds[1]:Play()
			wait(.1)
		elseif dragonFire ~= nil and dragonFire.Parent ~= nil then
			while dragonFire.Transparency < 1 do
				dragonFire.Transparency = dragonFire.Transparency + .05
				if charge > 0 then 
					charge = charge - 1
					swordOut(math.pi/40 * charge)
				end
				wait(.05)
			end
			while charge > 0 do
				charge = charge - 1
				swordOut(math.pi/40 * charge)
				wait(.05)
			end
			dragonFire:remove()
			wait(2)
		else
			while charge > 0 do
				charge = charge - 2
				swordOut(math.pi/40 * charge)
				wait(.05)
			end
			wait(2)
		end
		-- potentially fire and uncharge
	end

	last_attack = t

	Tool.Enabled = true
end


function onEquipped()
	vChar = Tool.Parent
	myHumanoid = vChar:FindFirstChild("Humanoid")
	UnsheathSound:play()
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)


connection = sword.Touched:connect(blow)


