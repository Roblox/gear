--Made by Luckymaxer

ContentProvider = game:GetService("ContentProvider")

BaseUrl = "http://www.roblox.com/asset/?id="

Assets = require(script.Parent:WaitForChild("Assets"))

for i, v in pairs(Assets) do
	if type(v) == "table" then
		for ii, vv in pairs(v) do
			ContentProvider:Preload(BaseUrl .. vv)
		end
	elseif type(v) == "string" or type(v) == "number" then
		ContentProvider:Preload(BaseUrl .. v)
	end
end