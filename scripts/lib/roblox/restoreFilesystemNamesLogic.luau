local assignFilesystemNames = require("@scripts/lib/roblox/assignFilesystemNames")

local DUPLICATE_SUFFIX = assignFilesystemNames.DUPLICATE_SUFFIX

export type Adapter<T> = {
	getChildren: (T) -> { T },
	getName: (T) -> string,
	setName: (T, string) -> (),
	getOriginalName: (T) -> string?,
	clearOriginalName: (T) -> (),
	reparentInOrder: (T, { T }) -> (),
}

type OrderedEntry<T> = {
	instance: T,
	order: number,
}

local function restoreFilesystemNames<T>(root: T, adapter: Adapter<T>): number
	local restored = 0

	local function visit(instance: T)
		local originalName = adapter.getOriginalName(instance)
		if originalName ~= nil then
			adapter.setName(instance, originalName)
			adapter.clearOriginalName(instance)
			restored += 1
		end

		local duplicateGroups: { [string]: { OrderedEntry<T> } } = {}
		for _, child in adapter.getChildren(instance) do
			local childOriginalName = adapter.getOriginalName(child)
			if childOriginalName ~= nil then
				local childName = adapter.getName(child)
				local prefix = childOriginalName .. DUPLICATE_SUFFIX
				assert(childName:sub(1, #prefix) == prefix, `{childName} does not start with expected prefix {prefix}`)
				local order = tonumber(childName:sub(#prefix + 1))
				assert(order, `{childName} does not end with a numeric duplicate index`)

				duplicateGroups[childOriginalName] = duplicateGroups[childOriginalName] or {}
				table.insert(duplicateGroups[childOriginalName], {
					instance = child,
					order = order,
				})
			end
			visit(child)
		end

		for _, group in duplicateGroups do
			if #group < 2 then
				continue
			end
			table.sort(group, function(a: OrderedEntry<T>, b: OrderedEntry<T>)
				return a.order < b.order
			end)
			local ordered: { T } = {}
			for _, entry in group do
				table.insert(ordered, entry.instance)
			end
			adapter.reparentInOrder(instance, ordered)
		end
	end

	visit(root)
	return restored
end

return restoreFilesystemNames
