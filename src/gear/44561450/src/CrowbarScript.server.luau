-------- OMG HAX
-- 43645306:  Full LaserSword
-- 43960328:  LaserBlade
-- 43960368:  LaserHandle

r = game:service("RunService")
debris = game:GetService("Debris")

local damage = 5
local held_damage = 5
local slash_damage = 10
local spark_color = Color3.new(0, 1, 1)

sword = script.Parent.Handle
Tool = script.Parent


local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "http://www.roblox.com/asset/?id=11998777"
SlashSound.Pitch = 1
SlashSound.Volume = 1
SlashSound.Parent = sword


local ClashSound = Instance.new("Sound")
ClashSound.SoundId = "http://www.roblox.com/asset/?id=44463749"
ClashSound.Pitch = 1
ClashSound.Volume = .7
ClashSound.Parent = sword


local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "http://www.roblox.com/asset/?id=11998796"
UnsheathSound.Pitch = 1
UnsheathSound.Volume = 1
UnsheathSound.Parent = sword

function waitForChild(parent, childName)
	local child = parent:findFirstChild(childName)
	if child then return child end
	while true do
		child = parent.ChildAdded:wait()
		if child.Name==childName then return child end
	end
end

-- declarations

local Figure = Tool.Parent
local hum = nil

while Figure == nil or Figure.Name == "BackPack" or hum == nil do 
	Figure = Tool.Parent
	if Figure ~= nil then hum = Figure:FindFirstChild("Humanoid") end
	wait(1)
end


local Torso = waitForChild(Figure, "Torso")
local RightShoulder = waitForChild(Torso, "Right Shoulder")
local initialShoulderFrame = nil
--local LeftShoulder = waitForChild(Torso, "Left Shoulder")
--local RightHip = waitForChild(Torso, "Right Hip")
--local LeftHip = waitForChild(Torso, "Left Hip")
--local Neck = waitForChild(Torso, "Neck")
--local Humanoid = waitForChild(Figure, "Humanoid")
--local SwordAngle = waitForChild(sword, "SwordAngle")
--local SwordC1 = waitForChild(sword, "SwordC1")

-- ANIMATION
--local downLeftPose = waitForChild(Tool, "downLeftTest")
--local downRightPose = waitForChild(Tool, "downrightTest")
local downLeftPose = waitForChild(Tool, "DL")
local downRightPose = waitForChild(Tool, "DR")
local upRightPose = waitForChild(Tool, "UR")
local middlePose = waitForChild(Tool, "M")
local upLeftPose = waitForChild(Tool, "upleftTest")

local dL = nil
local dR = nil
local uR = nil
local M = nil
local uL = nil
local prev = nil

print("Got past the intro!")


function blow(hit)

	--if (Tool.Enabled) then return end -- only damages on a swing

	if hit == nil or hit.Parent == nil then return end

	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	if vCharacter == nil then return end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand

		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1)
				untagHumanoid(humanoid)
			end
		end
	elseif humanoid == nil and hum ~= nil then
		if hit.Parent.Name == "LaserSword" then
			humanoid = hit.Parent.Parent
			if humanoid ~= nil then
				humanoid = humanoid:FindFirstChild("Humanoid")
				if humanoid ~= nil then
					-- hit an enemy laserSword which is being held by an opponent, so make sure our sword is in-hand
					local right_arm = vCharacter:FindFirstChild("Right Arm")
					if (right_arm ~= nil) then
						local joint = right_arm:FindFirstChild("RightGrip")
						if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
							if damage > held_damage then
								ClashSound.Pitch = .5 + math.random()*.5
								ClashSound:Play()
							end

							--prev:Stop(.2)
							if prev ~= nil then 
								prev:Stop()
								if M ~= nil and prev ~= M then
									M:Play(.4) 
									prev = M
								end
								damage = held_damage
							end

							-- stop sword's motion!  produce sparks too! :D
							-- sparks here:
							tempSparks = sword:FindFirstChild("LaserSwordSparks")
							if tempSparks == nil then
								tempSparks = Instance.new("Sparkles")
								tempSparks.Color = spark_color
								tempSparks.Parent = sword
								debris:AddItem(tempSparks, .5)
							end

						end
					end
				end
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

