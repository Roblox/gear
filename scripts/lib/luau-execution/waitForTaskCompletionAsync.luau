local task = require("@lute/task")
local json = require("@std/json")

local fetch = require("@scripts/lib/fetch")

local function waitForTaskCompletionAsync(operationPath: string, apiKey: string)
	while true do
		local res = fetch(`https://apis.roblox.com/cloud/v2/{operationPath}`, {
			headers = {
				["x-api-key"] = apiKey,
			},
		})

		local luauTask = json.deserialize(res.body)

		if luauTask.state ~= "PROCESSING" then
			return luauTask
		else
			task.wait(2)
		end
	end
end

return waitForTaskCompletionAsync
