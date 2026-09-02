local H = require("@root/site/htmluau")

local REPO_URL = "https://github.com/Roblox/gear"

type NavLink = { label: string, href: string }
type SortLink = { label: string, value: string, title: string }

local NAV_LINKS: { NavLink } = {
	{ label = "Catalog", href = "./index.html" },
	{ label = "Oddities", href = "./oddities.html" },
	{ label = "Source", href = `{REPO_URL}/tree/main/src/gear` },
	{ label = "License", href = `{REPO_URL}/blob/main/LICENSE.txt` },
	{ label = "README", href = `{REPO_URL}#readme` },
	{ label = "Roblox.com", href = "https://www.roblox.com/catalog" },
}

local SORT_LINKS: { SortLink } = {
	{ label = "Name A-Z", value = "az", title = "Gear, A to Z" },
	{ label = "Name Z-A", value = "za", title = "Gear, Z to A" },
	{ label = "Most Instances", value = "instances", title = "Gear, Most Instances First" },
	{ label = "Fewest Instances", value = "fewest", title = "Gear, Fewest Instances First" },
	{ label = "Newest", value = "newest", title = "Gear, Newest First" },
	{ label = "Oldest", value = "oldest", title = "Gear, Oldest First" },
}

local function document(titleText: string, description: string, moduleScript: string?, contents: H.Element): string
	local headChildren: { H.Child } = {
		H.meta({ charset = "utf-8" }),
		H.meta({ name = "viewport", content = "width=device-width, initial-scale=1" }),
		H.meta({ name = "description", content = description }),
		H.title()({ titleText }),
		H.link({ rel = "stylesheet", href = "./styles.css" }),
	}
	if moduleScript then
		table.insert(headChildren, H.script({ src = moduleScript, type = "module" })({}))
	end

	return "<!doctype html>\n" .. H.html({ lang = "en" })({
		H.head()(headChildren),
		H.body()({ contents }),
	})()
end

local function Banner(): H.Element
	return H.div({ class = "banner" })({
		H.img({
			class = "banner-image",
			src = "./Banner.jpg",
			width = "898",
			height = "72",
			alt = "Think. Create. -- the 2008 ROBLOX site banner",
		})({}),
		H.span({ class = "wordmark" })({ "GEAR" }),
	})
end

local function NavBar(activeHref: string): H.Element
	local links: { H.Child } = {}
	for _, link in NAV_LINKS do
		table.insert(
			links,
			H.a({ class = if link.href == activeHref then "active" else "", href = link.href })({ link.label })
		)
	end
	return H.div({ class = "navbar" })({
		H.nav({ ["aria-label"] = "Main navigation" })(links),
	})
end

local function SearchStrip(): H.Element
	return H.div({ class = "search-strip" })({
		H.form({ class = "search-form", role = "search" })({
			H.label({ class = "sr-only", ["for"] = "search" })({ "Search gear" }),
			H.input({
				id = "search",
				type = "text",
				autocomplete = "off",
			}),
			H.button({ type = "submit", class = "grey-button" })({ "Search" }),
		}),
	})
end

local function SiteFooter(): H.Element
	return H.div({ class = "footer" })({
		H.p()({
			'ROBLOX, "Online Building Toy", characters, logos, names, and all related indicia are trademarks of ',
			H.a({ href = "https://www.roblox.com" })({ "Roblox Corporation" }),
			". Gear data and thumbnails © Roblox.",
		}),
		H.p()({
			"This catalog is a static archive built from source in ",
			H.a({ href = REPO_URL })({ "Roblox/gear" }),
			". Every item here is a real catalog asset, dumped to reviewable Rojo source.",
		}),
		H.p({ class = "footer-links" })({
			H.a({ href = REPO_URL })({ "GitHub" }),
			" | ",
			H.a({ href = `{REPO_URL}#readme` })({ "About" }),
			" | ",
			H.a({ href = `{REPO_URL}/blob/main/LICENSE.txt` })({ "License" }),
			" | ",
			H.a({ href = `{REPO_URL}/blob/main/SECURITY.md` })({ "Security" }),
			" | ",
			H.a({ href = "https://www.roblox.com/catalog" })({ "Roblox Catalog" }),
		}),
	})
