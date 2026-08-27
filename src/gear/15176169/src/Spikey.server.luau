debris = game:GetService("Debris")

local damage = 10

wait(.5)


function newSound(id)
	local sound = Instance.new("Sound")
	sound.Name = "Died"
	sound.SoundId = id
	sound.archivable = false
	return sound
end

-- declarations

local sDied = newSound("rbxasset://sounds/uuhhh.wav")


function playOuch(char)
	local sound = char.Head:FindFirstChild("CaltropOw")
	if (sound == nil) then
		sound = newSound("rbxasset://sounds/uuhhh.wav")
		sound.Parent = char.Head
	end
	sound:Play()
end


function onTouched(hit)


	humanoid = hit.Parent:findFirstChild("Humanoid")
	if humanoid~=nil then

		tagHumanoid(humanoid)

		humanoid:TakeDamage(damage)

		playOuch(humanoid.Parent)


	end
	
end


function tagHumanoid(humanoid, creator)
	-- tag does not need to expire iff all explosions lethal
	
	if creator ~= nil then
		local new_tag = creator:clone()
		new_tag.Parent = humanoid
		debris:AddItem(new_tag, 1)
	end
end

connection = script.Parent.Touched:connect(onTouched)

debris:AddItem(script.Parent, 240)

