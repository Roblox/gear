local roblox = require("@lune/roblox")

local assignFilesystemNames = require("@scripts/lib/roblox/assignFilesystemNames")
local restoreFilesystemNamesLogic = require("@scripts/lib/roblox/restoreFilesystemNamesLogic")

type Instance = roblox.Instance

local ORIGINAL_NAME_ATTRIBUTE = assignFilesystemNames.ORIGINAL_NAME_ATTRIBUTE

local function restoreFilesystemNames(root: Instance): number
	local adapter: restoreFilesystemNamesLogic.Adapter<Instance> = {
		getChildren = function(instance)
			return instance:GetChildren()
		end,
		getName = function(instance)
			return instance.Name
		end,
		setName = function(instance, name)
			instance.Name = name
		end,
		getOriginalName = function(instance)
			local originalName = instance:GetAttribute(ORIGINAL_NAME_ATTRIBUTE)
			if originalName == nil then
				return nil
			end
			assert(typeof(originalName) == "string", `{ORIGINAL_NAME_ATTRIBUTE} must be a string`)
			return originalName
		end,
		clearOriginalName = function(instance)
			instance:SetAttribute(ORIGINAL_NAME_ATTRIBUTE, nil)
		end,
		-- Rojo reads files lexically, where "__10" sorts before "__2".
		-- Reparent in numeric order so GetChildren() preserves the source
		-- occurrence order after names are restored.
		reparentInOrder = function(parent, instances)
			for _, instance in instances do
				instance.Parent = nil
			end
			for _, instance in instances do
				instance.Parent = parent
			end
		end,
	}
	return restoreFilesystemNamesLogic(root, adapter)
end

return restoreFilesystemNames
