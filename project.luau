return {
	RAW_GEAR_ASSETS_PATH = "assets",
	GEAR_PATH = "src/gear",
	GEAR_INVENTORY_PATH = "src/AllGear.csv",

	SCRIPTS_PATH = "scripts",
	SITE_PATH = "site",
	SOURCE_PATH = "src",

	TESTS_PROJECT_PATH = "tests.project.json",

	LUAU_PACKAGES_PATH = "LuauPackages",

	LUTE_BATTERIES_COMMIT = "6a8e5f0de40439b94c9bbff7dbcf994bc15b6770",
	LUTE_BATTERIES_PATH = "LuauPackages/batteries",
	LUTE_BATTERIES_SHA256 = {
		["cli.luau"] = "c81fea53b1fc00243cfbdb5a4023e9bd98be31b3022333456415f7772e3b5ff9",
		["pp.luau"] = "1d8f66bdc8e661ef9e9a2e8e794573cd9a50313ac757ac7f6bc5101d938e25f9",
		["richterm.luau"] = "942606cfd3475337f05225aaf5c8fab4f5f2aed7e59d12bf147418734a26b80b",
	} :: { [string]: string },

	RBXASSET_URL = "https://github.com/Roblox/rbxasset/releases/download/v0.2.0/rbxasset.zip",
	RBXASSET_SHA256 = "923653f16692a8a8a435ef2a35774b46835b2382aaeb9c84a069bc5800739928",

	-- Foreman pins luau-lsp =1.58.0; this is that release's scripts/globalTypes.d.lua.
	LUAU_LSP_COMMIT = "f4fa9c67bcb19f15922f0a69b871771b9ae45be4",
	LUAU_LSP_GLOBAL_TYPES_SHA256 = "dffa9173bd1ac910906155d5272f83e7b9d3f9dadc17eba980d26c280c227fe3",
}
