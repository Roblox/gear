local fs = require("@lute/fs")
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

local function installRbxasset()
	process.run({ "mkdir", "-p", project.LUAU_PACKAGES_PATH })

	process.run({ "curl", "-LO", "https://github.com/Roblox/rbxasset/releases/download/v0.2.0/rbxasset.zip" }, {
		cwd = project.LUAU_PACKAGES_PATH,
	})

	process.run({ "unzip", "rbxasset.zip" }, {
		cwd = project.LUAU_PACKAGES_PATH,
	})

	fs.remove(`{project.LUAU_PACKAGES_PATH}/rbxasset.zip`)
end

process.run({ "rm", "-rf", project.LUAU_PACKAGES_PATH })

installWallyPackages()
installLuteBatteries()
installRbxasset()
