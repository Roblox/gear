local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getUploadedAssetForComparison(sourceGear: Instance): Instance?
	for _, rawGear in ReplicatedStorage.Assets:GetChildren() do
		if rawGear.Name == sourceGear.Name then
			return rawGear
		end
	end
	return nil
end

return getUploadedAssetForComparison
