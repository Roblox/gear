local fs = require("@lune/fs")
local net = require("@lune/net")
local process = require("@lune/process")
local task = require("@lune/task")

local MIME_TYPES: { [string]: string } = {
	css = "text/css; charset=utf-8",
	html = "text/html; charset=utf-8",
	jpeg = "image/jpeg",
	jpg = "image/jpeg",
	js = "text/javascript; charset=utf-8",
	json = "application/json; charset=utf-8",
	png = "image/png",
	svg = "image/svg+xml",
}

local port = tonumber(process.args[1]) or 8000
if not fs.isDir("_site") then
	error("Build the site first with: lune run site/generate.luau --offline")
end

net.serve(port, function(request: net.ServeRequest): net.ServeResponse
	local requestPath = if request.path == "/" then "/index.html" else request.path
	local relativePath = requestPath:gsub("^/+", "")
	if relativePath:find("..", 1, true) then
		return {
			status = 400,
			body = "Bad request",
		}
	end

	local path = `_site/{relativePath}`
	if not fs.isFile(path) then
		return {
			status = 404,
			body = "Not found",
		}
	end

	local extension = path:match("%.([^./]+)$") or ""
	return {
		status = 200,
		headers = {
			["Content-Type"] = MIME_TYPES[extension] or "application/octet-stream",
		},
		body = fs.readFile(path),
	}
end)

print(`The gear catalog is open at http://localhost:{port}`)
while true do
	task.wait(60)
end
