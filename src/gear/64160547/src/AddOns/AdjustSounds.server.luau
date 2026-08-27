--Made by Luckymaxer

Board = script.Parent

Sounds = {
	{Sound = Board:FindFirstChild("BoardDrop"), SoundId = "http://www.roblox.com/asset/?id=64137930"},
	{Sound = Board:FindFirstChild("BoardOllie"), SoundId = "http://www.roblox.com/asset/?id=64137930"},
	{Sound = Board:FindFirstChild("BoardStop"), SoundId = "http://www.roblox.com/asset/?id=64134923"},
	{Sound = Board:FindFirstChild("CruiseLoop"), SoundId = "http://www.roblox.com/asset/?id=64134836"},
}

for i, v in pairs(Sounds) do
	if v.Sound then
		v.Sound.SoundId = v.SoundId
	end
end