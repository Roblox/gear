zombieParent = false

local soundIds = {25954372, 25954392, 25954407}
local sounds = {}
for i=1,#soundIds do
	local s = Instance.new("Sound")
	s.SoundId = "http://www.roblox.com/asset/?id=" .. soundIds[i]
	s.Volume = 1
	s.Parent = script.Parent
	sounds[#sounds + 1] = s
end

while zombieParent == false do

	wait(1)
	if script.Parent.Name == "Head" then
		zombieParent = true
	end

end

while true do
	wait(math.random(5,10))
	local i = math.random(1, #sounds)
	sounds[i].Pitch = .8 + (math.random() * .2)
	sounds[i]:Play()
end