Tool.Enabled = true
local waitCount = 0
function onActivated()
	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		Tool.Enabled = true
		return 
	end

	local head = character:FindFirstChild("Head")
	if head == nil then
		print("Head not found")
		Tool.Enabled = true
		return
	end

	local selector = 0
	local targetPos = humanoid.TargetPoint
	local attackVector = head.CFrame:vectorToObjectSpace(targetPos - head.Position)
	if attackVector.y > 0 then selector = selector + 2 end -- ups are later
	if attackVector.x < 0 then selector = selector + 1 end -- rights are odd

	print(attackVector)

	if prev ~= nil then
		if selector == 0 and prev ~= dL then
			prev:Stop()
			dL:Play(.2)
			prev = dL
			waitCount = 2
			damage = slash_damage
			SlashSound.Pitch = .9 + math.random()*.25
			SlashSound:Play()
		elseif selector == 1 and prev ~= dR then
			prev:Stop()
			dR:Play(.2)
			prev = dR
			waitCount = 2
			damage = slash_damage
			SlashSound.Pitch = .9 + math.random()*.25
			SlashSound:Play()
		elseif selector == 2 and prev ~= uL then
			prev:Stop()	
			uL:Play(.2)
			prev = uL
			waitCount = 2
			damage = slash_damage
			SlashSound.Pitch = .9 + math.random()*.25
			SlashSound:Play()
		elseif selector == 3 and prev ~= uR then 
			prev:Stop() 
			uR:Play(.2) 
			prev = uR
			waitCount = 2
			damage = slash_damage
			SlashSound.Pitch = .9 + math.random()*.25
			SlashSound:Play()
		end
	end

	print(selector)

	Tool.Enabled = true
end

function onEquipped()
	damage = held_damage
	Figure = Tool.Parent
	hum = Figure:FindFirstChild("Humanoid")
	if hum == nil then
		print("could not find humanoid!")
		return
	end

	-- give 'em the animations
	dL = hum:LoadAnimation(downLeftPose)
	dR = hum:LoadAnimation(downRightPose)
	uR = hum:LoadAnimation(upRightPose)
	M = hum:LoadAnimation(middlePose)
	uL = hum:LoadAnimation(upLeftPose)

	prev = M

	UnsheathSound.Pitch = .5 + math.random()*.5
	UnsheathSound:Play()

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=43960368"
	Tool.RisingBlade.Transparency = .5

	Tool.FlashyScript.Disabled = true
	Tool.RisingBlade.Mesh.VertexColor = Vector3.new(1,1,1)

	for i = 1, 15 do
		Tool.RisingBlade.Mesh.Scale = Vector3.new(1.5,1.5,0.1*i)
		Tool.Handle.LaserBladeWeld.C0 = CFrame.new(Vector3.new(0,0,0.1*i - 1.5))
		wait(.05)
		if prev == nil then return end
	end

	if prev == M then
		waitCount = 0
		M:Play(.2)
		SlashSound.Pitch = .5 + math.random()*.5
		SlashSound:Play()
	end

	Tool.FlashyScript.Disabled = false

	--UnsheathSound:play()
end

function onUnequipped()
	damage = held_damage
	if prev ~= nil then prev:Stop() prev = nil end
	if dL ~= nil then dL:Stop() end
	if uL ~= nil then uL:Stop() end
	if uR ~= nil then uR:Stop() end
	if dR ~= nil then dR:Stop() end
	if M ~= nil then M:Stop() end

	ClashSound:Stop()
	UnsheathSound:Stop()
	SlashSound:Stop()

	Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=43645306"
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)

connection = sword.Touched:connect(blow)

-- reset to M position after a few seconds of inactivity
while true do
	if waitCount > 0 then
		waitCount = waitCount - 1
		if waitCount == 0 and prev ~= M and prev ~= nil then
			SlashSound.Pitch = .5 + math.random()*.5
			SlashSound:Play()

			damage = held_damage
			prev:Stop()
			M:Play(.2)
			prev = M
		end
	end
	wait(2)
end


