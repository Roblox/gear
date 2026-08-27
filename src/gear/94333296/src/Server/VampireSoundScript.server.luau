--Made by Stickmasterluke
--Surrounds you with serendipity


sp=script.Parent


local sound=Instance.new("Sound")
sound.SoundId="http://www.roblox.com/asset/?id=94688738"
sound.Volume = 1.5
sound.Parent=sp

while sound do
	--sound.Pitch=(math.random()*.2)+.9
	sound.PlaybackSpeed=(math.random()*.2)+.9
	sound:Play()
	wait((math.random()*2)+9)
end

script:Destroy()
