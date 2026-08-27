local WhooshSound = Instance.new("Sound")
WhooshSound.SoundId = "http://www.roblox.com/asset/?id=55634401"
WhooshSound.Parent = script.Parent
	
for i = 1, 50 do
	WhooshSound:Play()
	wait(0.2)
end

script:Remove()
