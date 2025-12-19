local process = require("@lute/process")

process.run({
	"rojo",
	"build",
	"-o",
	"gear.rbxl",
}, {
	stdio = "inherit",
})
