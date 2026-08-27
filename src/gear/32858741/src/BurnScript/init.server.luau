local fire = script.Parent
local debris = game:GetService("Debris")
local con = nil

function onTouched(part)

	if part.Parent == nil then return end
	if string.find(fire.Name,part.Parent.Name) ~= nil then return end
	if part.Parent:FindFirstChild("Humanoid") then
		if part:FindFirstChild(fire.Name) == nil then
			burn = script.Burner:clone()
			burn.Parent = part.Parent
			burn.Disabled = false
			local firer = Instance.new("Fire")
			firer.Color = Color3.new(1,117/255,57/255)
			firer.Parent = part
			debris:AddItem(firer,12)
			con:disconnect()
		end
	end

end

con = fire.Touched:connect(onTouched)

