local vCharacter = script.Parent
local myHumanoid = vCharacter:FindFirstChild("Humanoid")
local myTorso = vCharacter:FindFirstChild("Torso")

local duration = 3.5

local fire 

if myHumanoid then 
	if myTorso then 
		fire = Instance.new("Fire")
		fire.Parent = myTorso 
		fire.Color = Color3.new(0, 1, 0)
		fire.SecondaryColor = Color3.new(0, 1, 0)
	end 
	while duration > 0 do 
		duration = duration - wait(0.5)
		myHumanoid:TakeDamage(3.5)
		wait(0.5)
	end 
	if fire then fire:Destroy() end 
end 

wait(1.75)
script:Remove() 
