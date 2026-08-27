local Part = script.Parent
local hitCharacter = Part.Parent
local hitHumanoid = hitCharacter:FindFirstChild("Humanoid")

local Fire = Instance.new("Fire")
Fire.Size = Part:GetMass() * 2
Fire.Heat = Part:GetMass() * 2
Fire.Parent = Part

if hitHumanoid then
	for i = 1, 5 do
		hitHumanoid:TakeDamage(1)
		wait(1)
	end
else
	wait(5)
end

Fire:Remove()
script:Remove()
