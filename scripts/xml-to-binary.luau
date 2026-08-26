local fs = require("@lute/fs")

local project = require("@root/project")

local INPUT_DIR = project.RAW_GEAR_ASSETS_PATH
local OUTPUT_DIR = "gear"

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
		table.insert(diff, file.name)
	end
end

if #diff > 0 then
	print("Some files did not get processed:")
	for _, file in diff do
		print(file)
	end
end
print("all done")
