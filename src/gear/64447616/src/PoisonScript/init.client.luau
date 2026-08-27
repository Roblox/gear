local vCharacter = script.Parent
while vCharacter:FindFirstChild("Torso") == nil or vCharacter:FindFirstChild("Humanoid") == nil do 
	print("Waiting")
	wait()
end

local myTorso = vCharacter.Torso
local myHumanoid = vCharacter.Humanoid 

local duration = 13

local eatAnim

while script:FindFirstChild("EatSound") == nil do 
	wait()
end

if script:FindFirstChild("EatAnim") and myHumanoid then
	eatAnim = myHumanoid:LoadAnimation(script.EatAnim)
	eatSound = script.EatSound
	if eatAnim then eatAnim:Play() end
	if eatSound then eatSound:Play() end
	wait(2.2)
end

if vCharacter:FindFirstChild("Apple") then vCharacter.Apple:Remove() end

local smoke = Instance.new("Smoke")
smoke.Parent = myTorso
smoke.Color = Color3.new(0, 1, 0)
smoke.Opacity = 0.5
smoke.RiseVelocity = 0.1

while myHumanoid and duration > 0 do
	myHumanoid:TakeDamage(5)
	myHumanoid.WalkSpeed = 10.0
	duration = duration - 1
	wait(1.0)
end

if smoke then smoke:Remove() end

myHumanoid.WalkSpeed = 16.0

wait(2.0)
script:Remove()
