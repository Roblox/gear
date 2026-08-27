wait()
local tool = script.Parent
local EggPhone = require(script.EggPhone)

tool.Equipped:Connect(function()
	if EggPhone.Enabled == false then
		EggPhone:Open()
	end
end)

tool.Unequipped:Connect(function()
	if EggPhone.Enabled == true then
		EggPhone:Close()
	end
end)