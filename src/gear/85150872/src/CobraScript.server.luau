--Updated for R15 avatars by StarWars
local Character = script.Parent 
local Humanoid = Character:WaitForChild("Humanoid")
local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

Humanoid.WalkSpeed = 13.0 

local Duration = 5.0 

local RBX_Debris = game:GetService('Debris')

local fire = Instance.new('Fire')
fire.Parent = Torso 
fire.Color = Color3.new(0, 1, 0)
fire.Size = 8 

RBX_Debris:AddItem(fire, 5.5) 

while Duration > 0.0 do 
	Duration = Duration - wait(0.2)
	wait()
	Humanoid:TakeDamage(1)
end  

Humanoid.WalkSpeed = 16.0 

script:Destroy() 