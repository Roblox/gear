local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReflectionService = game:GetService("ReflectionService")

local ObjectStatus = require(ReplicatedStorage.Src.ObjectStatus)
type ObjectStatus = ObjectStatus.ObjectStatus

type PathModification = {
	path: string,
	status: ObjectStatus,
	oldValue: any?,
	newValue: any?,
}

type ModificationsByCategory = {
	ADDED: { PathModification },
	MODIFIED: { PathModification },
	REMOVED: { PathModification },
}

local IGNORED_PROPERTIES: { [string]: string } = {
	IsLoaded = "runtime sound loading state",
	Parent = "covered by walking the tree",
	WorldPivot = "derived from WorldPivotData / bounding box",
}

local function getFullNameFromGearCollectionRoot(instance: Instance?): string
	if typeof(instance) ~= "Instance" then
		return tostring(instance)
	end
	local fullName =
		instance:GetFullName():gsub("^ReplicatedStorage.Src.gear(.?)", ""):gsub("^ReplicatedStorage.Assets(.?)", "")
	return fullName
end

-- For instances with duplicate-named siblings (e.g. BloxyCola's 73 Welds),
-- a Name-only path is ambiguous and `FindFirstChild` silently collapses
-- them. We instead encode each path segment as `Name` (when unique) or
-- `Name#index` (1-based, when duplicates exist), so siblings are paired
-- positionally between the two trees being compared.
local function indexAmongSameNamedSiblings(object: Instance): number?
	local parent = object.Parent
	if parent == nil then
		return nil
	end
	local matches = 0
	local index = nil
	for _, sibling in parent:GetChildren() do
		if sibling.Name == object.Name then
			matches += 1
			if sibling == object then
				index = matches
			end
		end
	end
	if matches > 1 then
		return index
	end
	return nil
end

local function getObjectPathFromRoot(object: Instance?): { string }
	local objectPath: { string } = {}

	while object ~= nil and getFullNameFromGearCollectionRoot(object) ~= "" do
		local idx = indexAmongSameNamedSiblings(object)
		local segment = if idx then `{object.Name}#{idx}` else object.Name
		table.insert(objectPath, 1, segment)
		object = object.Parent
	end

	return objectPath
end

local function findChildByNameAndIndex(parent: Instance, name: string, index: number): Instance?
	local seen = 0
	for _, sibling in parent:GetChildren() do
		if sibling.Name == name then
			seen += 1
			if seen == index then
				return sibling
			end
		end
	end
	return nil
end

-- Path-from-gear-root for any in-gear Instance (e.g. "11419319.Handle").
-- Used to compare Ref-typed properties across the source-asset tree and
-- the built-gear tree without relying on Instance identity (two Refs to
-- "the corresponding Handle" are different Instance objects but logically
-- equivalent).
local function refPathDescriptor(value: any): string
	if value == nil then
		return "<nil>"
	end
	if typeof(value) ~= "Instance" then
		return tostring(value)
	end
	local segments = getObjectPathFromRoot(value)
	if #segments == 0 then
		return `<{value:GetFullName()}>` -- Ref points outside the gear scope
	end
	return table.concat(segments, ".")
end

local function valuesEquivalent(a: any, b: any): boolean
	if a == b then
		return true
	end
	-- Two Refs are equivalent if they resolve to the same path within
	-- their respective gear tree. Catches every Weld.Part0/Part1 case
	-- as well as deprecated lowercase aliases (e.g. `part1`) which
	-- ReflectionService lists separately but share the underlying value.
	if typeof(a) == "Instance" or typeof(b) == "Instance" then
		return refPathDescriptor(a) == refPathDescriptor(b)
	end
	return false
end

local function describeForDiff(value: any, propName: string, instance: Instance): any
	if propName == "Source" and instance:IsA("Script") then
		return "[ SOURCE TRUNCATED ]"
	end
	if typeof(value) == "Instance" or value == nil then
		-- Always serialize Refs as path strings so the diff output is
		-- legible even when both sides happen to share a Name.
		return refPathDescriptor(value)
	end
	return value
end

local function crossReferenceObject(referenceObject: Instance, targetTree: Instance?): Instance?
	local referenceObjectPath = getObjectPathFromRoot(referenceObject)
	local object = targetTree
	for pathIndex = 2, #referenceObjectPath do
		if object == nil then
			return nil
		end

		local pathNode = referenceObjectPath[pathIndex]
		local name, indexStr = string.match(pathNode, "^(.-)#(%d+)$")
		if name and indexStr then
			object = findChildByNameAndIndex(object, name, tonumber(indexStr) :: number)
		else
			object = object:FindFirstChild(pathNode)
		end
	end
	return object
end

local function compareGear(oldGear: Instance?, newGear: Instance?): (ModificationsByCategory, boolean)
	local modificationsByPath: {
		[string]: PathModification,
	} = {}
	local function addModification(path: string, modification: PathModification)
		if modificationsByPath[path] then
			return
		end
		modificationsByPath[path] = modification
	end

	local function findDiffs(oldObject: Instance?, newObject: Instance?, reverseModification: boolean?)
		local function diffForObject(objectToCheck: Instance)
			local creationDeletionStatus: ObjectStatus = if reverseModification
				then ObjectStatus.ADDED
				else ObjectStatus.REMOVED
			local crossReferencedObjectToCheck = crossReferenceObject(objectToCheck, newObject)

			if crossReferencedObjectToCheck == nil then
				local path = getFullNameFromGearCollectionRoot(objectToCheck)
				addModification(path, {
					path = path,
					status = creationDeletionStatus,
				})
				return
			end

			if objectToCheck.ClassName == crossReferencedObjectToCheck.ClassName then
				for _, prop in ReflectionService:GetPropertiesOfClass(objectToCheck.ClassName) do
					if IGNORED_PROPERTIES[prop.Name] then
						continue
					end

					-- Properties are looked up by name from reflection data, which
					-- the type checker cannot verify against a plain Instance.
					local checked = objectToCheck :: any
					local crossReferenced = crossReferencedObjectToCheck :: any

					local oldPropertyValue, newPropertyValue
					local propertyReadSuccess = pcall(function()
						oldPropertyValue = if reverseModification
							then crossReferenced[prop.Name]
							else checked[prop.Name]
						newPropertyValue = if reverseModification
							then checked[prop.Name]
							else crossReferenced[prop.Name]
					end)
					if not propertyReadSuccess then
						-- Error reading property, probably shouldn't be read --
						continue
					end
					if not valuesEquivalent(oldPropertyValue, newPropertyValue) then
						local path = `{getFullNameFromGearCollectionRoot(objectToCheck)}.{prop.Name}`
						addModification(path, {
							path = path,
							status = ObjectStatus.MODIFIED,
							oldValue = describeForDiff(oldPropertyValue, prop.Name, objectToCheck),
							newValue = describeForDiff(newPropertyValue, prop.Name, objectToCheck),
						})
					end
				end
			else
				local path = getFullNameFromGearCollectionRoot(objectToCheck)
				addModification(path, {
					path = path,
					status = ObjectStatus.MODIFIED,
					oldValue = crossReferencedObjectToCheck.ClassName,
					newValue = objectToCheck.ClassName,
				})
			end

			for _, childObject in objectToCheck:GetChildren() do
				diffForObject(childObject)
			end
		end

		if oldObject ~= nil then
			diffForObject(oldObject)
		end
	end

	findDiffs(oldGear, newGear)
	findDiffs(newGear, oldGear, true)

	local modificationsByCategory: ModificationsByCategory = {
		ADDED = {},
		MODIFIED = {},
		REMOVED = {},
	}

	local modificationsPresent = false
	-- If there's no modifications, return early
	if next(modificationsByPath) ~= nil then
		modificationsPresent = true

		-- Re-sort by modification category to export
		for _, modification in modificationsByPath do
			table.insert(modificationsByCategory[modification.status], modification)
		end

		-- Sort each category alphabetically by path. Iterating the record
		-- directly yields `unknown`, so view it as a uniform map first.
		local categories = modificationsByCategory :: { [ObjectStatus]: { PathModification } }
		for _, modifications in categories do
			table.sort(modifications, function(a, b)
				return a.path < b.path
			end)
		end
	end

	return modificationsByCategory, modificationsPresent
end

return compareGear
