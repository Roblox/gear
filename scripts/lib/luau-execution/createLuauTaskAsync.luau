local json = require("@std/json")

local fetch = require("@scripts/lib/fetch")
local types = require("./types")

type LuauTaskResponse = types.LuauTaskResponse

local function createLuauTaskAsync(
	scriptContent: string,
	universeId: string,
	placeId: string,
	apiKey: string
): LuauTaskResponse
	local res =
		fetch(`https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/luau-execution-session-tasks`, {
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
