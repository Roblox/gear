local Debris = Game:GetService('Debris')
local Character = script.Parent
local Humanoid = Character:FindFirstChild('Humanoid')
local BAV = script:WaitForChild('BAV')
local Torso = Character:FindFirstChild('Torso')

if Humanoid then
	Humanoid.PlatformStand = true
	if Torso then
		BAV.angularvelocity = Vector3.new(math.random(1,5), (12 + math.random(0,8)), math.random(1,5))
		BAV.Parent = Torso
	end
	wait(1)
	if BAV then
		BAV:Destroy()
	end
	wait(2)
	Humanoid.PlatformStand = false
end

wait(3)
script:Destroy()
