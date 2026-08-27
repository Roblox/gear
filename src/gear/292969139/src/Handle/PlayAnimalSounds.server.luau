local Alpaca = script.Parent
local Sounds = Alpaca.AnimalSounds:GetChildren()

for _, Sound in pairs(Sounds) do
	Sound.Parent = Alpaca
end

while true do
	wait(math.random() * 5 + 1)
	Sounds[math.random(1, #Sounds)]:Play()
end