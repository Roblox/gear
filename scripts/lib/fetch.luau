local json = require("@std/json")
local net = require("@lute/net")

type HttpMethod = "GET" | "POST" | "PATCH"

type FetchOptions = {
	method: HttpMethod?,
	headers: { [string]: string }?,
	body: string?,
}

local function fetch(url: string, options: FetchOptions)
	local method: HttpMethod = options.method or "GET"

	local res = net.request(url, {
		method = method,
		headers = options.headers,
		body = options.body,
	})

	if res.ok then
		return res
	else
		local body = json.deserialize(res.body)

		local problems: { string } = {}
		if body.errors then
			for _, err in body.errors do
				table.insert(problems, err.message)
			end
		elseif body.message then
			table.insert(problems, body.message)
		end

		error(
			`{res.status} {res.body} when attempting to {method} {url}`
				.. if #problems > 0 then `: {table.concat(problems, ", ")}` else "",
			2
		)
	end
end

return fetch
