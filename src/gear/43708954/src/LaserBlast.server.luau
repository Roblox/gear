ball = script.Parent
damage = 5

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1

local touchedYet = false

function onTouched(hit)
	if hit == nil or hit.Parent == nil or touchedYet or hit.Name == "DragonXBowArrow" or hit.Parent.Name == "DragonHunterXBow" then return end
	touchedYet = true
	ball.Velocity = Vector3.new(0,0,0)

	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		HitSound:Play()
		humanoid:TakeDamage(damage)
	end

	newWeld = Instance.new("Weld")
	newWeld.Name = "ArrowWeld"
	newWeld.Part0 = hit
	newWeld.Part1 = ball
	--newWeld.C0 = ball.CFrame*hit.CFrame:inverse()
	--script.Parent.CFrame:inverse()*hit.CFrame
	newWeld.C1 = ball.CFrame:inverse()*hit.CFrame
	newWeld.Parent = hit

--	HitSound:Play()
--	ball.Parent = nil
	--print("Hit Ground At: ")
	--print(ball.Position)
end


ball.Touched:connect(onTouched)

local i = 0
while i < 80 and not touchedYet do
	ball.ArrowGyro.cframe = CFrame.new(ball.Position, ball.Position+ball.Velocity)*CFrame.Angles(math.pi/2, 0, math.pi)
	wait(.1)
	i = i + 1
end

while i < 80 do
	wait(.1)
	i = i + 1
end

ball.Parent = nil
