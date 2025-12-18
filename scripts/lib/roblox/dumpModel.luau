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

	if fs.isDir(root) then
		fs.removeDir(root)
	end

	local function dumpInstance(instance: Instance)
		local path = getInstancePath(instance)

		local hasChildren = #instance:GetChildren() > 0

		local basename = if hasChildren then "init" else instance.Name
		local ext = ""
		local content = ""

		if hasChildren then
			mkdir(`{src}/{path}`)
			for _, child in instance:GetChildren() do
				dumpInstance(child)
			end
		end

		if instance:IsA("LuaSourceContainer") then
			ext = ".luau"
			if instance:IsA("LocalScript") then
				ext = `.client{ext}`
			elseif instance:IsA("Script") then
				ext = `.server{ext}`
			end

			content = (instance :: any).Source
		else
			local diff = diffProperties(instance)

			if hasChildren then
				ext = ".meta.json"
				content = serde.encode("json", {
					["className"] = instance.ClassName,
					["properties"] = diff,
				}, true)
			else
				ext = ".model.json"
				content = serde.encode("json", {
					["ClassName"] = instance.ClassName,
					["Properties"] = diff,
				}, true)
			end
		end

		local dest = ""
		if hasChildren then
			dest = `{src}/{path}/{basename}{ext}`
		else
			dest = `{src}/{path}{ext}`
		end
		print("write", dest)
		fs.writeFile(dest, content)
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
