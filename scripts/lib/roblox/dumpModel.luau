local fs = require("@lune/fs")
local serde = require("@lune/serde")

local project = require("@root/project")
local diffProperties = require("@scripts/lib/roblox/diffProperties")
local assignFilesystemNames = require("@scripts/lib/roblox/assignFilesystemNames")
local planReferences = require("@scripts/lib/roblox/planReferences")

local function mkdir(path: string)
	local parts = path:split("/")
	local current
	for _, part in parts do
		if current then
			current ..= `/{part}`
		else
			current = part
		end

		fs.writeDir(current)
	end
end

local function dumpModel(model: Instance, assetId: string)
	local root = `{project.GEAR_PATH}/{assetId}`
	local src = `{root}/src`
	local referencePlan = planReferences(model, `g{assetId}`)

	if fs.isDir(src) then
		fs.removeDir(src)
	end

	local function dumpInstance(instance: Instance, path: string, originalName: string?)
		local hasChildren = #instance:GetChildren() > 0
		local basename = if hasChildren then "init" else instance.Name
		local metadata = referencePlan.getMetadata(instance)
		local attributes = table.clone(metadata.attributes)
		if originalName then
			if instance:GetAttribute(assignFilesystemNames.ORIGINAL_NAME_ATTRIBUTE) ~= nil then
				error(
					`{instance:GetFullName()} already has reserved attribute `
						.. assignFilesystemNames.ORIGINAL_NAME_ATTRIBUTE
				)
			end
			attributes[assignFilesystemNames.ORIGINAL_NAME_ATTRIBUTE] = originalName
		end

		local function addMetadata(document)
			if metadata.id then
				document.id = metadata.id
			end
			if next(attributes) then
				document.attributes = attributes
			end
			return document
		end

		local function writeFile(ext: string, content: string)
			-- The model root has an empty `path`; write its `init.*` files
			-- directly under `src/` (no leading slash) instead of `src//`.
			local prefix = if path == "" then src else `{src}/{path}`
			local dest = if hasChildren then `{prefix}/{basename}{ext}` else `{prefix}{ext}`
			print("write", dest)
			fs.writeFile(dest, content)
		end

		if hasChildren then
			mkdir(if path == "" then src else `{src}/{path}`)
			for _, assignment in
				assignFilesystemNames.assign(instance:GetChildren(), function(child)
					return child.Name
				end)
			do
				local childPath = if path == "" then assignment.filesystemName else `{path}/{assignment.filesystemName}`
				dumpInstance(assignment.instance, childPath, assignment.originalName)
			end
		end

		local diff = diffProperties(instance)

		if instance:IsA("LuaSourceContainer") then
			local ext = ".luau"
			local source = (instance :: any).Source
			if instance:IsA("LocalScript") then
				writeFile(`.client{ext}`, source)
			elseif instance:IsA("Script") then
				writeFile(`.server{ext}`, source)
			elseif instance:IsA("ModuleScript") then
				writeFile(ext, source)
			end

			diff.Source = nil
			writeFile(
				".meta.json",
				serde.encode(
					"json",
					addMetadata({
						["properties"] = diff,
					}),
					true
				)
			)
		else
			if hasChildren then
				writeFile(
					".meta.json",
					serde.encode(
						"json",
						addMetadata({
							["className"] = instance.ClassName,
							["properties"] = diff,
						}),
						true
					)
				)
			else
				writeFile(
					".model.json",
					serde.encode(
						"json",
						addMetadata({
							["ClassName"] = instance.ClassName,
							["Properties"] = diff,
						}),
						true
					)
				)
			end
		end
	end

	local rojoProject = {
		tree = {
			["$path"] = "src",
		},
	}

	fs.writeDir(src)
	fs.writeFile(`{root}/default.project.json`, serde.encode("json", rojoProject, true))

	dumpInstance(model, "")
end

return dumpModel
