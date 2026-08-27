--Made by Luckymaxer

Humanoid = script.Parent
Character = Humanoid.Parent

Debris = game:GetService("Debris")

Creator = script:WaitForChild("Creator")

Health = Humanoid.Health

IgnoreChange = false

Colors = {"Med. yellowish green", "Br. yellowish green", "Medium green", "Tr. Green", "Faded green", "Bright green", "Dark green", "Earth green"}

Parts = {}

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

Humanoid.Changed:connect(function(Property)
	if Property == "Health" then
		if Humanoid.Health < Health and not IgnoreChange then
			local HealthLost = (Health - Humanoid.Health)
			IgnoreChange = true
			UntagHumanoid(Humanoid)
			TagHumanoid(Humanoid, Creator.Value)
			Humanoid:TakeDamage(HealthLost)
			Health = Humanoid.Health
			IgnoreChange = false
		elseif Humanoid.Health >= Health then
			Health = Humanoid.Health
		end
	elseif Property == "Jump" then
		Humanoid.Jump = false
	end
end)

Humanoid.WalkSpeed = (16 / 2)

for i, v in pairs(Character:GetChildren()) do
	if v:IsA("BasePart") then
		table.insert(Parts, {Part = v, BrickColor = v.BrickColor})
	end
end

for i, v in pairs(Colors) do
	for ii, vv in pairs(Parts) do
		if vv.Part and vv.Part.Parent then
			vv.Part.BrickColor = BrickColor.new(v)
		end
	end
	wait(60 / #Colors)
end

for i, v in pairs(Parts) do
	v.Part.BrickColor = v.BrickColor
end

Humanoid.WalkSpeed = 16

script:Destroy()