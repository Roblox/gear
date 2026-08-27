local Tool = script.Parent
local Sword = Tool.Handle

r = game:service("RunService")

local debris = game:GetService("Debris")

local damage = 5

local slashDamage = 14
local lungeDamage = 24

local vCharacter
local vPlayer
local myTorso
local myHumanoid

local connection

Tool.Enabled = true

local slashSound = Instance.new("Sound")
slashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
slashSound.Parent = Sword
slashSound.Volume = .7

local lungeSound = Instance.new("Sound")
lungeSound.SoundId = "rbxasset://sounds\\swordlunge.wav"
lungeSound.Parent = Sword
lungeSound.Volume = .6

local unsheathSound = Instance.new("Sound")
unsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
unsheathSound.Parent = Sword
unsheathSound.Volume = 1

function tagHumanoid(humanoid, player)
	if humanoid then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end

function blow(hit)
	if hit == nil or hit.Parent == nil or vCharacter == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")	
	local vPlayer = game.Players:playerFromCharacter(vCharacter)	
	if humanoid~=nil and humanoid ~= myHumanoid and myHumanoid ~= nil then		
		local rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
		if rightArm then
			local rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then
				if humanoid.Health - damage <= 0 then 
					myHumanoid.WalkSpeed = myHumanoid.WalkSpeed + 1.2 -- Woo
				end
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)			
				humanoid.WalkSpeed = humanoid.WalkSpeed - 1.2				
				if hit then hit.BrickColor = BrickColor.new("Deep orange") end
			end
		end
	end
end

function attack()
	damage = slashDamage
	slashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end

function lunge()
	damage = lungeDamage

	lungeSound:play()

	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = Tool	
	
	local force = Instance.new("BodyVelocity")
	force.velocity = Vector3.new(0, 3, 0) 
	force.Parent = myTorso
	wait(0.25)
	swordOut()
	wait(0.25)
	if force then force:Destroy() end
	wait(0.5)
	swordUp()

	damage = slashDamage
end

function swordUp()	
	Tool.GripUp = Vector3.new(0, -1, 0)	
	Tool.GripForward = Vector3.new(1, 0, 0)		
	Tool.GripRight = Vector3.new(0, 0, 1)				
	Tool.GripUp = Vector3.new(0, -1, 0)	
end

function swordOut()
	Tool.GripForward = Vector3.new(0, -1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(1, 0, 0)
end

local lastAttack = 0

function onActivated()

	if not Tool.Enabled then
		return
	end

	vCharacter = Tool.Parent;
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myHumanoid == nil or myTorso == nil then		
		return 
	end
	
	Tool.Enabled = false

	local t = r.Stepped:wait()
	if (t - lastAttack < 0.2) then
		lunge()
	else
		attack()
	end
	lastAttack = t	
	Tool.Enabled = true
end


function onEquipped()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	unsheathSound:play()
end

function onUnequipped()
	
end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)


connection = Sword.Touched:connect(blow)


