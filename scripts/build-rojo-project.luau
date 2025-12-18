local process = require("@lune/process")

local buildRojoProject = require("@scripts/lib/roblox/buildRojoProject")

local projectPath = process.args[1]
local outputPath = process.args[2]

buildRojoProject({
	projectPath = projectPath,
	outputPath = outputPath,
})

print(`Built to {outputPath} successfully`)
