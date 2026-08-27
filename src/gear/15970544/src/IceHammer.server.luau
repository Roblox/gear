-------- OMG HAX
debris = game:GetService("Debris")
r = game:service("RunService")


local damage = 18


local slash_damage = 18


sword = script.Parent.Handle
Tool = script.Parent


local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "http://www.roblox.com/asset/?id=15933756"
SlashSound.Parent = sword
SlashSound.Volume = 1


local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "http://www.roblox.com/asset/?id=15933756"
UnsheathSound.Parent = sword
UnsheathSound.Volume = 1

local blues = {23,107,102,11,45,135}


function isTurbo(character)
	return character:FindFirstChild("IceHelm") ~= nil
end

function allThatIce(pos, isTurbo)

	local count = 5
	if (isTurbo == true) then count = 10 end

	for i=1,count do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new(blues[math.random(#blues)])
		p.formFactor = 2
		p.Size = Vector3.new(1,.4,1)
		p.Material = Enum.Material.Ice
		p.TopSurface = 0
		p.BottomSurface = 0
		
		local a = math.random() * 6.28
		local d = Vector3.new(math.cos(a), 0, math.sin(a)).unit
		p.Velocity = d * 25
		p.RotVelocity = d
		p.Position = pos + Vector3.new(0, math.random() * 3, 0) + (d * 2)
		p.Parent = game.Workspace

		debris:AddItem(p, 60)
	end

end


function blow(hit)
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
				if (isTurbo(vCharacter) == true) then
					humanoid:TakeDamage(damage * 1.2)
				else
					humanoid:TakeDamage(damage)
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
	debris:AddItem(creator_tag, 1)
end




function attack()
	damage = slash_damage
	SlashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
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



Tool.Enabled = true

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

	

	attack()
	wait(.2)
	allThatIce(character.Torso.Position + (character.Torso.CFrame.lookVector * 3), isTurbo(character))

	wait(1)

	Tool.Enabled = true
end


function onEquipped()
	UnsheathSound:play()
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)


connection = sword.Touched:connect(blow)


