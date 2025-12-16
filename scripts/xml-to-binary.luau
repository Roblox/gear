local fs = require("@lute/fs")
local task = require("@lute/task")
local process = require("@lute/process")

local project = require("@root/project")

local tasks: { thread } = {}

local INPUT_DIR = project.RAW_GEAR_ASSETS_PATH
local OUTPUT_DIR = "gear"

-- for _, file in fs.listdir(INPUT_DIR) do
-- 	local path = `{INPUT_DIR}/{file.name}`

-- 	if file.type == "file" then
-- 		print(file.name)

-- 		table.insert(
-- 			tasks,
-- 			task.spawn(function()
-- 				process.run({
-- 					"robloxdev-cli",
-- 					"run",

-- 					"--load.model",
-- 					path,

-- 					"--run",
-- 					"scripts/xml-to-binary-roblox.luau",

-- 					"--args",
-- 					file.name,

-- 					"--load.asRobloxScript",

-- 					"--fs.readwrite",
-- 					process.cwd(),

-- 					"--studioMode",
-- 					"1",
-- 				}, {
-- 					stdio = "inherit",
-- 				})
-- 			end)
-- 		)
-- 	end
-- end

-- while true do
-- 	local dead = 0
-- 	for _, thread in tasks do
-- 		if coroutine.status(thread) ~= "dead" then
-- 			dead += 1
-- 		end
-- 	end

-- 	if dead == #tasks then
-- 		break
-- 	end
-- end

local diff: { string } = {}
for _, file in fs.listdir(INPUT_DIR) do
	local hasMatch = false

	for _, other in fs.listdir(OUTPUT_DIR) do
		if file.name == other.name then
			hasMatch = true
			break
		end
	end

	if not hasMatch then
		table.insert(diff, file)
	end
end

if #diff > 0 then
	print("Some files did not get processed:")
	for _, file in diff do
		print(file.name)
	end
end
print("all done")
