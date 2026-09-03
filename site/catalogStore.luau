local fs = require("@lune/fs")
local serde = require("@lune/serde")

local catalogApi = require("@root/site/catalogApi")

type JsonObject = catalogApi.JsonObject

export type StoredItem = {
	id: number,
	name: string?,
	description: string?,
	creator: string?,
	created: string?,
	price: number?,
	priceStatus: string?,
	favorites: number?,
	thumbnail: string?,
}

export type CatalogStore = {
	nextIndex: number,
	updatedAt: string,
	items: { [number]: StoredItem },
}

local function empty(): CatalogStore
	return {
		nextIndex = 0,
		updatedAt = "",
		items = {},
	}
end

local function readJson(path: string): JsonObject
	return serde.decode("json", fs.readFile(path)) :: JsonObject
end

local function itemFromJson(raw: JsonObject): StoredItem?
	local itemId = tonumber(raw.id)
	if not itemId then
		return nil
	end
	return {
		id = itemId,
		name = raw.name,
		description = raw.description,
		creator = raw.creator,
		created = raw.created,
		price = raw.price,
		priceStatus = raw.priceStatus,
		favorites = raw.favorites,
		thumbnail = raw.thumbnail,
	}
end

local function load(path: string?): CatalogStore
	if path == nil or not fs.isFile(path) then
		return empty()
	end
	local ok, decoded = pcall(readJson, path)
	if not ok then
		warn(`Could not read the catalog store at {path}: {decoded}`)
		return empty()
	end

	local store = empty()
	store.nextIndex = tonumber(decoded.nextIndex) or 0
	store.updatedAt = decoded.updatedAt or ""

	local rawItems = decoded.items
	if typeof(rawItems) == "table" then
		if rawItems[1] ~= nil then
			for _, raw in rawItems :: { JsonObject } do
				local item = itemFromJson(raw)
				if item then
					store.items[item.id] = item
				end
			end
		end
	end

	return store
end

local function save(path: string, store: CatalogStore)
	local parent = path:match("^(.*)/[^/]+$")
	if parent then
		fs.writeDir(parent)
	end

	local items: { StoredItem } = {}
	for _, item in store.items do
		table.insert(items, item)
	end
	table.sort(items, function(a: StoredItem, b: StoredItem): boolean
		return a.id < b.id
	end)

	fs.writeFile(
		path,
		serde.encode("json", {
			nextIndex = store.nextIndex,
			updatedAt = store.updatedAt,
			count = #items,
			items = items,
		})
	)
end

local function applyMetadata(store: CatalogStore, metadata: { [number]: JsonObject }): number
	local refreshed = 0
	for numericId, apiItem in metadata do
		local existing: StoredItem = store.items[numericId] or { id = numericId }
		store.items[numericId] = {
			id = numericId,
			name = apiItem.name,
			description = apiItem.description,
			creator = apiItem.creatorName,
			created = apiItem.itemCreatedUtc,
			priceStatus = apiItem.priceStatus,
			price = apiItem.price,
			favorites = apiItem.favoriteCount,
			thumbnail = existing.thumbnail,
		}
		refreshed += 1
	end
	return refreshed
end

local function applyThumbnails(store: CatalogStore, thumbnails: { [number]: string })
	for numericId, thumbnail in thumbnails do
		local existing: StoredItem = store.items[numericId] or { id = numericId }
		existing.thumbnail = thumbnail
		store.items[numericId] = existing
	end
end

local function refreshIds(store: CatalogStore, assetIds: { number }): number
	if #assetIds == 0 then
		return 0
	end
	local metadata = catalogApi.fetchCatalogMetadata(assetIds)
	local refreshed = applyMetadata(store, metadata)
	applyThumbnails(store, catalogApi.fetchThumbnails(assetIds))
	store.updatedAt = os.date("!%Y-%m-%dT%H:%M:%SZ")
	return refreshed
end

return {
	empty = empty,
	load = load,
	save = save,
	refreshIds = refreshIds,
}
