local fs = require("@lute/fs")
local process = require("@lute/process")

local downloadPinned = require("@scripts/lib/downloadPinned")
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

	for battery, expectedSha256 in project.LUTE_BATTERIES_SHA256 do
		downloadPinned.downloadPinned(
			`https://raw.githubusercontent.com/luau-lang/lute/{project.LUTE_BATTERIES_COMMIT}/batteries/{battery}`,
			`{project.LUTE_BATTERIES_PATH}/{battery}`,
			expectedSha256
		)
	end
end

local function installRbxasset()
	process.run({ "mkdir", "-p", project.LUAU_PACKAGES_PATH })

	downloadPinned.downloadPinned(
		project.RBXASSET_URL,
		`{project.LUAU_PACKAGES_PATH}/rbxasset.zip`,
		project.RBXASSET_SHA256
	)

	process.run({ "unzip", "rbxasset.zip" }, {
		cwd = project.LUAU_PACKAGES_PATH,
	})

	fs.remove(`{project.LUAU_PACKAGES_PATH}/rbxasset.zip`)
end

-- The `@lute`, `@std`, and `@lune` aliases in .luaurc resolve to type
-- definitions that each toolchain generates into its own versioned home
-- directory. Without these, analysis reports every runtime require as unknown.
local function installTypeDefinitions()
	process.run({ "lute", "setup" })

	-- `lune setup` rewrites the .luaurc of its working directory, so run it
	-- somewhere disposable to leave ours alone.
	local scratch = `{process.cwd()}/.lune-setup`
	process.run({ "mkdir", "-p", scratch })
	process.run({ "lune", "setup" }, { cwd = scratch })
	process.run({ "rm", "-rf", scratch })
end

process.run({ "rm", "-rf", project.LUAU_PACKAGES_PATH })

installTypeDefinitions()
installWallyPackages()
installLuteBatteries()
installRbxasset()
