local json = require("@std/json")

local fetch = require("@scripts/lib/fetch")

type TaskLogsResponse = {
	luauExecutionSessionTaskLogs: {
		{
			messages: { string },
		}
	},
}

local function getLuauTaskLogsAsync(taskPath: string, apiKey: string): { string }
	local res = fetch(`https://apis.roblox.com/cloud/v2/{taskPath}/logs`, {
		headers = {
			["x-api-key"] = apiKey,
		},
	})

	local logs = json.deserialize(res.body) :: TaskLogsResponse

	local pages = logs.luauExecutionSessionTaskLogs
	if #pages == 0 then
		return {} -- no logs found
	end
	return pages[1].messages
end

return getLuauTaskLogsAsync
