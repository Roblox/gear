--Made by Stickmasterluke
--Surrounds you with serendipity


sp=script.Parent


local sound=Instance.new("Sound")
sound.SoundId="http://www.roblox.com/asset/?id=98332255"
sound.Parent=sp
local sound2=Instance.new("Sound")
sound2.SoundId="http://www.roblox.com/asset/?id=98333808"
sound2.Parent=sp

wait()

sound2:Play()
wait(1)

while sound do
	sound:Play()
	wait(3.05)
end

script:remove()
