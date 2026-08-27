-- Script that will be inserted into the target character for damage over time 

function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do wait() print("Waiting") end
	print("Found Child")
end

waitForChild(script, "Poison")
waitForChild(script, "creator")
poison = script:FindFirstChild("Poison")

local debris = game:GetService("Debris")

local poisonDuration = poison.Value.Y
local poisonDamage = poison.Value.X

local tag = script:FindFirstChild("creator")
local humanoid = script.Parent:FindFirstChild("Humanoid")
local torso = script.Parent:FindFirstChild("Torso")
tag.Parent = humanoid 

local fire 

if torso:FindFirstChild("fire") == nil then
	fire = Instance.new("Fire")
	fire.Parent = torso 
	fire.Color = Color3.new(1, 1, 0)	
	fire.SecondaryColor = Color3.new(1, 1, 0)
	debris:AddItem(fire, 5)
end

while poisonDuration > 0 do 	
	humanoid:TakeDamage(poisonDamage)		
	poisonDuration = poisonDuration - 1
	script.Poison.Value = Vector3.new(script.Poison.Value.X, script.Poison.Value.Y - 1, 0)
	poisonDuration = script.Poison.Value.Y
	wait(1.0)	
end

if fire then fire:Remove() end
if tag then tag:Remove() end

wait(1.0)
script:Remove()