--Stickmasterluke


sp=script.Parent

sounds={79080744,79080766}

function playsound()
	local s=Instance.new("Sound")
	s.SoundId="http://www.roblox.com/asset/?id="..tostring(sounds[math.random(1,#sounds)])
	s.Pitch=.8+(math.random()*.4)
	s.Volume=.5
	s.Parent=sp
	s:Play()
end

check=true

sp.Touched:connect(function(hit)
	if hit and hit.Parent~=nil and hit.Name~="Effect" and check and hit.Name~="Handle" and hit.Name~="InnerPart" then
		local bound=hit.Parent:FindFirstChild("Bind")
		if bound==nil then
			doeshit=true
			local tag=sp:FindFirstChild("creator")
			if tag~=nil and tag.Value~=nil and tag.Value.className=="Player" and tag.Value.Character~=nil and hit.Parent==tag.Value.Character then
				doeshit=false
			end
			if doeshit then
				check=false
				playsound()
				local h=hit.Parent:FindFirstChild("Humanoid")
				local t=hit.Parent:FindFirstChild("Torso")
				if h~=nil and t~=nil then
					sp.Mesh.Scale=Vector3.new(2.5,1.5,1.5)
					local w=Instance.new("Weld")
					w.Name="Bind"
					w.Part0=sp
					w.Part1=t
					w.Parent=hit.Parent
					for i=1,10 do
						h.Sit=true
						wait(1)
						playsound()
					end
					sp:remove()
				end
			end
		end
	end
end)