end

local function CatalogSidebar(): H.Element
	local sortLinks: { H.Child } = {}
	for index, link in SORT_LINKS do
		table.insert(
			sortLinks,
			H.li()({
				H.a({
					class = if index == 1 then "selected" else "",
					href = "#catalog",
					["data-sort"] = link.value,
					["data-title"] = link.title,
				})({ link.label }),
			})
		)
	end

	return H.div({ class = "sidebar" })({
		H.h1()({ "Catalog" }),
		H.p({ class = "sidebar-tagline" })({ "Browse Classic ROBLOX Gear!" }),
		H.h2()({ "Browse" }),
		H.ul({ class = "sidebar-list", id = "sort-list" })(sortLinks),
		H.h2()({ "Letter" }),
		H.div({ class = "sidebar-letters", id = "alphabet", ["aria-label"] = "Filter by first letter" }),
		H.h2()({ "Fun Facts" }),
		H.ul({ class = "sidebar-facts", id = "fun-facts" }),
		H.h2()({ "The Goal" }),
		H.p({ class = "sidebar-note" })({
			"The goal of this project is to preserve the history of classic catalog gear.",
		}),
		H.p({ class = "sidebar-note" })({
			H.a({ href = REPO_URL })({ "View the source on GitHub »" }),
		}),
	})
end

local function CatalogPage(): string
	return document(
		"Catalog - Roblox Gear",
		"Preserving the history of classic Roblox catalog gear, browsable as source.",
		"./catalog.js",
		H.createComponent(function()
			return H.div({ class = "page" })({
				Banner(),
				NavBar("./index.html"),
				SearchStrip(),
				H.div({ class = "body" })({
					CatalogSidebar(),
					H.div({ class = "content", id = "catalog" })({
						H.div({ class = "content-head" })({
							H.h2({ id = "catalog-title" })({ "All Gear, Alphabetized" }),
							H.span({ id = "result-count", class = "result-count", ["aria-live"] = "polite" })({
								"Loading...",
							}),
						}),
						H.div({ id = "catalog-grid", class = "item-grid", ["aria-live"] = "polite" }),
						H.div({ id = "empty-state", class = "notice", hidden = "hidden" })({
							H.strong()({ "No gear found." }),
							H.br(),
							"Try another name, asset ID, or letter.",
						}),
						H.div({ class = "pager" })({
							H.button({ id = "load-more", class = "pager-link", type = "button", hidden = "hidden" })({
								"Show More Gear >>",
							}),
						}),
					}),
				}),
				SiteFooter(),
			})
		end)({})({})
	)
end

local function OddityCard(
	assetId: string,
	catalogName: string,
	created: string,
	dimensions: string,
	description: { H.Child },
	alt: string
): H.Element
	return H.div({ class = "oddity-card" })({
		H.a({ class = "oddity-image", href = `./oddities/{assetId}.png` })({
			H.img({ src = `./oddities/{assetId}.png`, alt = alt })({}),
		}),
		H.div({ class = "oddity-copy" })({
			H.h3()({ `Asset {assetId}` }),
			H.p({ class = "oddity-meta" })({
				H.b()({ "Catalog name:" }),
				` {catalogName} · `,
				H.b()({ "Created:" }),
				` {created} · {dimensions}`,
			}),
			H.p()(description),
			H.p()({
				H.a({ href = `https://www.roblox.com/catalog/{assetId}` })({ "View the Gear page on Roblox »" }),
			}),
		}),
	})
end

local function DelayedReleaseLink(assetId: string, name: string): H.Element
	return H.li()({
		H.a({ href = `https://www.roblox.com/catalog/{assetId}` })({ name }),
		` (${assetId})`,
	})
