--Made by Luckymaxer

Tool = script.Parent

ContentProvider = game:GetService("ContentProvider")

BaseUrl = "http://www.roblox.com/asset/?id="

Hieroglyphics = require(Tool:WaitForChild("Hieroglyphics"))

for i, v in pairs(Hieroglyphics) do
	ContentProvider:Preload(BaseUrl .. v)
end