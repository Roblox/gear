--Stickmasterluke


sp=script.Parent


time=5
radius=10

function playsound(pitch) --Fix implemented by Luckymaxer
	pitch=pitch or 1
	local s=sp:FindFirstChild("BeepTone")
	if s~=nil then
		s.Pitch=pitch
		s:Play()
	end
end

for i=1,time-1 do
	wait(1)
	playsound(1.5)
end
wait(1)
playsound(2)
wait(.1)
playsound(2)
wait(.1)
playsound(2)
wait(.5)
local e=Instance.new("Explosion")
e.BlastPressure=2*(10^6)
e.BlastRadius=radius
e.Position=sp.Position
e.Parent=game.Workspace
local sound=Instance.new("Sound")
sound.SoundId="rbxasset://sounds\\Rocket shot.wav"
sound.Parent=sp
sound.Volume=1
sound:play()
sp.CanCollide=false
sp.Anchored=true
sp.Transparency=1
wait(2)
sp:remove()




