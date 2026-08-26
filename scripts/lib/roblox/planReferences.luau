local roblox = require("@lune/roblox")
local planReferencesLogic = require("@scripts/lib/roblox/planReferencesLogic")

local reflection = roblox.getReflectionDatabase()

export type Metadata = planReferencesLogic.Metadata
export type Plan = planReferencesLogic.Plan<Instance>

local function planReferences(root: Instance, idPrefix: string): Plan
	local instances = { root }
	for _, descendant in root:GetDescendants() do
		table.insert(instances, descendant)
	end

	local references = {}

	for _, instance in instances do
		local class = reflection:GetClass(instance.ClassName)
		while class do
			for _, property in class.Properties do
				if property.Datatype ~= "Ref" or property.Name == "Parent" then
					continue
				end

				local ok, target = pcall(function()
					return (instance :: any)[property.Name]
				end)
				if not ok or target == nil then
					continue
				end

				table.insert(references, {
					source = instance,
					propertyName = property.Name,
					target = target,
				})
			end

			class = if class.Superclass then reflection:GetClass(class.Superclass) else nil
		end
	end

	return planReferencesLogic(instances, references, idPrefix, function(instance)
		return instance:GetFullName()
	end)
end

return planReferences
