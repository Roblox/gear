--Stickmasterluke

wait()
sp=script.Parent


while script:FindFirstChild("Dance1")==nil or script:FindFirstChild("Dance2")==nil or script:FindFirstChild("DanceSound")==nil do
	wait()
end


local h=sp:FindFirstChild("Humanoid")
if h~=nil then
	h.WalkSpeed=0
	local dance=h:LoadAnimation(script:FindFirstChild("Dance"..tostring(math.random(1,2))))
	if dance then
		dance:Play()
	end
	sound=script.DanceSound
	if sp:FindFirstChild("Torso")~=nil then
		sound.Parent=sp.Torso
	end
	wait(.1)
	sound:Play()
	wait(5.5)
	if dance then
		dance:Stop()
	end
	if sound~=nil then
		sound:Stop()
		sound:remove()
	end
	h.WalkSpeed=16
end


script:remove()

