-- Every AllGear asset that does not currently have a raw RBXM or source dump.
-- Keep entries here until the asset is recovered or proven not to be gear.
return {
	-- Cataloged as Gear, but every available version is a Hat.
	["23307906"] = "hat-payload",

	-- Cataloged as Gear, but every available version is an Accessory.
	["2845969550"] = "accessory-payload",
	["2846247073"] = "accessory-payload",
	["2936947382"] = "accessory-payload",
	["3016462854"] = "accessory-payload",
	["3061661395"] = "accessory-payload",
	["4504687245"] = "accessory-payload",
	["4504688440"] = "accessory-payload",
	["4504689279"] = "accessory-payload",
	["4504690230"] = "accessory-payload",
	["4510344627"] = "accessory-payload",
	["6468066575"] = "accessory-payload",
	["16648133530"] = "accessory-payload",
	["16648471753"] = "accessory-payload",
	["16648718579"] = "accessory-payload",
	["16648843454"] = "accessory-payload",
	["16649013455"] = "accessory-payload",
	["16649019530"] = "accessory-payload",
	["16649045008"] = "accessory-payload",
	["16649053805"] = "accessory-payload",

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