end

local function OdditiesPage(): string
	return document(
		"Archival Oddities - Roblox Gear",
		"Odd artifacts and mistakes preserved in the Roblox gear catalog.",
		nil,
		H.createComponent(function()
			return H.div({ class = "page" })({
				Banner(),
				NavBar("./oddities.html"),
				H.div({ class = "body" })({
					H.div({ class = "content content-wide" })({
						H.p({ class = "breadcrumb" })({
							H.a({ href = "./index.html" })({ "Catalog" }),
							" » Archival Oddities",
						}),
						H.h1({ class = "oddity-title" })({ "Archival Oddities" }),
						H.p({ class = "oddity-intro" })({
							"This archive starts from a dump of catalog assets with type Gear. Those should all be Tools. What we actually archived includes textures uploaded as Gear, items parked a thousand years in the future, names that never quite landed, drafts that were uploaded over and over then blanked out, and a pair of Tools that contain nothing at all.",
						}),
						H.div({ class = "panel" })({
							H.div({ class = "panel-head" })({
								H.h2()({ "Forbidden Gear" }),
							}),
							H.div({ class = "panel-body oddity-list" })({
								H.p()({
									"These Roblox-created assets are type 19, but asset delivery serves a PNG instead of a model — each one an avatar texture uploaded into the Gear category by mistake.",
								}),
								OddityCard("806754856", "_", "May 15, 2017", "1024×1024 PNG", {
									"An unwrapped texture sheet for ",
									H.a({ href = "https://www.roblox.com/bundles/59/Zoey-The-Fashionista" })({
										"Zoey: The Fashionista",
									}),
									"— the black top, pink skirt, and limbs laid out on a single page. The bundle that shipped splits the same artwork into one smaller texture per body part.",
								}, "A texture sheet of pink and black Roblox avatar clothing pieces"),
								OddityCard("806882461", "__", "May 15, 2017", "388×272 PNG", {
									"A draft of Zoey's torso texture. It is the same 388×272 size as the one ",
									H.a({ href = "https://www.roblox.com/catalog/807194095" })({ "Zoey Torso" }),
									"ships today and matches it across roughly 85% of its pixels, with the leftover paint around the edges still uncleaned.",
								}, "A pink skirt and black top painted as a flat Roblox torso texture"),
								OddityCard("887261871", ".", "June 27, 2017", "256×256 PNG", {
									"The frames and lenses of ",
									H.a({ href = "https://www.roblox.com/catalog/890860816/Neon-Green-Thumb-Shades" })({
										"Neon Green Thumb Shades",
									}),
									"flattened out so the arms fold away to either side. The texture that accessory serves today is byte-for-byte identical to this file.",
								}, "Neon green sunglasses frames with magenta lenses, unwrapped flat"),
							}),
						}),
						H.div({ class = "panel oddity-section" })({
							H.div({ class = "panel-head" })({
								H.h2()({ "Gear from the Year 3000" }),
							}),
							H.div({ class = "panel-body" })({
								H.p()({
									"These 11 assets are delayed releases with on-sale dates parked roughly 1,000 years in the future. Public catalog APIs hide their metadata, even though thumbnails and catalog redirects still work.",
								}),
								H.ul({ class = "delayed-release-list" })({
									DelayedReleaseLink("361950562", "2/13 - Dominus Sword"),
									DelayedReleaseLink("583634140", "12/23 - Orbital Violin: Deep Freeze"),
									DelayedReleaseLink("754910297", "Noble Knight Sword"),
									DelayedReleaseLink("754930870", "Black Knight Sword"),
									DelayedReleaseLink("858743383", "6/9 - Robo Attack Sheetah"),
									DelayedReleaseLink("1180416995", "Neon Space Cutlass"),
									DelayedReleaseLink("1425156865", "2/23 - Star Tailslide Grind Skateboard"),
									DelayedReleaseLink("2620420487", "Yeti Shoes"),
									DelayedReleaseLink("2620442780", "Icicle Kunai"),
									DelayedReleaseLink("2750187687", "Year of the Boar Lantern"),
									DelayedReleaseLink("2830538074", "Neon Tiger Mount"),
								}),
							}),
						}),
						H.div({ class = "panel oddity-section" })({
							H.div({ class = "panel-head" })({
								H.h2()({ "The Empty Kunai" }),
							}),
							H.div({ class = "panel-body" })({
								H.p()({
									H.a({ href = "https://www.roblox.com/catalog/2620442780" })({ "2620442780" }),
									"redirects as Icicle Kunai and sits in the delayed-release list above. The current asset version is an empty model. Version 1 is a Tool named RavenSword — a MeshPart handle plus a ThumbnailCamera — recovered into ",
									H.a({ href = `{REPO_URL}/tree/main/src/gear/2620442780` })({
										"src/gear/2620442780",
									}),
									"from that historical version.",
								}),
							}),
						}),
						H.div({ class = "panel oddity-section" })({
							H.div({ class = "panel-head" })({
								H.h2()({ "A Sword by Any Other Name" }),
							}),
							H.div({ class = "panel-body" })({
								H.p()({
									"Three nearby assets inherited the Tool name RavenSword, and a fourth never got a real catalog slug at all.",
								}),
								H.ul({ class = "oddity-plain-list" })({
									H.li()({
										H.a({ href = "./gear.html?id=2535102249" })({ "2535102249" }),
										"is an archived Tool actually named RavenSword.",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=2620420487" })({ "2620420487" }),
										"catalogs as Yeti Shoes, but the Tool inside is named RavenSword.",
									}),
									H.li()({
										H.a({ href = "https://www.roblox.com/catalog/2620442780" })({ "2620442780" }),
										"catalogs as Icicle Kunai. Version 1 is also a RavenSword.",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=2830538074" })({ "2830538074" }),
										"is Neon Tiger Mount. Its catalog slug is the placeholder asset-version-me.",
									}),
								}),
							}),
						}),
						H.div({ class = "panel oddity-section" })({
							H.div({ class = "panel-head" })({
								H.h2()({ "Ten Uploads, One Empty Hat" }),
							}),
							H.div({ class = "panel-body" })({
								H.p()({
									"On the night of June 30, 2016, ten unnamed assets appeared in about 45 minutes. Version 1 on six of them is GoldenRailSplitterAxe — four files are byte-identical, then two slightly smaller copies. Version 1 on the other four is one 2016July4thFireworks binary. Around 1:00 UTC on July 1, every one of those IDs was overwritten with an empty Hat named Empty.",
								}),
								H.p()({
									"Ten minutes before the wipe, the real catalog items were created: ",
									H.a({ href = "./gear.html?id=445150567" })({ "Lincoln's Golden Rail Splitter" }),
									"and ",
									H.a({ href = "./gear.html?id=445151478" })({ "4th of July 2016 Fireworks" }),
									"— the drafts are smaller than what shipped. The dump kept every ID, so the archive still has the version-1 Tools.",
								}),
								H.ul({ class = "delayed-release-list" })({
									H.li()({
										H.a({ href = "./gear.html?id=445118715" })({ "445118715" }),
										" GoldenRailSplitterAxe",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445118914" })({ "445118914" }),
										" GoldenRailSplitterAxe",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445119186" })({ "445119186" }),
										" GoldenRailSplitterAxe",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445127715" })({ "445127715" }),
										" GoldenRailSplitterAxe",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445132899" })({ "445132899" }),
										" GoldenRailSplitterAxe, missing RightSlash",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445146200" })({ "445146200" }),
										" GoldenRailSplitterAxe, missing RightSlash",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445120580" })({ "445120580" }),
										" 2016July4thFireworks",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445122594" })({ "445122594" }),
										" 2016July4thFireworks",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445122795" })({ "445122795" }),
										" 2016July4thFireworks",
									}),
									H.li()({
										H.a({ href = "./gear.html?id=445136641" })({ "445136641" }),
										" 2016July4thFireworks",
									}),
								}),
								H.p()({
									H.a({ href = "./gear.html?id=445132899" })({ "445132899" }),
									"and ",
									H.a({ href = "./gear.html?id=445146200" })({ "445146200" }),
									"are those smaller axe drafts. The raw RBXMs omit the RightSlash Animation; the server script still waits for it, so the Tool never finishes loading. The other four copies and the shipped splitter include RightSlash.",
								}),
							}),
						}),
						H.div({ class = "panel oddity-section" })({
							H.div({ class = "panel-head" })({
								H.h2()({ "A Tool Named Tool" }),
							}),
							H.div({ class = "panel-body" })({
								H.p()({
									H.a({ href = "./gear.html?id=66416590" })({ "66416590" }),
									"and ",
									H.a({ href = "./gear.html?id=66416602" })({ "66416602" }),
									'were created 22 seconds apart on November 25, 2011. The catalog still calls them unnamed and "??". Each RBXM is a Tool named Tool with no children, and the two files are byte-for-byte identical.',
								}),
							}),
						}),
					}),
				}),
				SiteFooter(),
			})
		end)({})({})
	)
