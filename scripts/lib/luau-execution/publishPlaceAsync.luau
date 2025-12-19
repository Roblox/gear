local fs = require("@lute/fs")
local json = require("@std/json")

local fetch = require("@scripts/lib/fetch")

local function publishPlaceAsync(
	placePath: string,
	universeId: string,
	placeId: string,
	apiKey: string,
	shouldPublish: boolean?
)
	print("uploading place to Roblox")

	local versionType = if shouldPublish then "Published" else "Saved"

	local handle = fs.open(placePath)
	local content = fs.read(handle)

	local res =
		fetch(`https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType={versionType}`, {
			method = "POST",
			body = content,
			headers = {
				["x-api-key"] = apiKey,
				["Content-Type"] = "application/xml",
				["Accept"] = "application/json",
			},
		})

	if res.ok then
		local body = json.deserialize(res.body)
		return body.versionNumber :: number
	end
	return -1
end

return publishPlaceAsync
