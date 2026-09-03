local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")

local CATALOG_DETAILS_URL = "https://catalog.roblox.com/v1/catalog/items/details"
local CATALOG_BATCH_SIZE = 120
local CATALOG_THROTTLE_WAIT = 65
local THUMBNAIL_URL = "https://thumbnails.roblox.com/v1/assets"
local USER_AGENT = "marketplace-gear-pages/1.0"

export type JsonObject = { [string]: any }

local function httpMap(entries: { [string]: string }): net.HttpHeaderMap
	-- selene: allow(manual_table_clone)
	local map: net.HttpHeaderMap = {}
	for key, value in entries do
		map[key] = value
	end
	return map
end

local function isRetryable(statusCode: number): boolean
	return statusCode == 429 or statusCode >= 500
end

local function retryAfterSeconds(headers: net.HttpHeaderMap): number?
	local value = headers["retry-after"]
	if typeof(value) == "string" then
		return tonumber(value)
	end
	return nil
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
			if response.statusCode == 429 then
				task.wait(retryAfterSeconds(response.headers) or CATALOG_THROTTLE_WAIT)
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
	local items: { JsonObject } = {}
	for _, assetId in assetIds do
		local entry: JsonObject = { itemType = "Asset", id = assetId }
		table.insert(items, entry)
	end
	local payload = requestCatalogBatch(items)
	for _, item in payload.data or {} do
		local itemId = tonumber(item.id)
		if itemId then
			found[itemId] = item
		end
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

return {
	BATCH_SIZE = CATALOG_BATCH_SIZE,
	fetchCatalogMetadata = fetchCatalogMetadata,
	fetchThumbnails = fetchThumbnails,
}
