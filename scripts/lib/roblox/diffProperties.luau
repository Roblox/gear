local roblox = require("@lune/roblox")

local reflection = roblox.getReflectionDatabase()

local function diffProperties(instance: Instance)
	local diff: { [string]: any } = {}

	local class = reflection:GetClass(instance.ClassName)
	for _, prop in class.Properties do
		if class.DefaultProperties[prop.Name] == nil or (instance.ClassName == "Script" and prop.Name == "Source") then
			continue
		end

		local propertyValue = instance[prop.Name]
		if propertyValue ~= class.DefaultProperties[prop.Name] then
			local value

			-- There's no way we actually have to serialize properties
			-- ourselves.... right?
			if type(propertyValue) == "userdata" then
				if typeof(propertyValue) == "EnumItem" then
					value = propertyValue.Name
				elseif typeof(propertyValue) == "CFrame" then
					value = { propertyValue:GetComponents() }
				elseif typeof(propertyValue) == "Content" then
					value = propertyValue.Uri
				else
					print("UNSUPPORTED", prop.Name, propertyValue)
				end
			else
				value = propertyValue
			end

			diff[prop.Name] = value
		end
	end

	return diff
end

return diffProperties
