--Stickmastertluke


sp=script.Parent


hitdelay=1
hitforce={30,60}


check=true
local sound=sp:WaitForChild("Sound")


sp.Touched:connect(function(hit)
	if hit and check then
		local h=hit.Parent:FindFirstChild("Humanoid")
		if h~=nil then
			check=false
			sp.Velocity=(Vector3.new(0,10,0)+(sp.Position-hit.Position)).unit*math.random(hitforce[1],hitforce[2])
			sp.CFrame=sp.CFrame+Vector3.new(0,.01,0)
			sound.Pitch=.5+math.random()
			sound:Play()
			wait(hitdelay)
			check=true
		end
	end
end)

wait(2*60)
sp:remove()


