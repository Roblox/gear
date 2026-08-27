local vCharacter = script.Parent 
local myTorso = vCharacter:FindFirstChild("Torso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local duration = 5

if myHumanoid and myTorso then 
	myHumanoid.WalkSpeed = 14.0 
	local fire = Instance.new("Fire")
	fire.Color = Color3.new(1, 204/255, 0)
	fire.SecondaryColor = Color3.new(1, 204/255, 0)
	fire.Parent = myTorso
	while duration > 0 do
		myHumanoid:TakeDamage(1.5)
		wait(1)
		duration = duration - wait(1)
	end 
	myHumanoid.WalkSpeed = 16.0
	if fire then fire:Remove() end 
end 

wait(2.0)
script:Remove()
