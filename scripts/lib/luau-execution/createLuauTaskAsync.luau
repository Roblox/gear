local json = require("@std/json")

local fetch = require("@scripts/lib/fetch")

type LuauTaskResponse = {
	binaryInput: string,
	binaryOutputUri: string,
	createTime: string,
	enableBinaryOutput: boolean,
	output: {
		results: { any },
	},
	path: string,
	script: string,
	state: string,
	updateTime: string,
	user: string,
	error: { [string]: any }?,
}

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

	return json.deserialize(res.body)
end

return createLuauTaskAsync
