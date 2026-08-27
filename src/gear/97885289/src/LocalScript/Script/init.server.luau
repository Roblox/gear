--Stickmasterluke


sp=script.Parent


rate=1/30


bolt={}
debris=game:GetService("Debris")
check=true

wait()
for _,v in pairs(sp:GetChildren()) do
	if v.className=="Part" and v.Name~="EffectWire" then
		v:BreakJoints()
		v.Anchored=true
		table.insert(bolt,v)
	end
end

if bolt[2]~=nil then
	local dist=(bolt[1].Position-bolt[2].Position).magnitude
	local p=Instance.new("Part")
	p.Name="EffectWire"
	p.BrickColor=BrickColor.new("Institutional white")
	p.CanCollide=false
	p.Anchored=true
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	p.formFactor="Custom"
	p.Size=Vector3.new(.2,dist,.2)
	local m=Instance.new("CylinderMesh")
	m.Scale=Vector3.new(.05,.2,.05)*5
	m.Parent=p
	p.CFrame=((CFrame.new(bolt[1].Position,bolt[2].Position)*CFrame.Angles(math.pi/2,0,0))*CFrame.new(0,-dist*.5,0))+Vector3.new(0,.5,0)
	p.Parent=sp
	p.Touched:connect(function(hit)
		if hit~=nil then
			local h=hit.Parent:FindFirstChild("Humanoid")
			local t=hit.Parent:FindFirstChild("Torso")
			local sus=hit.Parent:FindFirstChild("StandUpScript")
			if h~=nil and t~=nil and sus==nil then
				iscreator=false
				local plr=game.Players:GetPlayerFromCharacter(hit.Parent)
				local creatortag=sp:FindFirstChild("creator")
				if plr~=nil and creatortag~=nil then
					if plr==creatortag.Value then
						iscreator=true
					end
				end
				if not iscreator then
					for _,v in pairs(sp:GetChildren()) do
						if v.className=="Part" then
							v.Transparency=0
						end
					end
					check=false
					h.PlatformStand=true
					local cf=(t.CFrame*CFrame.new(0,-2.5,-2))*CFrame.Angles(-math.pi/2,0,0)
					local bg=Instance.new("BodyGyro")
					bg.cframe=cf
					bg.maxTorque=Vector3.new(1,1,1)*(10^6)
					bg.Parent=t
					t.CFrame=cf
					h.PlatformStand=true
					for _,v in pairs(h:GetChildren()) do
						if v~=nil and v.Name=="creator" then
							v:remove()
						end
					end
					if creatortag~=nil then
						creatortag:clone().Parent=t
					end
							
					local sup=script:FindFirstChild("StandUpScript")
					if sup~=nil then
						local sup2=sup:clone()
						sup2.Parent=hit.Parent
						sup2.Disabled=false
					end
					debris:AddItem(bg,5)
					wait(3)
					sp:remove()
				end
			end
		end
	end)
	wait(2)
	local frames=math.floor(3/rate)
	for frame=1,frames do
		local percent=frame/frames
		if check then
			for _,v in pairs(sp:GetChildren()) do
				if v.className=="Part" then
					v.Transparency=percent*.8
				end
			end
			wait(rate)
		end
	end
	wait(120)
end

sp:remove()


