local noobTorso = script.Parent
local touching = false

function onTouched(part)
	
	if touching then
		return
	end
	if not part then return end
	if part and not part.Parent then return end
	
	touching = false

	local humanoid = part.Parent:FindFirstChild("Humanoid")
	if part.Parent.Name ~= "n00b" and humanoid ~= nil and noobTorso.Velocity.magnitude > 40 then
		makeNoob(humanoid.Parent)
	end

	touching = true

end

function makeNoob(player)

	local parts = player:GetChildren()
	
	for i = 1, #parts do

		if parts[i]:IsA("CharacterMesh") or parts[i]:IsA("Shirt") or parts[i]:IsA("Pants") or parts[i]:IsA("Accessory") then
			parts[i]:Destroy()
		elseif parts[i].className == "BodyColors" then
			parts[i].HeadColor = BrickColor.new("Medium stone grey")
			parts[i].LeftArmColor = BrickColor.new("Medium stone grey")
			parts[i].LeftLegColor =  BrickColor.new("Medium blue")
			parts[i].RightArmColor =  BrickColor.new("Medium stone grey")
			parts[i].RightLegColor = BrickColor.new("Medium blue")
			parts[i].TorsoColor = BrickColor.new("Bright green")
		end

	end

end


noobTorso.Touched:connect(onTouched)
