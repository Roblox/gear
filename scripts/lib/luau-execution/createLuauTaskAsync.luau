local json = require("@std/json")

local fetch = require("@scripts/lib/fetch")
local types = require("./types")

type LuauTaskResponse = types.LuauTaskResponse

-- Omitting the version runs against whatever the place's latest version happens
-- to be when the task starts, which is not necessarily the one we just uploaded.
local function createLuauTaskAsync(
	scriptContent: string,
	universeId: string,
	placeId: string,
	apiKey: string,
	placeVersion: number?
): LuauTaskResponse
	local url = `https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/`
	if placeVersion then
		url ..= `versions/{placeVersion}/`
	end
	url ..= "luau-execution-session-tasks"

	local res = fetch(url, {
		method = "POST",
		headers = {
			["Content-Type"] = "application/json",
			["x-api-key"] = apiKey,
		},
		body = json.serialize({
			["script"] = scriptContent,
		}),
	})

	return json.deserialize(res.body) :: LuauTaskResponse
end

return createLuauTaskAsync
