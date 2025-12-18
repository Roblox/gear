local fs = require("@lune/fs")
local process = require("@lune/process")
local roblox = require("@lune/roblox")

local function postProcessGearDataModel(gearInstance)
	local gearId = gearInstance.Name
	local gearDir = `src/gear/{gearId}`
	assert(gearId:match("^%d+$"), `gearId must be fully numeric, received {gearId}`)
	if not fs.isDir(gearDir) then
		error(`No gear found at {gearDir}`)
	end
	if not fs.isFile(`{gearDir}/post_build.luau`) then
		return
	end

	print(`Running post-process script for gear {gearId}...`)
	local postBuildFunction = require(`@gear/{gearId}/post_build`)
	postBuildFunction(gearInstance)
end

local function buildRojoProject(opts: {
	projectPath: string,
	outputPath: string,
})
	local projectPath = opts.projectPath
	local outputPath = opts.outputPath
	assert(
		typeof(projectPath) == "string",
		`projectPath must be a specified string, received {projectPath} ({typeof(projectPath)})`
	)
	assert(
		typeof(outputPath) == "string",
		`outputPath must be a specified string, received {outputPath} ({typeof(outputPath)})`
	)

	print(`Building {projectPath}...`)
	local buildResult = process.exec(`rojo build {projectPath} -o {outputPath}`, {}, {
		shell = true,
		stdio = "inherit",
	})
	if not buildResult.ok then
		error(`Rojo build failed`)
	end

	local buildFile = fs.readFile(outputPath)

	if outputPath:match("%.rbxl$") then
		local game = roblox.deserializePlace(buildFile)

		-- Bulk gear place file --
		local generatedGearSrcFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Src")
		if not generatedGearSrcFolder then
			error(`Error post-processing gear: game.ReplicatedStorage.Src does not exist`)
		end

		local generatedGearFolder = generatedGearSrcFolder:FindFirstChild("gear")
		if not generatedGearFolder then
			error(`Error post-processing gear: game.ReplicatedStorage.Src.gear does not exist`)
		end

		for _, gearInstance in generatedGearFolder:GetChildren() do
			postProcessGearDataModel(gearInstance)
		end

		fs.writeFile(outputPath, roblox.serializePlace(game))
	elseif outputPath:match("%.rbxm") then
		local gearInstance = roblox.deserializeModel(buildFile)

		postProcessGearDataModel(gearInstance)

		fs.writeFile(outputPath, roblox.serializeModel(gearInstance))
	end
end

return buildRojoProject
