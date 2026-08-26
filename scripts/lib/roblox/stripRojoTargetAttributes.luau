--[[
	Walk a built `Instance` tree and remove every attribute whose name
	starts with `Rojo_Target_`. Dumped files use these attributes to wire
	`Ref`-typed properties (e.g. Weld.Part0) across filesystem entries.
	Rojo resolves them at build time but leaves the source attributes on
	the instance, where they would otherwise leak into the published asset
	and show up as a fidelity diff against the source rbxm.

	Returns the count of attributes stripped (useful for sanity checks).
]]

local PREFIX = "Rojo_Target_"

local function stripRojoTargetAttributes(root: Instance): number
	local stripped = 0
	local function visit(instance: Instance)
		local attrs = instance:GetAttributes()
		for name in attrs do
			if string.sub(name, 1, #PREFIX) == PREFIX then
				instance:SetAttribute(name, nil)
				stripped += 1
			end
		end
		for _, child in instance:GetChildren() do
			visit(child)
		end
	end
	visit(root)
	return stripped
end

return stripRojoTargetAttributes
