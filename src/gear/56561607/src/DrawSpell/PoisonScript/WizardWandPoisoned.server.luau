local Part = script.Parent
local hitCharacter = Part.Parent
if not hitCharacter then script:Remove() end
local hitHumanoid = hitCharacter:FindFirstChild("Humanoid")

if hitHumanoid then
	local oldBrickColor = Part.BrickColor
	Part.BrickColor = BrickColor.new("Bright violet")
	for i = 1, 15 do
		hitHumanoid:TakeDamage(1.3)
		wait(1)
	end
	Part.BrickColor = oldBrickColor
end

script:Remove()