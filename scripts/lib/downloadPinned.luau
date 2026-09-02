local process = require("@lute/process")

local function parseSha256(stdout: string): string
	local hash = string.lower(stdout):match("=%s*(%x+)")
	if hash == nil or #hash ~= 64 then
		error(`could not parse sha256: {stdout}`)
	end
	return hash
end

local function fileSha256(path: string): string
	local result = process.run({ "openssl", "dgst", "-sha256", path })
	if not result.ok then
		error(`failed to hash {path}: {result.stderr}`)
	end
	return parseSha256(result.stdout)
end

local function downloadPinned(url: string, dest: string, expectedSha256: string)
	print(`> curl -fsSL -o {dest} {url}`)

	local result = process.run({ "curl", "-fsSL", "-o", dest, url }, {
		stdio = "inherit",
	})
	if not result.ok then
		error(`failed to download {url}`)
	end

	local actual = fileSha256(dest)
	local expected = string.lower(expectedSha256)
	if actual ~= expected then
		error(`checksum mismatch for {dest}\nexpected {expected}\nactual   {actual}`)
	end
end

return {
	downloadPinned = downloadPinned,
	fileSha256 = fileSha256,
	parseSha256 = parseSha256,
}
