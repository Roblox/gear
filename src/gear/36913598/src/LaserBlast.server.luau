ball = script.Parent
damage = 10

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1

upVect = Vector3.new(0, 1, 0)
speedVect = ball.Velocity
perpVect = speedVect.unit:Cross(upVect)
randAngle = math.random()*math.pi*2 -- get random angle in the perpendicular plane we just solved for
wobbleVect = perpVect*math.cos(randAngle)+upVect*math.sin(randAngle) -- get a random "wobble vector" in the perpendicular plane


function onTouched(hit)
	if hit == nil or hit.Parent == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	ToTB = hit.Parent:findFirstChild("JacksTrickOrTreatBag")
	if ToTB ~= nil then
		power = ToTB:findFirstChild("Power")
		if power ~= nil then
			power.Value = power.Value + 2
		end
	end	

	if humanoid ~= nil then
		--if () then
			HitSound:Play()
			ball.Parent = nil
			humanoid:TakeDamage(10)
		--end
	else
		ball.Parent = nil
	end

--	HitSound:Play()
--	ball.Parent = nil
	--print("Hit Ground At: ")
	--print(ball.Position)
	--ball.Parent = nil
end


connection = ball.Touched:connect(onTouched)

local wobbleSize = 7
local wobbleSpeed = .4

local wobbleFactor = 0
for i = 1,50 do
	ball.RotVelocity = ball.RotVelocity+Vector3.new(0, (math.random()-.5)*2, 0) --see if is z instead of x value...
	ball.Velocity = speedVect+wobbleVect*math.sin(wobbleFactor)*wobbleSize
	wait(.1)
	wobbleFactor = wobbleFactor + wobbleSpeed
end
ball.Parent = nil
