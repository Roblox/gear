--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
PlaySound = Handle:WaitForChild("PlaySound")

Debris = game:GetService("Debris")

PlaySound.Changed:connect(function()
	if PlaySound.Value ~= "" then
		local SoundId = PlaySound.Value
		PlaySound.Value = ""
		local Sound = Instance.new("Sound")
		Sound.Looped = false
		Sound.Pitch = 1
		Sound.SoundId = "http://www.roblox.com/asset?id=" .. SoundId
		Sound.PlayOnRemove = false
		Sound.Volume = 1
		Debris:AddItem(Sound, 3)
		Sound.Parent = Handle
		wait()
		Sound:Play()
	end
end)