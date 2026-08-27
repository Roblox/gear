local vCharacter = script.Parent 
local myTorso = vCharacter:FindFirstChild("HumanoidRootPart")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local duration = 5

if myHumanoid and myTorso then 
	myHumanoid.WalkSpeed = 9.0 
	local fire = Instance.new("Fire")
	fire.Color = Color3.new(51/255, 51/255, 204/255)
	fire.SecondaryColor = Color3.new(102/255, 0, 1)
	fire.Parent = myTorso
	while duration > 0 do
		myHumanoid:TakeDamage(5.0)
		wait(1)
		duration = duration - wait(1)
	end 
	myHumanoid.WalkSpeed = 16.0
	if fire then
		fire:Destroy()
	end 
end 

wait(2.0)
script:Destroy()
