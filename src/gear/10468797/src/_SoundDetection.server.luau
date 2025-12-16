hammer = script.Parent.Handle
local HomerunSound = Instance.new("Sound")
HomerunSound.SoundId = "http://www.roblox.com/asset/?id=21343225"
HomerunSound.Parent = hammer
HomerunSound.Volume = 0.5
HomerunSound.Name = "Homerun"
local WhackSound = Instance.new("Sound")
WhackSound.SoundId = "http://www.roblox.com/asset/?id=10730819"
WhackSound.Parent = hammer
WhackSound.Volume = 1
WhackSound.Name = "Whack"
hammer.ChildAdded:connect(function(Child)
	wait()
	if Child.className == "StringValue" then 
		if Child.Name == "HomerunSound" then 
			HomerunSound:Play()
		elseif Child.Name == "WhackSound" then 
			WhackSound:Play()
		end 
		Child:Remove()
	end 
end)