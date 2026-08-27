--Rescripted by Luckymaxer

ContentProvider = game:GetService("ContentProvider")

BaseUrl = "http://www.roblox.com/asset/?id="

function LoadAssets(AssetList)
	for i, v in pairs(AssetList) do
		ContentProvider:Preload(BaseUrl .. v)
	end
end
 
LoadAssets({89722223, 37755007, 37755011, 37755016, 37755024, 37755034, 37755036, 37755042, 37755045, 37755047, 37755054})