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
			'<div><br>\n<img src="gear.png">\n<input type="search">\n<meta charset="utf-8">\n<link rel="stylesheet">\n<hr>\n<source src="gear.mp4">\n<track src="captions.vtt"></div>',
			rendered
		)
	end)

	suite:case("normal elements retain closing tags", function(asserts: Asserts)
		asserts.eq("<div>content</div>", H.div()({ "content" })())
	end)
end)
