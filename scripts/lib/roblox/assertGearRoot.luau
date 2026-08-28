--[[
	Throw unless the model's root is Gear. Asset IDs sourced from the catalog
	are not all Gear: some resolve to Hats or Accessories, and dumping one
	into `src/gear` would quietly put a non-Gear tree in the archive.

	`HopperBin` is a Class, not a gear name: it was the pre-2012 Gear
	root, later replaced by `Tool`. The oldest assets in this archive
	(Part Dragger, Clone Part) still use it, so it is as valid here as
	`Tool`. See https://create.roblox.com/docs/reference/engine/classes/HopperBin.

	Left generic rather than tied to a concrete Instance: this runs against
	Lune instances in scripts but lightweight fakes under `lute test`, which
	cannot require `@lune/roblox`.
]]

local function assertGearRoot<T>(model: T, assetId: string): T
	local root = model :: any
	assert(
		root.ClassName == "Tool" or root.ClassName == "HopperBin",
		`asset {assetId} has non-Gear root {root.ClassName} {root.Name}`
	)
	return model
end

return assertGearRoot
