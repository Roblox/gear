local vCharacter = script.Parent
local myHumanoid = vCharacter:FindFirstChild("Humanoid")
local myTorso = vCharacter:FindFirstChild("Torso")

if myTorso == nil or myHumanoid == nil then
	script:Remove()
end

local fire = Instance.new("Fire")
fire.Color = Color3.new(1, 0, 0)
fire.SecondaryColor = Color3.new(128/255, 128/255, 128/255)
fire.Parent = myTorso 

local duration = 6 

while duration > 0 do 
	myHumanoid:TakeDamage(4) 
	if myHumanoid.Health < 10 then 
		myHumanoid.Health = 0
	end
	duration = duration - 1 
	wait(1.0)
end

if fire then fire:Remove() end

wait(2.0)
script:Remove()
