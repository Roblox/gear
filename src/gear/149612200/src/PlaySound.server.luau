--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
PlaySound = Handle:WaitForChild("PlaySound")
Charging = Tool:WaitForChild("Charging")
Charge = Handle:WaitForChild("Charge")

Debris = game:GetService("Debris")

PlaySound.Changed:connect(function()
	if PlaySound.Value ~= "" then
		local SoundId = PlaySound.Value
		PlaySound.Value = ""
		local Sound = Instance.new("Sound")
		Sound.Looped = false
		Sound.Pitch = 0.5
		Sound.SoundId = "http://www.roblox.com/asset?id=" .. SoundId
		Sound.PlayOnRemove = false
		Sound.Volume = 1
		Debris:AddItem(Sound, 3)
		Sound.Parent = Handle
		wait()
		Sound:Play()
	end
end)

Charging.Changed:connect(function()
	if Charging.Value then
		Charge:Play()
	else
		Charge:Stop()
	end
end)