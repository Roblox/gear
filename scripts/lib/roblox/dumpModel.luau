local fs = require("@lune/fs")
local serde = require("@lune/serde")

local project = require("@root/project")
local getInstancePath = require("@scripts/lib/roblox/getInstancePath")
local diffProperties = require("@scripts/lib/roblox/diffProperties")

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

	-- Only clear `src/` so sibling files (rbxasset.toml, post_build.luau) survive.
	if fs.isDir(src) then
		fs.removeDir(src)
	end

	local function dumpInstance(instance: Instance)
		local path = getInstancePath(instance)

		local hasChildren = #instance:GetChildren() > 0
		local basename = if hasChildren then "init" else instance.Name

		local function writeFile(ext: string, content: string)
			local dest = ""
			if hasChildren then
				dest = `{src}/{path}/{basename}{ext}`
			else
				dest = `{src}/{path}{ext}`
			end
			print("write", dest)
			fs.writeFile(dest, content)
		end

		if hasChildren then
			mkdir(`{src}/{path}`)
			for _, child in instance:GetChildren() do
				dumpInstance(child)
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
				serde.encode("json", {
					["properties"] = diff,
				}, true)
			)
		else
			if hasChildren then
				writeFile(
					".meta.json",
					serde.encode("json", {
						["className"] = instance.ClassName,
						["properties"] = diff,
					}, true)
				)
			else
				writeFile(
					".model.json",
					serde.encode("json", {
						["ClassName"] = instance.ClassName,
						["Properties"] = diff,
					}, true)
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

	dumpInstance(model)
end

return dumpModel
