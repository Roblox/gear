local json = require("@std/json")

local createLuauTaskAsync = require("./createLuauTaskAsync")
local getLuauTaskLogsAsync = require("./getLuauTaskLogsAsync")
local publishPlaceAsync = require("./publishPlaceAsync")
local waitForTaskCompletionAsync = require("./waitForTaskCompletionAsync")

local function executeLuauTaskAsync(
	placePath: string,
	scriptContent: string,
	universeId: string,
	placeId: string,
	apiKey: string
): { any }
	publishPlaceAsync(placePath, universeId, placeId, apiKey)

	local boundary = ("-"):rep(80)
	print(`executing script content\n{boundary}\n{scriptContent}\n{boundary}`)

	print("starting Luau task...")
	local luauTask = createLuauTaskAsync(scriptContent, universeId, placeId, apiKey)
	print(`task created: {luauTask.path}`)

	print("waiting for task to complete...")
	luauTask = waitForTaskCompletionAsync(luauTask.path, apiKey)
	print(`task is now in {luauTask.state} state`)

	-- Logs are diagnostics only. A task that never prints still returns
	-- results, so an empty log must not short-circuit the payload.
	local logs = getLuauTaskLogsAsync(luauTask.path, apiKey)
	if #logs == 0 then
		print("the task did not produce any logs")
	else
		print("task output:")
		for _, l in logs do
			print(`  {l}`)
		end
	end

	if luauTask.state == "COMPLETE" then
		if luauTask.output then
			local results = luauTask.output.results
			if results then
				return results
			end
		end
	else
		print(`Task failed, error:\n{json.serialize(luauTask.error :: any)}`)
	end

	return {}
end

return executeLuauTaskAsync
