ball = script.Parent
damage = 25

debris = game:GetService("Debris")
debris:AddItem(ball, 10)

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Pitch = .5
HitSound.Parent = ball

local peanutButter = Instance.new("Part")
peanutButter.BrickColor = BrickColor.new("Nougat")
peanutButter.formFactor = 2
peanutButter.Size = Vector3.new(1,0.4,1)
peanutButter.TopSurface = 0
peanutButter.BottomSurface = 0

local hitSound = Instance.new("Sound")
hitSound.SoundId = "http://www.roblox.com/asset/?id=29504712"
hitSound.Name = "hitSound"
hitSound.Parent = peanutButter

local blownUp = false

function onTouched(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	connection:disconnect()
	local bf = ball:FindFirstChild("BulletFloat")
	if (bf ~= nil) then bf:Remove() end

	if humanoid ~= nil then
		tagHumanoid(humanoid)
		ball.SlowWalkerScript.Disabled = false
		ball.SlowWalkerScript.Parent = humanoid.Parent
		HitSound:Play()
		blowUp()
	end


end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = ball:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
		new_tag.Parent = humanoid
		debris:AddItem(new_tag, 1)
	end
end

function blowUp()

	ball.Transparency = 1

	local sound = Instance.new("Sound")
	sound.SoundId = "http://www.roblox.com/asset/?id=29505543"
	sound.Parent = ball
	sound:Play()

	if blownUp then
		return
	end

	local v = ball.CFrame.lookVector
	local angleIncrement = 0.25
	local angle = 0

	peanutButter.Position = ball.Position
	for i = 1, 25 do

		local butterClone = peanutButter:clone()

		local slowScript = ball.SlowWalkerScript:clone()
		slowScript.Parent = butterClone
		butterClone.SlowWalkerScript.Disabled = false

		local inserter = ball.InsertScript:clone()
		inserter.Parent = butterClone

		butterClone.Position = Vector3.new(butterClone.Position.x + math.random(-5,5),butterClone.Position.y, butterClone.Position.z + math.random(-5,5))
		butterClone.Velocity = Vector3.new(70 * math.cos(angle),math.random(0,90),70 * math.sin(angle))
		butterClone.Parent = game.Workspace

		debris:AddItem(butterClone,15)

		angle = angle + angleIncrement

	end

	blownUp = true

	wait(1.5)
	ball:remove()

end

connection = ball.Touched:connect(onTouched)

wait(3.5)
blowUp()
