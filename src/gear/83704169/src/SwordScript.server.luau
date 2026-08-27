-- by QuantumSama
-- creates a defensive orb

local r = game:service("RunService")
local debris = game:GetService("Debris")

sword = script.Parent.Handle
Tool = script.Parent

local damage = 5

local default_damage = 5
local slash_damage = 10
local lunge_damage = 19 --also projectile damage

local lastOrbTime = 0

local lungeAnim = nil

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
SlashSound.Parent = sword
SlashSound.Volume = .7

local LungeSound = Instance.new("Sound")
LungeSound.SoundId = "rbxasset://sounds\\swordlunge.wav"
LungeSound.Parent = sword
LungeSound.Volume = .6

local FireSound = Instance.new("Sound")
FireSound.SoundId = "http://www.roblox.com/asset/?id=83674171"
FireSound.Parent = sword
FireSound.Volume = 1


local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1


function blow(hit, dmg)
	if (hit.Parent == nil) then return end -- happens when bullet hits sword


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
				if dmg then 
					humanoid:TakeDamage(dmg)
				else 
					humanoid:TakeDamage(damage)
				end 
				wait(1)
				untagHumanoid(humanoid)
			end
		end
	end
end

function fire(v, part)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")

	--local PewPew = Tool.Handle:FindFirstChild("PewPew")

	--[[
	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=22968437"
		--PewPew.SoundId = "http://www.roblox.com/asset/?id=13510352"
		PewPew.Parent = Tool.Handle
		PewPew.Pitch = 1 --.85
		PewPew.Volume = .85
	end
	--]]

	missile.CFrame = CFrame.new(part.CFrame.p) + Vector3.new(0,10,0)
	missile.Size = Vector3.new(18,18,18)
	--missile.Velocity = v.unit * 300
	missile.BrickColor = BrickColor.new("Really red")
	missile.Transparency = 1
	missile.Shape = 0
	missile.BottomSurface = 0
	missile.TopSurface = 0
	missile.CanCollide = false
	print(missile.CanCollide)
	--missile.Material = Enum.Material.CorrodedMetal
	missile.Elasticity = .05
	missile.Friction = .7
	missile.Name = "FireBall"

	local fire = Instance.new("Fire")
	fire.Size = 25
	--fire.Heat = 20
	--mesh.VertexColor = Vector3.new(0,1,0)
	fire.Parent = missile

	local missiles = {}

	for i = 1, 5 do
		missiles[i] = missile:Clone()
		
		local bv = Instance.new("BodyVelocity")
		bv.velocity = (CFrame.Angles(0,i* 2* math.pi/5,0) * missile.CFrame.lookVector.unit * Vector3.new(1,0,1))* 6 + Vector3.new(0,-4,0)
		--print(bv.velocity)
		bv.Name = "bv"
		bv.maxForce = Vector3.new(999999999999999,9999999999999999999,999999999999999999)
		bv.Parent = missiles[i]
		--missiles[i].CFrame = part.CFrame * CFrame.Angles(math.pi*2*math.random(),0,0)+ Vector3.new(0,10,0)
		debris:AddItem(missiles[i], 15)
		--print("making fireball")
		missiles[i].Parent = game.Workspace
		missiles[i].Touched:connect(function(hit) blow(hit, 5) end)
	end

	FireSound:Play()

	wait(1.75)
		
	for i = 1,5 do
		if missiles[i] and missiles[i].bv then missiles[i].bv.velocity = Vector3.new(0,0,0) end
	end 


	--PewPew:Play()

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

local lunging = false

--function lunge()
--	lunging = true
--	wait(.75)
--	lunging = false
--end

function doLunge()
	print("lunging")
	--makeLargeOrb()
	damage = lunge_damage

	LungeSound:play()

	--local anim = Instance.new("StringValue")
	--anim.Name = "toolanim"
	--anim.Value = "Lunge"
	--anim.Parent = Tool
	lungeAnim:Play()
	
	--force = Instance.new("BodyVelocity")
	--force.velocity = Vector3.new(0,10,0) --Tool.Parent.Torso.CFrame.lookVector * 80
	--force.Parent = Tool.Parent.Torso
	--wait(.25)
	swordOut()
	wait(.25)
	fire(-sword.CFrame.lookVector, sword)
	wait(.25)
	--force.Parent = nil
	--wait(.5)
	swordUp()

	lunging = false
end

function attack()
	--if lunging then return end

	damage = slash_damage
	SlashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
	wait(.2)
	if lunging then doLunge() end
	damage = default_damage
end

local initGrip = Tool.Grip

function swordUp()
	Tool.Grip = initGrip
	--Tool.GripForward = Vector3.new(0,0,1)
	--Tool.GripRight = Vector3.new(-1,0,0)
	--Tool.GripUp = Vector3.new(0,1,0)
end

function swordOut()
	local initTime = tick()
	local time = tick()
	local duration = .25
	local initGrip = Tool.Grip
	while (time - initTime) < duration do
	--local frames =5	for i = 1, frames do
		time = tick()
		Tool.Grip = initGrip * CFrame.Angles( (time - initTime)/duration * math.pi/2,0,0)
		wait()
	end
	
	Tool.Grip = initGrip * CFrame.Angles(math.pi/2,0,0)

	--Tool.GripForward = Vector3.new(0,1,0)
	--Tool.GripRight = Vector3.new(-1,0,0)
	--Tool.GripUp = Vector3.new(0,0,-1)
	wait(.25)
end

function swordAcross()
	-- parry
end


Tool.Enabled = true
local last_attack = r.Stepped:wait() - .2
local t = 0

function onActivated()
	if not Tool.Enabled then

		t = r.Stepped:wait()
		if (t - last_attack < .2) then
			print("Lunging on")
			lunging = true
		end
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
	last_attack = t

	lunging = false
	attack()

	Tool.Enabled = true
end


function onEquipped()
	UnsheathSound:play()
	local vCharacter = Tool.Parent
	local humanoid = vCharacter:findFirstChild("Humanoid") 
	if humanoid ~= nil then lungeAnim = humanoid:LoadAnimation(Tool.Lunge) else print("humanoid error") end
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
--[[
script.ChildAdded:connect(function(child)
	if child:IsA("StringValue") and child.Name == "KeyPress" and child.Value == "q" then
		child:Destroy() 
	end
end)
--]]


connection = sword.Touched:connect(blow)


