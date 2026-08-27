local character = script.Parent 
while character:FindFirstChild("Torso") == nil or character:FindFirstChild("Humanoid") == nil do wait() end 

local debris = game:GetService("Debris") 
local torso = character.Torso 
local humanoid = character.Humanoid 

function computeMass(obj)
	local children
	local mass = 0
	if type(obj) == "userdata" then
		children = obj:GetChildren() 
	else 
		children = obj 
	end 

	for i = 1, #children do 
		if children[i]:IsA("BasePart") then 
			mass = mass + children[i]:GetMass()
		end 
		mass = computeMass(children[i]) + mass 		
	end
	return mass
end


local characterMass = computeMass(character) 

if torso:FindFirstChild("GravBF") == nil then 

	local bodyForce = Instance.new("BodyForce")
	bodyForce.force = Vector3.new(0, characterMass * 200.1, 0)
	bodyForce.Name = "GravBF"
	bodyForce.Parent = torso 

	debris:AddItem(bodyForce, 7.0) 
end 

if humanoid then 
	humanoid.WalkSpeed = 6.0 
	wait(7.0)
	humanoid.WalkSpeed = 16.0 
end 

wait(0.5)
script:Remove() 