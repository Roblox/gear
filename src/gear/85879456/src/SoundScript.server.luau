--Stickamsterluke
--this script this made so that the sound is not played locally


sp=script.Parent

local s=Instance.new("Sound")
s.Volume=2
s.SoundId="http://www.roblox.com/asset/?id=77170993"
s.Looped=false
s.PlayOnRemove=false
s.Parent=sp
wait()
s:Play()


