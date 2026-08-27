--Stickmasterluke


sp=script.Parent


function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

local tag=waitfor(sp,"creator")
attached=false


sp.Touched:connect(function(hit)
	if hit and hit.Parent~=nil and attached==false then
		if string.sub(hit.Name,1,6)~="Handle" and string.sub(hit.Name,1,6)~="Effect" and hit.Name~="Left Leg" and hit.Name~="Right Leg" and attached==false then
			attached=true
			local h=hit.Parent:FindFirstChild("Humanoid")
			if h~=nil then
				if tag~=nil and tag.Value~=h then
					local w=Instance.new("Weld")
					w.Part0=hit
					w.Part1=sp
					w.Name="Bite"
					local stickcf=CFrame.new(hit.CFrame.p,sp.Position)*CFrame.new(0,0,-1)*CFrame.Angles(math.pi/2,math.random()*math.pi*2,0)
					w.C1=stickcf:inverse()*hit.CFrame
					w.Parent=sp
					sp.CanCollide=false
					--tag:clone().Parent=h
					--h:TakeDamage(16)	--Suddenly weaponized eating utensils
				else
					attached=false
				end
			else
				local w=Instance.new("Weld")
				w.Part0=hit
				w.Part1=sp
				w.Name="Bite"
				w.C1=sp.CFrame:inverse()*hit.CFrame
				w.Parent=sp
				sp.CanCollide=false
			end
			if attached then
				local sound=sp:FindFirstChild("DoinkSound")
				if sound~=nil then
					sound.Pitch=1+(math.random()*.35)
					sound:play()
				end
			end
		end
	end
end)

wait(.05)
if not attached then
	sp.CanCollide=true
end
wait(25)
sp:remove()































