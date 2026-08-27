-------- OMG HAX

r = game:service("RunService")


local damage = 20

local debris = game:GetService("Debris")

sword = script.Parent.Handle
Tool = script.Parent

local humanoid = nil

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "http://www.roblox.com/asset/?id=32656754"
SlashSound.Parent = sword
SlashSound.Volume = 0.5

local Fireball = Instance.new("Sound")
Fireball.SoundId = "http://www.roblox.com/asset/?id=32656713"
Fireball.Parent = sword
Fireball.Volume = 1

function setOnFrost(humanoid)

	local stuff = humanoid.Parent.Torso:GetChildren()
	for i = 1, #stuff do
		if stuff[i].className == "Fire" then
			return false
		end
	end
	if Tool:FindFirstChild("Frost") ~= nil then
		local fire = Tool.Frost.IceFrost:clone()
		fire.Size = fire.Size * 1.5
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
				setOnFrost(humanoid)
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
	SlashSound.Pitch = math.random(0.5,1)
	SlashSound:Play()
end

function lunge()

	Tool.Lunge.Value = true

	SlashSound.Pitch = math.random(0.5,1)
	SlashSound:Play()

	wait(0.2)
	
	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(32576709)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end

	Fireball:Play()

	--Continue the insert process
	root = root:FindFirstChild("Iceball")
	root.Position = Tool.Handle.Position + humanoid.Parent.Torso.CFrame.lookVector * 5
	root.Velocity = (humanoid.TargetPoint - Tool.Parent.Head.Position).unit * 100
	print(root.Velocity)
	root.Parent = game.Workspace
	root.Locked = true
	root.Anchored = false

	root.Smoke.RiseVelocity = -10

	local script = Tool.IceballScript:clone()
	script.Parent = root
	script.Disabled = false

	local force = Instance.new("BodyForce")
	force.force = Vector3.new(0,root:GetMass() * 195, 0)
	force.Parent = root

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
	Tool.Frost.IceFrost.Enabled = true
	Tool.Handle.LoopSound:Play()
end

function onUnequipped()
	Tool.Frost.IceFrost.Enabled = false
	Tool.Handle.LoopSound:Stop()
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)


