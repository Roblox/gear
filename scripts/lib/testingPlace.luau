local process = require("@lute/process")

local function requireEnv(name: string): string
	local value = process.env[name]
	if typeof(value) == "string" and value ~= "" then
		return value
	end
	error(`{name} must be set via a repo secret, CI env, or a local .env file`)
end

local function universeId(): string
	return requireEnv("ROBLOX_UNIT_TESTING_UNIVERSE_ID")
end

local function placeId(): string
	return requireEnv("ROBLOX_UNIT_TESTING_PLACE_ID")
end

return {
	universeId = universeId,
	placeId = placeId,
}
