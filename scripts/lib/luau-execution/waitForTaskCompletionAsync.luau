local task = require("@lute/task")
local json = require("@std/json")

local fetch = require("@scripts/lib/fetch")
local types = require("./types")

type LuauTaskResponse = types.LuauTaskResponse

local POLL_INTERVAL_SECONDS = 2
local RETRY_DELAY_SECONDS = 5

-- Polling is a read-only GET against a task Roblox is already running, so a
-- failed poll can always be repeated. A single connection blip shouldn't
-- abandon a task that is still healthy, but a sustained outage still fails.
local MAX_CONSECUTIVE_FAILURES = 5

local function waitForTaskCompletionAsync(operationPath: string, apiKey: string): LuauTaskResponse
	local url = `https://apis.roblox.com/cloud/v2/{operationPath}`
	local consecutiveFailures = 0

	while true do
		-- Called through a closure rather than passed to pcall directly, so the
		-- options literal is still checked against fetch's parameter type.
		local ok, result = pcall(function()
			return fetch(url, {
				headers = {
					["x-api-key"] = apiKey,
				},
			})
		end)

		if not ok then
			consecutiveFailures += 1
			if consecutiveFailures >= MAX_CONSECUTIVE_FAILURES then
				error(`gave up polling {url} after {consecutiveFailures} consecutive failures: {tostring(result)}`)
			end

			print(
				`polling failed ({consecutiveFailures}/{MAX_CONSECUTIVE_FAILURES}), `
					.. `retrying in {RETRY_DELAY_SECONDS}s: {tostring(result)}`
			)
			task.wait(RETRY_DELAY_SECONDS)
			continue
		end

		consecutiveFailures = 0

		local luauTask = json.deserialize(result.body) :: LuauTaskResponse

		if luauTask.state ~= "PROCESSING" then
			return luauTask
		else
			task.wait(POLL_INTERVAL_SECONDS)
		end
	end
end

return waitForTaskCompletionAsync
