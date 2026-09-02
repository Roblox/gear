--[[
	Fetch raw Gear rbxms into `assets` by asset ID.

	The original corpus was imported in bulk before this repository existed,
	so this covers the gaps: IDs that AllGear lists but `assets` does not
	have. Downloading is deliberately separate from dumping, so
	scripts/model-to-rojo.luau stays an offline transform. Run this first,
	then dump the files it writes.

	usage: lune run scripts/download-gear.luau [--version <number>] <asset-id>...
]]

local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local project = require("@root/project")
local assertGearRoot = require("@scripts/lib/roblox/assertGearRoot")

local ASSET_DELIVERY_URL = "https://assetdelivery.roblox.com/v1/asset"

-- Asset delivery answers some of the older assets gzipped regardless of
-- Accept-Encoding, so sniff the magic bytes rather than trusting a header.
local function maybeDecompress(contents: string): string
	local first, second = string.byte(contents, 1, 2)
	if first == 0x1F and second == 0x8B then
		return serde.decompress("gzip", contents)
	end
	return contents
end

local function downloadAsset(assetId: string, version: string?): string
	print("Downloading", assetId)
	local versionQuery = if version then `&version={version}` else ""
	local params: net.FetchParams = {
		url = `{ASSET_DELIVERY_URL}/?id={assetId}{versionQuery}`,
		headers = {
			["User-Agent"] = "marketplace-gear",
		},
	}
	local response = net.request(params)
	if not response.ok then
		error(`failed to download asset {assetId}: {response.statusCode} {response.statusMessage}`)
	end

	local instances = roblox.deserializeModel(maybeDecompress(response.body))
	assertGearRoot(instances[1], assetId)
	-- Round-trip through Lune rather than writing the response as-is: some
	-- assets are served as XML, and Rojo rejects those under a `.rbxm` name.
	return roblox.serializeModel(instances)
end

local assetIds: { string } = {}
local version: string? = nil
local index = 1
while index <= #process.args do
	local argument = process.args[index]
	if argument == "--version" then
		index += 1
		version = assert(process.args[index], "--version requires a number")
		assert(version:match("^%d+$"), `expected a version number, got {version}`)
	else
		table.insert(assetIds, argument)
	end
	index += 1
end

if #assetIds == 0 then
	error("usage: lune run scripts/download-gear.luau [--version <number>] <asset-id>...")
end

for _, assetId in assetIds do
	assert(assetId:match("^%d+$"), `expected an asset ID, got {assetId}`)
	local modelFile = `{project.RAW_GEAR_ASSETS_PATH}/{assetId}.rbxm`
	if fs.isFile(modelFile) then
		print("Already have", modelFile)
		continue
	end
	fs.writeFile(modelFile, downloadAsset(assetId, version))
	print("Wrote", modelFile)
end
