debris = game:GetService("Debris")

FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local sounds = {script.Parent.MoneySound1, script.Parent.MoneySound2, script.Parent.MoneySound3}

local meshsize = script.Parent.Mesh.Scale

local buck = nil


buck = Instance.new("Part")
buck.formFactor = 2
buck.Size = Vector3.new(2,.4,1)
buck.BrickColor = BrickColor.new("Br. yellowish orange")
buck.TopSurface = 0
buck.BottomSurface = 0
buck.Elasticity = .01 

local d = Instance.new("Decal")
d.Face = 4
d.Texture = "http://www.roblox.com/asset/?id=19354292"
d.Parent = buck

local d2 = d:Clone()
d2.Face = 1
d2.Parent = buck

function MakeABuck(pos)

	local limit = 15

	for i=1,limit do

		local b = buck:Clone()
		local v = Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5).unit
		b.CFrame = CFrame.new(pos + (v * 2) + Vector3.new(0,4,0), v)
		b.Parent = game.Workspace
		debris:AddItem(b, 60)
	end

end

function update(big)
	if big then
		script.Parent.Mesh.Scale = meshsize * 1.5
	else
		script.Parent.Mesh.Scale = meshsize
	end
end


function blowUp()
	local sound = Instance.new("Sound")
		sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
		sound.Parent = script.Parent
		sound.Volume = 1
		sound:play()

	MakeABuck(script.Parent.Position + Vector3.new(0,4,0))


	explosion = Instance.new("Explosion")
	explosion.BlastRadius = 12
	explosion.BlastPressure = 100000 -- these are really wussy units

	-- find instigator tag
	local creator = script.Parent:findFirstChild("creator")
	if creator ~= nil then
		explosion.Hit:connect(function(part, distance)  onPlayerBlownUp(part, distance, creator) end)
	end

	explosion.Position = script.Parent.Position + Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5)
	explosion.Parent = game.Workspace

	for i=1,5 do
		sounds[math.random(1,#sounds)]:Play()
		wait(.1)
	end

	script.Parent.Transparency = 1
end

function onPlayerBlownUp(part, distance, creator)
	if part.Name == "Head" then
		local humanoid = part.Parent.Humanoid
		tagHumanoid(humanoid, creator)
	end
end

function tagHumanoid(humanoid, creator)
	-- tag does not need to expire iff all explosions lethal
	
	if creator ~= nil then
		local new_tag = creator:clone()
		new_tag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

local counter = .6
local big = true
while counter > .03 do
	wait(counter)
	counter = counter * .8
	update(big)
	big = not big
end


blowUp()
wait(.1)
script.Parent:remove()
