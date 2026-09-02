-- Every AllGear asset that does not currently have a raw RBXM or source dump.
-- Keep entries here until the asset is recovered or proven not to be gear.
return {
	-- The original import could not fully process these assets. See PR #1.
	["23307906"] = "original-import-failure",
	["445118715"] = "original-import-failure",
	["445118914"] = "original-import-failure",
	["445119186"] = "original-import-failure",
	["445120580"] = "original-import-failure",
	["445122594"] = "original-import-failure",
	["445122795"] = "original-import-failure",
	["445127715"] = "original-import-failure",
	["445132899"] = "original-import-failure",
	["445136641"] = "original-import-failure",
	["445146200"] = "original-import-failure",
	["2535472650"] = "original-import-failure",
	["2845969550"] = "original-import-failure",
	["2846247073"] = "original-import-failure",
	["2936947382"] = "original-import-failure",
	["3016462854"] = "original-import-failure",
	["3061661395"] = "original-import-failure",
	["4504687245"] = "original-import-failure",
	["4504688440"] = "original-import-failure",
	["4504689279"] = "original-import-failure",
	["4504690230"] = "original-import-failure",
	["4510344627"] = "original-import-failure",
	["6468066575"] = "original-import-failure",
	["16648133530"] = "original-import-failure",
	["16648471753"] = "original-import-failure",
	["16648718579"] = "original-import-failure",
	["16648843454"] = "original-import-failure",
	["16649013455"] = "original-import-failure",
	["16649019530"] = "original-import-failure",
	["16649045008"] = "original-import-failure",
	["16649053805"] = "original-import-failure",

	-- These are cataloged as Gear, but every available version is a PNG.
	["806754856"] = "non-model-payload",
	["806882461"] = "non-model-payload",
	["887261871"] = "non-model-payload",

	-- These assets were removed because they had effectively left the catalog
	-- and broke comparison. See PR #9.
	["66416590"] = "catalog-invalid",
	["66416602"] = "catalog-invalid",

	-- AllGear includes these IDs, but their absence was not documented.
	["27476125"] = "unexplained",
	["44084677"] = "unexplained",
	["91366868"] = "unexplained",
	["103360212"] = "unexplained",
}
