local fs = require("@lute/fs")
local test = require("@std/test")
local testTypes = require("@std/test/types")

local CatalogFallbacks = require("@root/src/CatalogFallbacks") :: { [string]: string? }
local MissingGear = require("@root/src/MissingGear") :: { [string]: string? }
local GearMap = require("@root/src/GearMap") :: { [string]: string? }
local project = require("@root/project")

type TestSuite = testTypes.TestSuite
type Asserts = testTypes.Asserts

type StringSet = { [string]: boolean }

local function readFile(path: string): string
	local handle = fs.open(path)
	local contents = fs.read(handle)
	fs.close(handle)
	return contents
end

local function sorted(values: { string }): { string }
	table.sort(values)
	return values
end

local function inventoryIds(asserts: Asserts): StringSet
	local ids: StringSet = {}
	local invalid = {}
	local duplicates = {}

	for line in readFile(project.GEAR_INVENTORY_PATH):gmatch("[^\r\n]+") do
		local assetId, assetType = line:match("^(%d+),(%d+)$")
		if assetId == nil or assetType ~= "19" then
			table.insert(invalid, line)
		elseif ids[assetId] then
			table.insert(duplicates, assetId)
		else
			ids[assetId] = true
		end
	end

	asserts.eq({}, sorted(invalid))
	asserts.eq({}, sorted(duplicates))
	return ids
end

local function filesystemIds(path: string, pattern: string): StringSet
	local ids: StringSet = {}
	for _, entry in fs.listdir(path) do
		local assetId = entry.name:match(pattern)
		if assetId ~= nil then
			ids[assetId] = true
		end
	end
	return ids
end

test.suite("gear dump coverage", function(suite: TestSuite)
	suite:case("accounts for every AllGear asset", function(asserts: Asserts)
		local inventory = inventoryIds(asserts)
		local raw = filesystemIds(project.RAW_GEAR_ASSETS_PATH, "^(%d+)%.rbxm$")
		local unaccounted = {}
		local obsoleteExclusions = {}

		for assetId in inventory do
			if not raw[assetId] and MissingGear[assetId] == nil then
				table.insert(unaccounted, assetId)
			end
		end
		for assetId in MissingGear do
			if not inventory[assetId] or raw[assetId] then
				table.insert(obsoleteExclusions, assetId)
			end
		end

		asserts.eq({}, sorted(unaccounted))
		asserts.eq({}, sorted(obsoleteExclusions))
	end)

	suite:case("has a complete dump and name for every raw gear asset", function(asserts: Asserts)
		local inventory = inventoryIds(asserts)
		local raw = filesystemIds(project.RAW_GEAR_ASSETS_PATH, "^(%d+)%.rbxm$")
		local dumped = filesystemIds(project.GEAR_PATH, "^(%d+)$")
		local outsideInventory = {}
		local missingDumps = {}
		local missingNames = {}

		for assetId in raw do
			if not inventory[assetId] then
				table.insert(outsideInventory, assetId)
			end
			local dumpPath = `{project.GEAR_PATH}/{assetId}`
			local hasSource = fs.exists(`{dumpPath}/src`) or fs.exists(`{dumpPath}/src.model.json`)
			if not dumped[assetId] or not fs.exists(`{dumpPath}/default.project.json`) or not hasSource then
				table.insert(missingDumps, assetId)
			end
			if GearMap[assetId] == nil then
				table.insert(missingNames, assetId)
			end
		end
		for assetId in dumped do
			if not raw[assetId] then
				table.insert(missingDumps, assetId)
			end
		end

		asserts.eq({}, sorted(outsideInventory))
		asserts.eq({}, sorted(missingDumps))
		asserts.eq({}, sorted(missingNames))
	end)

	suite:case("catalog fallbacks only cover dumped gear with a display name", function(asserts: Asserts)
		local unknown = {}
		for assetId, name in CatalogFallbacks do
			if GearMap[assetId] == nil then
				table.insert(unknown, assetId)
			end
			asserts.eq(true, name ~= "")
		end
		asserts.eq({}, sorted(unknown))
	end)

	suite:case("does not silently drop inventory records", function(asserts: Asserts)
		local inventory = inventoryIds(asserts)
		local count = 0
		for _ in inventory do
			count += 1
		end
		asserts.eq(2_344, count)
	end)
end)
