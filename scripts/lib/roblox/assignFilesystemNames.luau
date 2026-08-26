local ORIGINAL_NAME_ATTRIBUTE = "__MarketplaceGear_OriginalName"
local DUPLICATE_SUFFIX = "__"

export type Assignment<T> = {
	instance: T,
	filesystemName: string,
	originalName: string?,
}

local function assignFilesystemNames<T>(instances: { T }, getName: (T) -> string): { Assignment<T> }
	local counts: { [string]: number } = {}
	local reserved: { [string]: boolean } = {}
	for _, instance in instances do
		local key = string.lower(getName(instance))
		counts[key] = (counts[key] or 0) + 1
		reserved[key] = true
	end

	local occurrences: { [string]: number } = {}
	local used: { [string]: boolean } = {}
	local assignments = {}

	for _, instance in instances do
		local name = getName(instance)
		local key = string.lower(name)
		local filesystemName = name
		local originalName

		if counts[key] > 1 then
			occurrences[key] = (occurrences[key] or 0) + 1
			local suffix = occurrences[key]
			repeat
				filesystemName = `{name}{DUPLICATE_SUFFIX}{suffix}`
				suffix += 1
			until not reserved[string.lower(filesystemName)] and not used[string.lower(filesystemName)]
			originalName = name
		end

		used[string.lower(filesystemName)] = true
		table.insert(assignments, {
			instance = instance,
			filesystemName = filesystemName,
			originalName = originalName,
		})
	end

	return assignments
end

return {
	assign = assignFilesystemNames,
	ORIGINAL_NAME_ATTRIBUTE = ORIGINAL_NAME_ATTRIBUTE,
	DUPLICATE_SUFFIX = DUPLICATE_SUFFIX,
}
