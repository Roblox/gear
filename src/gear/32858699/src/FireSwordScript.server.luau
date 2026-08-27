-------- OMG HAX

r = game:service("RunService")


local damage = 20

local debris = game:GetService("Debris")

sword = script.Parent.Handle
Tool = script.Parent

local humanoid = nil

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "http://www.roblox.com/asset/?id=31758934"
SlashSound.Parent = sword
SlashSound.Volume = .7

local LungeSound = Instance.new("Sound")
LungeSound.SoundId = "http://www.roblox.com/asset/?id=31758956"
LungeSound.Parent = sword
LungeSound.Volume = .6

local Fireball = Instance.new("Sound")
Fireball.SoundId = "http://www.roblox.com/asset/?id=31758982"
Fireball.Parent = sword
Fireball.Volume = 1

function setOnFire(humanoid)

	local stuff = humanoid.Parent.Torso:GetChildren()
	for i = 1, #stuff do
		if stuff[i].className == "Fire" then
			return false
		end
	end
	if Tool.Handle:FindFirstChild("Fire") ~= nil then
		local fire = Tool.Handle.Fire:clone()
		fire.Parent = humanoid.Parent.Torso
		debris:AddItem(fire,10)
	end
	
end

function checkForFireAndX(part)
	local children = part:GetChildren()
	for i = 1, #children do
		if children[i].className == "Fire" then
			children[i]:remove()
		end
	end
end

local hitting = false

function blow(hit)

	if hit.Parent == nil then
		return
	end

	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand

		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) and hitting == false then
				hitting = true
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				checkForFireAndX(hit)
				setOnFire(humanoid)
				wait(1)
				untagHumanoid(humanoid)
				hitting = false
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
	local sound = math.random(1,2)
	if sound == 1 then
		SlashSound:play()
	else
		LungeSound:play()
	end
end

function lunge()

	Tool.Lunge.Value = true

	wait(0.2)
	
	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(31518609)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	Fireball:Play()

	--Continue the insert process
	root = root:FindFirstChild("Fireball")
	root.Position = Tool.Handle.Position + humanoid.Parent.Torso.CFrame.lookVector * 5
	root.Velocity = (humanoid.TargetPoint - Tool.Parent.Head.Position).unit * 100
	root.Parent = game.Workspace
	root.Locked = true

	local script = Tool.FireballScript:clone()
	script.Parent = root
	script.Disabled = false

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,root:GetMass() * 187, 0)
	force.Parent = root

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.cframe = root.CFrame
	bodyGyro.P = 10000
	bodyGyro.D = 1000
	bodyGyro.maxTorque  = Vector3.new(1,1,1) * bodyGyro.P
	bodyGyro.Parent = root

	debris:AddItem(root,10)

	wait(.6)
end

Tool.Enabled = true
local last_attack = -5
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

	wait(.1)

	Tool.Enabled = true
end


function onEquipped()
	humanoid = Tool.Parent:FindFirstChild("Humanoid")
	sword.Sound:Play()
	sword.Fire.Enabled = true
end

function onUnequipped()
	sword.Fire.Enabled = false
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)


