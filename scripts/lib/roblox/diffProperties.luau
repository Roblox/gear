local roblox = require("@lune/roblox")

local serializePropertyModule = require("@scripts/lib/roblox/serializeProperty")
local serializeProperty = serializePropertyModule.serializeProperty

local reflection = roblox.getReflectionDatabase()

type Instance = roblox.Instance

local function diffProperties(instance: Instance)
	local diff: { [string]: any } = {}

	-- Properties are read by name from reflection data, which the type checker
	-- cannot verify against a concrete instance.
	local dynamicInstance = instance :: any

	local class = reflection:GetClass(instance.ClassName)
	while class ~= nil do
		for _, prop in class.Properties do
			-- Script.Source is dumped to its own `.luau` file by dumpModel.
			if instance.ClassName == "Script" and prop.Name == "Source" then
				continue
			end

			local propertyValue
			local propertyReadSuccess = pcall(function()
				propertyValue = dynamicInstance[prop.Name]
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

		local superclass = class.Superclass
		class = if superclass ~= nil then reflection:GetClass(superclass) else nil
	end

	return diff
end

return diffProperties
