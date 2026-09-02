local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local serde = require("@lune/serde")
local task = require("@lune/task")

local CatalogFallbacks = require("@root/src/CatalogFallbacks")
local GearMap = require("@root/src/GearMap")
local pages = require("@root/site/pages")
local project = require("@root/project")

-- Bulk item details accepts 120 ids per request and is throttled to 10/minute.
-- It needs an X-CSRF-TOKEN but no login: the first POST answers 403 and hands
-- back a token to replay with.
local CATALOG_DETAILS_URL = "https://catalog.roblox.com/v1/catalog/items/details"
local CATALOG_BATCH_SIZE = 120
local CATALOG_BATCH_DELAY = 6.5
local THUMBNAIL_URL = "https://thumbnails.roblox.com/v1/assets"
local USER_AGENT = "marketplace-gear-pages/1.0"

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

-- GearMap is a literal table, so its inferred type rejects a string index.
local gearNames = GearMap :: { [string]: string? }
local catalogFallbacks = CatalogFallbacks :: { [string]: string? }

-- Query and header values are `string | { string }`, and table indexers are
-- invariant, so a plain `{ [string]: string }` will not satisfy net's map types.
local function httpMap(entries: { [string]: string }): net.HttpHeaderMap
	-- Not table.clone: that keeps the narrow `{ [string]: string }` indexer, which
	-- is the type net rejects. Copying into a widened table is the point.
	-- selene: allow(manual_table_clone)
	local map: net.HttpHeaderMap = {}
	for key, value in entries do
		map[key] = value
	end
	return map
end

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

-- Throttling and gateway faults both clear on their own, so they are worth the
-- backoff. Anything else (404, a malformed query) will fail the same way twice.
local function isRetryable(statusCode: number): boolean
	return statusCode == 429 or statusCode >= 500
end

local function requestJson(url: string, query: { [string]: string }): JsonObject
	local lastStatus = "request failed"
	local params: net.FetchParams = {
		url = url,
		query = httpMap(query),
		headers = httpMap({ ["User-Agent"] = USER_AGENT }),
	}
	for attempt = 1, 4 do
		local ok, response = pcall(net.request, params)
		if ok and response.ok then
			return serde.decode("json", response.body) :: JsonObject
		end
		if ok then
			lastStatus = `{response.statusCode} {response.statusMessage}`
			if not isRetryable(response.statusCode) then
				break
			end
		else
			lastStatus = tostring(response)
		end
		task.wait(2 ^ (attempt - 1))
	end
	error(`GET {url} failed: {lastStatus}`)
end

local csrfToken = ""

local function requestCatalogBatch(items: { JsonObject }): JsonObject
	local body = serde.encode("json", { items = items })
	local lastStatus = "request failed"
	for attempt = 1, 5 do
		local params: net.FetchParams = {
			url = CATALOG_DETAILS_URL,
			method = "POST",
			headers = httpMap({
				["Content-Type"] = "application/json",
				["User-Agent"] = USER_AGENT,
				["X-CSRF-TOKEN"] = csrfToken,
			}),
			body = body,
		}
		local ok, response = pcall(net.request, params)
		if ok and response.ok then
			return serde.decode("json", response.body) :: JsonObject
		end
		if ok then
			lastStatus = `{response.statusCode} {response.statusMessage}`
			local token = response.headers["x-csrf-token"]
			if response.statusCode == 403 and typeof(token) == "string" and token ~= csrfToken then
				csrfToken = token
				continue
			end
			if not isRetryable(response.statusCode) then
				break
			end
		else
			lastStatus = tostring(response)
		end
		task.wait(2 ^ (attempt - 1))
	end
	error(`POST {CATALOG_DETAILS_URL} failed: {lastStatus}`)
end

