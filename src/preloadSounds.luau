local ContentProvider = game:GetService("ContentProvider")

-- `Sound.TimeLength` reads 0 until the engine has fetched the audio, so any
-- comparison has to wait for both trees to finish loading first.
local function preloadSounds(roots: { Instance? })
	local sounds = {}
	for _, root in roots do
		if root == nil then
			continue
		end
		if root:IsA("Sound") then
			table.insert(sounds, root)
		end
		for _, descendant in root:GetDescendants() do
			if descendant:IsA("Sound") then
				table.insert(sounds, descendant)
			end
		end
	end

	if #sounds > 0 then
		ContentProvider:PreloadAsync(sounds)
	end
end

return preloadSounds
