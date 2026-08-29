local H = require("@root/site/htmluau")

local REPO_URL = "https://github.com/Roblox/marketplace-gear"

type NavLink = { label: string, href: string, active: boolean? }
type SortLink = { label: string, value: string, title: string }

local NAV_LINKS: { NavLink } = {
	{ label = "Catalog", href = "./index.html", active = true },
	{ label = "Source", href = `{REPO_URL}/tree/main/src/gear` },
	{ label = "Issues", href = `{REPO_URL}/issues` },
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

local function NavBar(): H.Element
	local links: { H.Child } = {}
	for _, link in NAV_LINKS do
		table.insert(links, H.a({ class = if link.active then "active" else "", href = link.href })({ link.label }))
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
			"Gear Cabinet is a static archive built from source in ",
			H.a({ href = REPO_URL })({ "Roblox/marketplace-gear" }),
			". Every item here is a real catalog asset, dumped to reviewable Rojo source.",
		}),
		H.p({ class = "footer-links" })({
			H.a({ href = REPO_URL })({ "GitHub" }),
			" | ",
			H.a({ href = `{REPO_URL}#readme` })({ "About" }),
			" | ",
			H.a({ href = `{REPO_URL}/issues` })({ "Report an Issue" }),
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
		"Catalog - Gear Cabinet",
		"Preserving the history of classic Roblox catalog gear, browsable as source.",
		"./catalog.js",
		H.createComponent(function()
			return H.div({ class = "page" })({
				Banner(),
				NavBar(),
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

local function GearPage(): string
	return document(
		"Gear Details - Gear Cabinet",
		"Explore a classic Roblox gear item and its instance tree.",
		"./gear.js",
		H.createComponent(function()
			return H.div({ class = "page" })({
				Banner(),
				NavBar(),
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
	gear = GearPage,
}
