local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local CatalogFallbacks = require("@root/src/CatalogFallbacks")
local GearMap = require("@root/src/GearMap")
local catalogStore = require("@root/site/catalogStore")
local pages = require("@root/site/pages")
local project = require("@root/project")

type JsonObject = { [string]: any }
type TreeNode = {
	n: string,
	c: string,
	p: { string },
	k: { TreeNode }?,
}
type CatalogEntry = {
	id: number,
	name: string,
	description: string,
	creator: string,
	created: string?,
	price: number?,
	priceStatus: string?,
	favorites: number?,
	thumbnail: string,
	instances: number,
	classes: { [string]: number },
}

local gearNames = GearMap :: { [string]: string? }
local catalogFallbacks = CatalogFallbacks :: { [string]: string? }

local function friendlyName(name: string): string
	if name:find(" ", 1, true) then
		return name
	end
	local spaced = name:gsub("_", " ")
	spaced = spaced:gsub("(%u+)(%u%l)", "%1 %2")
	spaced = spaced:gsub("(%l)(%u)", "%1 %2")
	spaced = spaced:gsub("(%d)(%u)", "%1 %2")
	spaced = spaced:gsub("%s+", " ")
	return spaced
end

local function copyDirectory(source: string, destination: string)
	fs.writeDir(destination)
	for _, name in fs.readDir(source) do
		if not name:match("%.luau$") and name ~= "data" then
			local sourcePath = `{source}/{name}`
			local destinationPath = `{destination}/{name}`
			if fs.isDir(sourcePath) then
				copyDirectory(sourcePath, destinationPath)
			else
				fs.writeFile(destinationPath, fs.readFile(sourcePath))
			end
		end
	end
end

local function readJson(path: string): JsonObject
	return serde.decode("json", fs.readFile(path)) :: JsonObject
end

local function metadataFields(document: JsonObject): (string, string, { string })
	local properties: JsonObject = document.properties or document.Properties or {}
	local className = document.className or document.ClassName or properties.ClassName or "Instance"
	local name = properties.Name or className
	local propertyNames: { string } = {}
	for propertyName in properties do
		table.insert(propertyNames, propertyName)
	end
	table.sort(propertyNames)
	return tostring(name), tostring(className), propertyNames
end

local function leafNode(path: string): TreeNode
	local name, className, properties = metadataFields(readJson(path))
	return {
		n = name,
		c = className,
		p = properties,
	}
end

local function directoryNode(path: string): TreeNode
	local metadataPath = `{path}/init.meta.json`
	local name: string, className: string, properties: { string }
	if fs.isFile(metadataPath) then
		name, className, properties = metadataFields(readJson(metadataPath))
	else
		name, className, properties = path:match("([^/]+)$") or path, "Folder", {}
	end

	local children: { TreeNode } = {}
	for _, childName in fs.readDir(path) do
		local childPath = `{path}/{childName}`
		if fs.isDir(childPath) then
			table.insert(children, directoryNode(childPath))
		elseif
			childName:match("%.model%.json$") or (childName ~= "init.meta.json" and childName:match("%.meta%.json$"))
		then
			table.insert(children, leafNode(childPath))
		end
	end
	table.sort(children, function(a: TreeNode, b: TreeNode)
		local aKey = `{a.n:lower()}\0{a.c:lower()}`
		local bKey = `{b.n:lower()}\0{b.c:lower()}`
		return aKey < bKey
	end)

	local node: TreeNode = {
		n = name,
		c = className,
		p = properties,
	}
	if #children > 0 then
		node.k = children
	end
	return node
end

local function gearTree(assetId: string): TreeNode
	local gearPath = `{project.GEAR_PATH}/{assetId}`
	local sourcePath = `{gearPath}/src`
	return if fs.isDir(sourcePath) then directoryNode(sourcePath) else leafNode(`{gearPath}/src.model.json`)
end

local function summarizeTree(node: TreeNode, classes: { [string]: number }?): (number, { [string]: number })
	local counts = classes or {}
	counts[node.c] = (counts[node.c] or 0) + 1
	local count = 1
	for _, child in node.k or {} do
		local childCount = summarizeTree(child, counts)
		count += childCount
	end
	return count, counts
