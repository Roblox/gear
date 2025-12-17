local process = require("@lute/process")

local project = require("@root/project")

local function installWallyPackages()
	process.run({
		"wally",
		"install",
	}, {
		stdio = "inherit",
	})
end

local function installLuteBatteries()
	process.run({ "mkdir", "-p", project.LUTE_BATTERIES_PATH })

	for _, battery in project.LUTE_BATTERIES do
		process.run({
			"curl",
			"-LO",
			`https://raw.githubusercontent.com/luau-lang/lute/{project.LUTE_BATTERIES_COMMIT}/batteries/{battery}`,
		}, {
			cwd = project.LUTE_BATTERIES_PATH,
		})
	end
end

installWallyPackages()
installLuteBatteries()