end

local function GearPage(): string
	return document(
		"Gear Details - Roblox Gear",
		"Explore a classic Roblox gear item and its instance tree.",
		"./gear.js",
		H.createComponent(function()
			return H.div({ class = "page" })({
				Banner(),
				NavBar("./index.html"),
				SearchStrip(),
				H.div({ class = "body" })({
					H.div({ class = "content content-wide" })({
						H.p({ class = "breadcrumb" })({
							H.a({ href = "./index.html" })({ "Catalog" }),
							" » ",
							H.span({ id = "gear-crumb" })({ "Gear" }),
						}),
						H.p({ id = "detail-loading", class = "notice" })({ "Loading gear details..." }),
						H.div({ id = "detail-error", class = "notice", hidden = "hidden" })({
							H.strong()({ "We could not find that gear." }),
							H.br(),
							"It may have rolled under another shelf. ",
							H.a({ href = "./index.html" })({ "Return to the catalog" }),
							".",
						}),
						H.div({ id = "gear-detail", hidden = "hidden" })({
							H.div({ class = "detail-top" })({
								H.div({ class = "detail-thumb" })({
									H.img({ id = "gear-image", alt = "" }),
								}),
								H.div({ class = "detail-info" })({
									H.h1({ id = "gear-name" }),
									H.p({ id = "gear-description", class = "detail-description" }),
									H.div({ id = "gear-facts", class = "fact-list" }),
									H.p({ class = "detail-actions" })({
										H.a({ id = "catalog-link", class = "grey-button", href = "" })({
											"View on Roblox",
										}),
										H.a({ id = "source-link", class = "grey-button", href = "" })({
											"Browse Source",
										}),
									}),
								}),
							}),
							H.div({ class = "panel" })({
								H.div({ class = "panel-head" })({
									H.h2()({ "Instance Tree" }),
									H.span({ class = "panel-tools" })({
										H.label({ class = "sr-only", ["for"] = "tree-search" })({
											"Filter instance tree",
										}),
										H.input({ id = "tree-search", type = "text", autocomplete = "off" }),
										H.button({ id = "expand-tree", class = "grey-button", type = "button" })({
											"Expand All",
										}),
									}),
								}),
								H.div({ class = "panel-body tree-layout" })({
									H.div({ id = "instance-tree", class = "instance-tree" }),
									H.div({ id = "node-inspector", class = "node-inspector" })({
										H.p({ class = "inspector-hint" })({ "Select an instance to inspect it." }),
									}),
								}),
							}),
						}),
					}),
				}),
				SiteFooter(),
			})
		end)({})({})
	)
end

return {
	catalog = CatalogPage,
	oddities = OdditiesPage,
	gear = GearPage,
}
