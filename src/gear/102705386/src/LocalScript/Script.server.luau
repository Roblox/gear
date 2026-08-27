--Stickmasterluke


sp=script.Parent


debris=game:GetService("Debris")

exploded=false

function bang(hit)
	if hit~=nil and hit.Name~="Effect" and hit.Name~="Handle" then
		local h=hit.Parent:FindFirstChild("Humanoid")
		if h~=nil then
			local ct=sp:FindFirstChild("creator")
			local dt=sp:FindFirstChild("DamageTag")
			if ct~=nil and dt~=nil and ((not game.Players:GetPlayerFromCharacter(hit.Parent)) or game.Players:GetPlayerFromCharacter(hit.Parent)~=ct.Value) then
				for _,v in pairs(h:GetChildren()) do
					if v~=nil and v.className=="ObjectValue" then
						v:remove()
					end
				end
				ct:clone().Parent=h
				h:TakeDamage(dt.Value)
				dt.Value=dt.Value*.5
			end
		end
		if not exploded then
			local s=sp:FindFirstChild("RockSound")
			if s~=nil then
				s:play()
			end
			local s2=sp:FindFirstChild("DirtSound")
			if s2~=nil then
				s2:stop()
			end
			exploded=true
			for i=1,math.random(8,16) do
				local p=Instance.new("Part")
				p.Name="rock"
				p.FormFactor="Custom"
				p.Size=Vector3.new(math.random(5,20),math.random(5,20),math.random(5,20))*.1
				p.LeftSurface="Universal"
				p.RightSurface="Universal"
				p.FrontSurface="Universal"
				p.BackSurface="Universal"
				p.Anchored=false
				if math.random()<.5 then
					p.CanCollide=false
				end
				p.Locked=true
				p.BrickColor=sp.BrickColor
				local rp=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)
				p.CFrame=sp.CFrame*CFrame.new(rp*8)*CFrame.Angles(math.random()*6,math.random()*6,math.random()*6)
				p.Velocity=Vector3.new(0,30+(math.random()*30),0)+(rp*math.random(10,40))
				p.RotVelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*10
				debris:AddItem(p,2+(math.random()*4))
				p.Parent=game.Workspace
			end
		end
	end
end

sp.Touched:connect(bang)

while sp:FindFirstChild("Boulder")==nil do
	wait()
end

sp:FindFirstChild("Boulder").Touched:connect(bang)


