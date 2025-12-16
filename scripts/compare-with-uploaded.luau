local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")

local reflection = roblox.getReflectionDatabase()

local BUILD_DIR = "build"

type ObjectStatus = "ADDED" | "MODIFIED" | "REMOVED"
type Instance = {
	Name: string,
	Parent: Instance?,
}

local ObjectStatus = {
	ADDED = "ADDED" :: "ADDED",
	MODIFIED = "MODIFIED" :: "MODIFIED",
	REMOVED = "REMOVED" :: "REMOVED",
}

local function getGearProjectNameFromId(gearId: number): string
	local gearProjectPath = `src/gear/{gearId}/default.project.json`
	if not fs.isFile(gearProjectPath) then
		error(`Cannot find default.project.json for gear {gearId}`)
	end

	local decodedRojoProject = serde.decode("json", fs.readFile(gearProjectPath))
	if decodedRojoProject == nil or decodedRojoProject.name == nil then
		error(`No name found in default.project.json for gear {gearId}`)
	end

	return decodedRojoProject.name
end

local function getObjectPathFromRoot(object: Instance?): { string }
	local objectPath: { string } = {}

	while object ~= nil do
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

local function buildGear(gearId: number): string
	if not fs.isDir(BUILD_DIR) then
		fs.writeDir(BUILD_DIR)
	end

	local outputPath = `{BUILD_DIR}/{gearId}.rbxm`
	if fs.isFile(outputPath) then
		fs.removeFile(outputPath)
	end

	local buildProcess = process.exec(`rojo build src/gear/{gearId}/default.project.json --output {outputPath}`, nil, {
		shell = "bash",
	})
	if not buildProcess.ok then
		error(
			`{stdio.color("red")}Error while generating rbxm for gear {gearId} {stdio.color("reset")}\n{buildProcess.stderr}`
		)
	end

	return fs.readFile(outputPath)
end

type PathModification = {
	path: string,
	status: ObjectStatus,
	oldValue: any?,
	newValue: any?,
}
local function compareGear(gearId: number)
	-- Find all diffs with instances & property values
	local uploadedGearFile = fs.readFile(`assets/{gearId}.rbxm`)
	local uploadedGearObject = roblox.deserializeModel(uploadedGearFile)[1]
	local generatedGearFile = buildGear(gearId)
	local generatedGearObject = roblox.deserializeModel(generatedGearFile)[1]

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
		local oldObjectsToCheck = { oldObject, table.unpack(oldObject:GetDescendants()) }
		for _, objectToCheck in oldObjectsToCheck do
			local crossReferencedObjectToCheck = crossReferenceObject(objectToCheck, newObject)

			if crossReferencedObjectToCheck == nil then
				local path = objectToCheck:GetFullName()
				addModification(path, {
					path = path,
					status = if reverseModification then ObjectStatus.ADDED else ObjectStatus.REMOVED,
				})
				continue
			end

			local class = reflection:GetClass(objectToCheck.ClassName)
			for _, prop in class.Properties do
				if class.DefaultProperties[prop.Name] == nil then
					-- Likely no property value should be set --
					continue
				end

				local oldPropertyValue = objectToCheck[prop.Name]
				local newPropertyValue = crossReferencedObjectToCheck[prop.Name]
				if oldPropertyValue ~= newPropertyValue then
					local path = `{objectToCheck:GetFullName()}.{prop.Name}`
					addModification(path, {
						path = path,
						status = ObjectStatus.MODIFIED,
						oldValue = if prop.Name == "Source" and objectToCheck:IsA("Script")
							then "[ SOURCE TRUNCATED ]"
							else oldPropertyValue,
						newValue = if prop.Name == "Source" and objectToCheck:IsA("Script")
							then "[ SOURCE TRUNCATED ]"
							else newPropertyValue,
					})
				end
			end
		end
	end

	findDiffs(uploadedGearObject, generatedGearObject)
	findDiffs(generatedGearObject, uploadedGearObject, true)

	-- If there's no modifications, return early
	if next(modificationsByPath) == nil then
		return nil
	end

	-- Re-sort by modification category to export
	local modificationsByCategory = {
		[ObjectStatus.ADDED] = {},
		[ObjectStatus.MODIFIED] = {},
		[ObjectStatus.REMOVED] = {},
	}
	for _, modification in modificationsByPath do
		table.insert(modificationsByCategory[modification.status], modification)
	end

	-- Sort each category alphabetically by path
	for _, modifications in modificationsByCategory do
		table.sort(modifications, function(a, b)
			return a.path < b.path
		end)
	end

	return modificationsByCategory
end

local allGearModifications = {}
for _, gearId in fs.readDir(`src/gear`) do
	if fs.isDir(`src/gear/{gearId}`) then
		allGearModifications[gearId] = compareGear(gearId)
	end
end

local statusesToMarkdownText = {
	[ObjectStatus.ADDED] = "Additions",
	[ObjectStatus.MODIFIED] = "Modifications",
	[ObjectStatus.REMOVED] = "Removals",
}
print("# 🛠️ Gear Changes\n")
for gearId, gearModifications in allGearModifications do
	print(`## [🔗 {getGearProjectNameFromId(gearId)}](https://roblox.com/catalog/{gearId}/)\n`)

	for category, categoryModifications in gearModifications do
		if #categoryModifications == 0 then
			continue
		end

		print(`### {statusesToMarkdownText[category]}\n`)

		for _, modification in categoryModifications do
			local path = modification.path

			if category == ObjectStatus.MODIFIED then
				print(
					`- 🟡 \`{path}\` **{modification.status}**: \`{modification.oldValue}\` --> \`{modification.newValue}\``
				)
			elseif category == ObjectStatus.ADDED then
				print(`- 🟢 \`{path}\` **{modification.status}**`)
			elseif category == ObjectStatus.REMOVED then
				print(`- 🔴 \`{path}\` **{modification.status}**`)
			end
		end

		print()
	end
end
