vChar = script.Parent
humanoid = vChar:FindFirstChild("Humanoid")
torso = vChar:FindFirstChild("Torso") or vChar:FindFirstChild("UpperTorso")

if humanoid ~= nil and torso ~= nil then
	fire = Instance.new("Fire")
	fire.Parent = torso
end

local fireTime = 5.0

while fireTime > 0 do 
	humanoid:TakeDamage(5)	
	fireTime = fireTime - 1
	wait(1.0)
end

tag = humanoid:FindFirstChild("creator")

wait(1.0)
if fire then fire:Destroy() end
if tag then tag:Destroy() end
script:Destroy()


		
