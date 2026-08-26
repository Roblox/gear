export type Reference<T> = {
	source: T,
	propertyName: string,
	target: T,
}

export type Metadata = {
	id: string?,
	attributes: { [string]: string },
}

export type Plan<T> = {
	getMetadata: (instance: T) -> Metadata,
	referenceCount: number,
}

type ResolvedReference = {
	sourceIndex: number,
	propertyName: string,
	targetIndex: number,
}

local function findIndex<T>(instances: { T }, target: T): number?
	for index, instance in instances do
		if instance == target then
			return index
		end
	end
	return nil
end

local function planReferences<T>(
	instances: { T },
	references: { Reference<T> },
	idPrefix: string,
	describe: ((T) -> string)?
): Plan<T>
	local metadata: { Metadata } = {}
	for _ in instances do
		local entry: Metadata = { attributes = {} }
		table.insert(metadata, entry)
	end

	local resolved: { ResolvedReference } = {}
	local targeted: { [number]: boolean } = {}
	for _, reference in references do
		local sourceIndex = findIndex(instances, reference.source)
		assert(sourceIndex, "reference source is not part of the model")

		local targetIndex = findIndex(instances, reference.target)
		if not targetIndex then
			local source = if describe then describe(reference.source) else "instance"
			error(
				`{source}.{reference.propertyName} points outside the dumped model; `
					.. "the reference cannot be represented in this Rojo project"
			)
		end

		targeted[targetIndex] = true
		table.insert(resolved, {
			sourceIndex = sourceIndex,
			propertyName = reference.propertyName,
			targetIndex = targetIndex,
		})
	end

	for targetIndex in targeted do
		metadata[targetIndex].id = `{idPrefix}_{targetIndex}`
	end

	for _, reference in resolved do
		local targetId = assert(metadata[reference.targetIndex].id, "referenced target was not assigned an id")
		metadata[reference.sourceIndex].attributes[`Rojo_Target_{reference.propertyName}`] = targetId
	end

	return {
		referenceCount = #references,
		getMetadata = function(instance)
			local index = findIndex(instances, instance)
			assert(index, "instance is not part of the reference plan")
			return metadata[index]
		end,
	}
end

return planReferences
