local fs = require("@lune/fs")
local process = require("@lune/process")

local catalogApi = require("@root/site/catalogApi")
local catalogStore = require("@root/site/catalogStore")
local project = require("@root/project")

local storePath = "catalog-store.json"
local newOnly = false
local argIndex = 1
while argIndex <= #process.args do
	local argument = process.args[argIndex]
	if argument == "--store" then
		argIndex += 1
		storePath = assert(process.args[argIndex], "--store requires a path")
	elseif argument == "--new-only" then
		newOnly = true
	else
		error(`Unknown argument: {argument}`)
	end
	argIndex += 1
end

local function sortedGearIds(): { number }
	local ids: { number } = {}
	for _, entry in fs.readDir(project.GEAR_PATH) do
		if entry:match("^%d+$") and fs.isDir(`{project.GEAR_PATH}/{entry}`) then
			table.insert(ids, assert(tonumber(entry)))
		end
	end
	table.sort(ids)
	return ids
end

local function setGithubOutput(name: string, value: string)
	local path = process.env.GITHUB_OUTPUT
	if typeof(path) ~= "string" or path == "" then
		return
	end
	local prefix = if fs.isFile(path) then fs.readFile(path) else ""
	fs.writeFile(path, `{prefix}{name}={value}\n`)
end

local gearIds = sortedGearIds()
local store = catalogStore.load(if fs.isFile(storePath) then storePath else nil)

if newOnly then
	local missing: { number } = {}
	for _, assetId in gearIds do
		local stored = store.items[assetId]
		if stored == nil or stored.name == nil then
			table.insert(missing, assetId)
		end
	end
	if #missing == 0 then
		print("No new gear needs catalog metadata")
		setGithubOutput("wrote", "false")
		process.exit(0)
	end

	local batch: { number } = {}
	for index = 1, math.min(catalogApi.BATCH_SIZE, #missing) do
		table.insert(batch, missing[index])
	end
	local refreshed = catalogStore.refreshIds(store, batch)
	catalogStore.save(storePath, store)
	local remaining = #missing - #batch
	if remaining > 0 then
		print(`Fetched metadata for {refreshed} new gear item(s); {remaining} still missing`)
	else
		print(`Fetched metadata for {refreshed} new gear item(s)`)
	end
	setGithubOutput("wrote", "true")
	process.exit(0)
end

if store.nextIndex >= #gearIds then
	store.nextIndex = 0
end

local startAt = store.nextIndex + 1
local batch: { number } = {}
for index = startAt, math.min(startAt + catalogApi.BATCH_SIZE - 1, #gearIds) do
	table.insert(batch, gearIds[index])
end

if #batch == 0 then
	print("Nothing to refresh")
	process.exit(0)
end

local refreshed = catalogStore.refreshIds(store, batch)
local endAt = startAt + #batch - 1
store.nextIndex = store.nextIndex + #batch
if store.nextIndex >= #gearIds then
	store.nextIndex = 0
end

catalogStore.save(storePath, store)
print(`Refreshed {refreshed} item(s) ({startAt}-{endAt} of {#gearIds}); next starts at {store.nextIndex + 1}`)
