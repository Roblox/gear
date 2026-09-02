local test = require("@std/test")
local testTypes = require("@std/test/types")

type Asserts = testTypes.Asserts
type TestSuite = testTypes.TestSuite

local H = require("@root/site/htmluau")

test.suite("htmluau", function(suite: TestSuite)
	suite:case("void elements omit closing tags", function(asserts: Asserts)
		local rendered = H.div()({
			H.br(),
			H.img({ src = "gear.png" }),
			H.input({ type = "search" }),
			H.meta({ charset = "utf-8" }),
			H.link({ rel = "stylesheet" }),
			H.hr(),
			H.source({ src = "gear.mp4" }),
			H.track({ src = "captions.vtt" }),
		})()

		asserts.eq(
			'<div><br> <img src="gear.png"> <input type="search"> <meta charset="utf-8"> <link rel="stylesheet"> <hr> <source src="gear.mp4"> <track src="captions.vtt"></div>',
			rendered
		)
	end)

	suite:case("normal elements retain closing tags", function(asserts: Asserts)
		asserts.eq("<div>content</div>", H.div()({ "content" })())
	end)

	suite:case("adjacent children do not introduce whitespace", function(asserts: Asserts)
		local rendered = H.p()({
			"Built by ",
			H.a({ href = "https://example.com" })({ "Roblox Corporation" }),
			".",
			"Read ",
			H.a({ href = "https://example.com/docs" })({ "the docs" }),
			"for details.",
		})()

		asserts.eq(
			'<p>Built by <a href="https://example.com">Roblox Corporation</a>. Read <a href="https://example.com/docs">the docs</a> for details.</p>',
			rendered
		)
	end)
end)
