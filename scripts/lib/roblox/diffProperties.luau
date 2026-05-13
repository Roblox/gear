local roblox = require("@lune/roblox")

local serializePropertyModule = require("@scripts/lib/roblox/serializeProperty")
local serializeProperty = serializePropertyModule.serializeProperty

local reflection = roblox.getReflectionDatabase()

local function diffProperties(instance: Instance)
	local diff: { [string]: any } = {}

	local class = reflection:GetClass(instance.ClassName)
	while true do
		for _, prop in class.Properties do
			-- Script.Source is dumped to its own `.luau` file by dumpModel.
			if prop.Datatype == "OptionalCFrame" or (instance.ClassName == "Script" and prop.Name == "Source") then
				continue
			end

			local propertyValue
			local propertyReadSuccess = pcall(function()
				propertyValue = instance[prop.Name]
			end)
			if not propertyReadSuccess then
				continue
			end

			if propertyValue == class.DefaultProperties[prop.Name] then
				continue
			end

			local serialized, status = serializeProperty(prop.Datatype, propertyValue)
			if status == "ok" then
				diff[prop.Name] = serialized
			elseif status == "unsupported" then
				print(`UNSUPPORTED {prop.Name} <{prop.Datatype}={tostring(propertyValue)}>`)
			end
		end

		if class.Superclass ~= nil then
			class = reflection:GetClass(class.Superclass)
		else
			break
		end
	end

	return diff
end

return diffProperties
