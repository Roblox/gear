local Character = script.Parent 
local Humanoid = Character:WaitForChild('Humanoid') 

local Fire = Instance.new('Fire')
Fire.Color = Color3.new(1, 1, 1)
Fire.Parent = Character:WaitForChild('Torso')

Game:GetService('Debris'):AddItem(Fire, 5.5)

local Duration = 4.5

while Duration > 0 do 
	Humanoid:TakeDamage(11)
	Duration = Duration - wait(0.75)
	wait(0.75)
end 

wait(1.0)
script:Destroy() 
