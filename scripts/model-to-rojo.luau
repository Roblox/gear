local fs = require("@lune/fs")
local roblox = require("@lune/roblox")

local reflection = roblox.getReflectionDatabase()

local game = roblox.deserializePlace(fs.readFile("gravity_coil.rbxlx"))
local tool = game.StarterPack.GravityCoil

local function diffProperties(instance: Instance)
	local class = reflection:GetClass(instance.ClassName)
	for name, prop in class.Properties do
		if class.DefaultProperties[prop.Name] == nil then
			continue
		end
		-- local success, propertyValueOrErr = pcall(function()
		-- 	return instance[prop.Name]
		-- end)
		-- if not success then
		-- 	warn(propertyValueOrErr)
		-- 	continue
		-- end

		local propertyValue = instance[prop.Name]
		if propertyValue ~= class.DefaultProperties[prop.Name] then
			print(`{instance:GetFullName()} has a modified {prop.Name} property: {propertyValue}`)
		end
	end
end

diffProperties(tool)
for _, instance in tool:GetDescendants() do
	diffProperties(instance)
end