end

local function sortedGearIds(): { string }
	local ids: { string } = {}
	for _, entry in fs.readDir(project.GEAR_PATH) do
		if entry:match("^%d+$") and fs.isDir(`{project.GEAR_PATH}/{entry}`) then
			table.insert(ids, entry)
		end
	end
	table.sort(ids, function(a: string, b: string): boolean
		return assert(tonumber(a)) < assert(tonumber(b))
	end)
	return ids
end

-- Half the catalog is enough to keep a lost artifact plus one --new-only
-- batch from replacing the live site, without blocking the current store
-- (~80% covered) or the later half of the first hourly rotation.
local CATALOG_MIN_COVERED_RATIO = 0.5

local output = "_site"
local storePath: string? = nil
local offline = false
local index = 1
while index <= #process.args do
	local argument = process.args[index]
	if argument == "--output" then
		index += 1
		output = assert(process.args[index], "--output requires a path")
	elseif argument == "--store" then
		index += 1
		storePath = assert(process.args[index], "--store requires a path")
	elseif argument == "--offline" then
		offline = true
	else
		error(`Unknown argument: {argument}`)
	end
	index += 1
end

if offline then
	if storePath ~= nil then
		error("Cannot combine --store and --offline")
	end
end

if fs.isDir(output) then
	fs.removeDir(output)
end
copyDirectory("site", output)
fs.writeFile(`{output}/index.html`, pages.catalog())
fs.writeFile(`{output}/oddities.html`, pages.oddities())
fs.writeFile(`{output}/gear.html`, pages.gear())
fs.writeDir(`{output}/data`)
fs.writeDir(`{output}/data/gear`)

local gearIds = sortedGearIds()
for _, assetId in gearIds do
	if gearNames[assetId] == nil then
		error(`GearMap is missing dumped gear {assetId}`)
	end
end

local store = catalogStore.load(storePath)
local catalog: { CatalogEntry } = {}
for _, assetId in gearIds do
	local numericId = assert(tonumber(assetId))
	local tree = gearTree(assetId)
	local instanceCount, classes = summarizeTree(tree)
	local stored = store.items[numericId]
	local entry: CatalogEntry = {
		id = numericId,
		name = stored and stored.name or catalogFallbacks[assetId] or friendlyName(gearNames[assetId] or assetId),
		description = if stored then stored.description or "" else "",
		creator = if stored and stored.creator then stored.creator else "ROBLOX",
		created = if stored then stored.created else nil,
		price = if stored then stored.price else nil,
		priceStatus = if stored then stored.priceStatus else nil,
		favorites = if stored then stored.favorites else nil,
		thumbnail = if stored and stored.thumbnail then stored.thumbnail else "",
		instances = instanceCount,
		classes = classes,
	}
	table.insert(catalog, entry)
	fs.writeFile(`{output}/data/gear/{assetId}.json`, serde.encode("json", tree))
end

local function isUnnamed(name: string): boolean
	return name:match("^%s*%w") == nil
end

table.sort(catalog, function(a: CatalogEntry, b: CatalogEntry): boolean
	local aUnnamed = isUnnamed(a.name)
	local bUnnamed = isUnnamed(b.name)
	if aUnnamed ~= bUnnamed then
		return bUnnamed
	end
	local aName = a.name:lower()
	local bName = b.name:lower()
	return if aName == bName then a.id < b.id else aName < bName
end)

local covered = 0
for _, entry in catalog do
	if entry.created ~= nil then
		covered += 1
	end
end

if storePath ~= nil then
	local minimum = math.floor(#catalog * CATALOG_MIN_COVERED_RATIO)
	if covered < minimum then
		error(
			`Catalog store at {storePath} covers {covered}/{#catalog} items (need {minimum}); refusing to publish fallback names`
		)
	end
end

fs.writeFile(
	`{output}/data/catalog.json`,
	serde.encode("json", {
		generatedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		count = #catalog,
		covered = covered,
		items = catalog,
	})
)

print(`Built {#catalog} gear pages ({covered} with catalog metadata from the store)`)
