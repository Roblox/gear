local process = require("@lute/process")

local project = require("@root/project")
local run = require("@scripts/lib/run")

-- `src/gear` is excluded via selene.toml / .styluaignore: dumped catalog
-- scripts are not ours to restyle or lint yet.
local FOLDERS_TO_LINT = {
	project.SOURCE_PATH,
	project.SCRIPTS_PATH,
}

local failureCount = 0

local ok = pcall(function()
	run("selene", FOLDERS_TO_LINT)
end)

if not ok then
	failureCount += 1
end

ok = pcall(function()
	run("stylua", {
		"--check",
		table.unpack(FOLDERS_TO_LINT),
	})
end)

if not ok then
	failureCount += 1
end

process.exit(failureCount)
