local roblox = require("@lune/roblox")

local reflection = roblox.getReflectionDatabase()

local function diffProperties(instance: Instance)
	local diff: { [string]: any } = {}

	local class = reflection:GetClass(instance.ClassName)
	while true do
		for _, prop in class.Properties do
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

			if propertyValue ~= class.DefaultProperties[prop.Name] then
				local value

				-- There's no way we actually have to serialize properties
				-- ourselves.... right?
				if type(propertyValue) == "userdata" then
					local propType = typeof(propertyValue)
					if propType == "EnumItem" then
						value = propertyValue.Name
					elseif propType == "CFrame" then
						value = { propertyValue:GetComponents() }
					elseif propType == "Content" then
						value = propertyValue.Uri
					elseif propType == "Vector2" then
						value = { propertyValue.X, propertyValue.Y }
					elseif propType == "Vector3" then
						value = { propertyValue.X, propertyValue.Y, propertyValue.Z }
					elseif propType == "Color3" then
						value = { propertyValue.R, propertyValue.G, propertyValue.B }
					else
						print("UNSUPPORTED", prop.Name, propertyValue)
					end
				else
					value = propertyValue
				end

				diff[prop.Name] = value
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
