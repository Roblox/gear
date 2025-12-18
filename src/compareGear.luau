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

local function getFullNameFromGearCollectionRoot(instance: Instance?): string
	if typeof(instance) ~= "Instance" then
		return tostring(instance)
	end
	local fullName =
		instance:GetFullName():gsub("^ReplicatedStorage.Src.gear(.?)", ""):gsub("^ReplicatedStorage.Assets(.?)", "")
	return fullName
end

local function getObjectPathFromRoot(object: Instance?): { string }
	local objectPath: { string } = {}

	while object ~= nil and getFullNameFromGearCollectionRoot(object) ~= "" do
		table.insert(objectPath, 1, object.Name)
		object = object.Parent
	end

	return objectPath
end

local function crossReferenceObject(referenceObject: Instance, targetTree: Instance)
	local referenceObjectPath = getObjectPathFromRoot(referenceObject)
	local object = targetTree
	for pathIndex = 2, #referenceObjectPath do
		local pathNode = referenceObjectPath[pathIndex]

		object = object:FindFirstChild(pathNode)
		if object == nil then
			return nil
		end
	end
	return object
end

local function compareGear(
	oldGear: Instance?,
	newGear: Instance?
): ({
	ADDED: { PathModification },
	MODIFIED: { PathModification },
	REMOVED: { PathModification },
}, boolean)
	local modificationsByPath: {
		[string]: PathModification,
	} = {}
	local function addModification(path: string, modification: PathModification)
		if modificationsByPath[path] then
			return
		end
		modificationsByPath[path] = modification
	end

	local function findDiffs(oldObject, newObject, reverseModification: boolean?)
		local function diffForObject(objectToCheck)
			local creationDeletionStatus = if reverseModification then ObjectStatus.ADDED else ObjectStatus.REMOVED
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
					if prop.Name == "Parent" then
						continue
					end

					local oldPropertyValue, newPropertyValue
					local propertyReadSuccess = pcall(function()
						oldPropertyValue = if reverseModification
							then crossReferencedObjectToCheck[prop.Name]
							else objectToCheck[prop.Name]
						newPropertyValue = if reverseModification
							then objectToCheck[prop.Name]
							else crossReferencedObjectToCheck[prop.Name]
					end)
					if not propertyReadSuccess then
						-- Error reading property, probably shouldn't be read --
						continue
					end
					if oldPropertyValue ~= newPropertyValue then
						local path = `{getFullNameFromGearCollectionRoot(objectToCheck)}.{prop.Name}`
						local oldValue = if prop.Name == "Source" and objectToCheck:IsA("Script")
							then "[ SOURCE TRUNCATED ]"
							else oldPropertyValue
						local newValue = if prop.Name == "Source" and objectToCheck:IsA("Script")
							then "[ SOURCE TRUNCATED ]"
							else newPropertyValue
						addModification(path, {
							path = path,
							status = ObjectStatus.MODIFIED,
							oldValue = oldValue,
							newValue = newValue,
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

		diffForObject(oldObject)
	end

	findDiffs(oldGear, newGear)
	findDiffs(newGear, oldGear, true)

	local modificationsByCategory = {
		[ObjectStatus.ADDED] = {},
		[ObjectStatus.MODIFIED] = {},
		[ObjectStatus.REMOVED] = {},
	}

	local modificationsPresent = false
	-- If there's no modifications, return early
	if next(modificationsByPath) ~= nil then
		modificationsPresent = true

		-- Re-sort by modification category to export
		for _, modification in modificationsByPath do
			table.insert(modificationsByCategory[modification.status], modification)
		end

		-- Sort each category alphabetically by path
		for _, modifications in modificationsByCategory do
			table.sort(modifications, function(a, b)
				return a.path < b.path
			end)
		end
	end

	return modificationsByCategory, modificationsPresent
end

return compareGear
