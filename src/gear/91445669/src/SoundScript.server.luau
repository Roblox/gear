--Stickmasterluke


sp=script.Parent


function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		wait()
	end
	return parent:FindFirstChild(name)
end

playsound=waitfor(sp,"PlaySound")
soundname=waitfor(playsound,"SoundName")
handle=waitfor(sp,"Handle")

playsound.Changed:connect(function()
	local sound=handle:FindFirstChild(soundname.Value)
	if sound~=nil then
		sound:Play()
	end
end)