local function fetchCatalogMetadata(assetIds: { number }): { [number]: JsonObject }
	local found: { [number]: JsonObject } = {}
	for startIndex = 1, #assetIds, CATALOG_BATCH_SIZE do
		local items: { JsonObject } = {}
		for index = startIndex, math.min(startIndex + CATALOG_BATCH_SIZE - 1, #assetIds) do
			local entry: JsonObject = { itemType = "Asset", id = assetIds[index] }
			table.insert(items, entry)
		end
		local ok, payload = pcall(requestCatalogBatch, items)
		if ok then
			for _, item in payload.data or {} do
				local itemId = tonumber(item.id)
				if itemId then
					found[itemId] = item
				end
			end
		else
			warn(`Catalog batch at {startIndex} failed, continuing without it: {payload}`)
		end
		if startIndex + CATALOG_BATCH_SIZE <= #assetIds then
			task.wait(CATALOG_BATCH_DELAY)
		end
	end

	local omitted: { string } = {}
	for _, assetId in assetIds do
		if found[assetId] == nil then
			table.insert(omitted, tostring(assetId))
		end
	end
	if #omitted > 0 then
		warn(`Catalog API omitted {#omitted} item(s): {table.concat(omitted, ", ")}`)
	end

	return found
end

local function fetchThumbnails(assetIds: { number }): { [number]: string }
	local thumbnails: { [number]: string } = {}
	for startIndex = 1, #assetIds, 100 do
		local batch: { string } = {}
		for index = startIndex, math.min(startIndex + 99, #assetIds) do
			table.insert(batch, tostring(assetIds[index]))
		end
		local query: { [string]: string } = {
			assetIds = table.concat(batch, ","),
			returnPolicy = "PlaceHolder",
			size = "420x420",
			format = "Png",
			isCircular = "false",
		}
		local ok, payload = pcall(requestJson, THUMBNAIL_URL, query)
		if ok then
			for _, image in payload.data or {} do
				if image.state == "Completed" and image.imageUrl then
					thumbnails[image.targetId] = image.imageUrl
				end
			end
		else
			warn(`Thumbnail batch at {startIndex} failed, continuing without it: {payload}`)
		end
		task.wait(0.2)
	end
	return thumbnails
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

local output = "_site"
local offline = false
local index = 1
while index <= #process.args do
	local argument = process.args[index]
	if argument == "--output" then
		index += 1
		output = assert(process.args[index], "--output requires a path")
	elseif argument == "--offline" then
		offline = true
	else
		error(`Unknown argument: {argument}`)
	end
	index += 1
end

if fs.isDir(output) then
	fs.removeDir(output)
end
copyDirectory("site", output)
fs.writeFile(`{output}/index.html`, pages.catalog())
fs.writeFile(`{output}/gear.html`, pages.gear())
fs.writeDir(`{output}/data`)
fs.writeDir(`{output}/data/gear`)

local gearIds = sortedGearIds()
local numericIds: { number } = {}
for _, assetId in gearIds do
	if gearNames[assetId] == nil then
		error(`GearMap is missing dumped gear {assetId}`)
	end
	table.insert(numericIds, assert(tonumber(assetId)))
end

local catalogMetadata: { [number]: JsonObject } = {}
local thumbnails: { [number]: string } = {}
if not offline then
	local metadataOk, metadataResult = pcall(fetchCatalogMetadata, numericIds)
	if metadataOk then
		catalogMetadata = metadataResult
	else
		warn(`Catalog metadata unavailable: {metadataResult}`)
	end
	local thumbnailsOk, thumbnailsResult = pcall(fetchThumbnails, numericIds)
	if thumbnailsOk then
		thumbnails = thumbnailsResult
	else
		warn(`Thumbnails unavailable: {thumbnailsResult}`)
	end
end

local catalog: { CatalogEntry } = {}
for _, assetId in gearIds do
	local numericId = assert(tonumber(assetId))
	local tree = gearTree(assetId)
	local instanceCount, classes = summarizeTree(tree)
	local apiItem: JsonObject = catalogMetadata[numericId] or {}
	local entry: CatalogEntry = {
		id = numericId,
		name = apiItem.name or catalogFallbacks[assetId] or friendlyName(gearNames[assetId] or assetId),
		description = apiItem.description or "",
		creator = apiItem.creatorName or "ROBLOX",
		created = apiItem.itemCreatedUtc,
		price = apiItem.price,
		priceStatus = apiItem.priceStatus,
		favorites = apiItem.favoriteCount,
		thumbnail = thumbnails[numericId] or "",
		instances = instanceCount,
		classes = classes,
	}
	table.insert(catalog, entry)
	fs.writeFile(`{output}/data/gear/{assetId}.json`, serde.encode("json", tree))
end

table.sort(catalog, function(a: CatalogEntry, b: CatalogEntry): boolean
	local aName = a.name:lower()
	local bName = b.name:lower()
	return if aName == bName then a.id < b.id else aName < bName
end)

local apiEnriched = 0
for _ in catalogMetadata do
	apiEnriched += 1
end
fs.writeFile(
	`{output}/data/catalog.json`,
	serde.encode("json", {
		generatedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		count = #catalog,
		apiEnriched = apiEnriched,
		items = catalog,
	})
)

print(`Built {#catalog} gear pages ({apiEnriched} catalog-enriched)`)
