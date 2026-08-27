--Made by Stickmasterluke


sp=script.Parent

scale=.5
jumpcooldown=1
color=BrickColor.new("Toothpaste")
transparency=.5
rate=1/30

local lastjump=tick()
local debris=game:GetService("Debris")
local cf=CFrame.new()

function waitfor(a,b,c)
	local c=c or 5*60
	local d=tick()+c
	while a:FindFirstChild(b)==nil and tick()<=d do
		wait()
	end
	return a:FindFirstChild(b)
end

wait(3)

local ct=waitfor(sp,"creator",5)
if ct~=nil then
	if ct.Value~=nil and ct.Value.Character~=nil then
		local holo=Instance.new("Model")
		holo.Name="Hologram"
		holo.Parent=sp

		t=Instance.new("Part")
		t.Name="Torso"
		t.CanCollide=false
		t.Locked=true
		t.BrickColor=color
		t.Transparency=transparency
		t.FormFactor="Custom"
		t.Size=Vector3.new(2,2,1)*scale
		t.TopSurface="Smooth"
		t.BottomSurface="Smooth"

		local h=Instance.new("Humanoid")
		h.MaxHealth=1
		h.Health=1
		h.Parent=holo

		bp=Instance.new("BodyPosition")
		bp.maxForce=Vector3.new(1,1,1)*(10^7)
		bp.position=sp.Position+Vector3.new(0,4,0)
		bp.Parent=t

		bg=Instance.new("BodyGyro")
		bg.maxTorque=Vector3.new(1,1,1)*(10^7)
		bg.cframe=cf
		bg.Parent=t

		t.CFrame=CFrame.new(sp.Position)
		t.Parent=holo

		he=Instance.new("Part")
		he.Name="Head"
		he.CanCollide=false
		he.Locked=true
		he.BrickColor=color
		he.Transparency=1
		he.FormFactor="Custom"
		he.Size=Vector3.new(0,0,0)
		he.TopSurface="Smooth"
		he.BottomSurface="Smooth"
		local neck=Instance.new("Weld")
		neck.Name="Neck"
		neck.Part0=t
		neck.Part1=he
		neck.C0=CFrame.new(Vector3.new(0,1.5,0)*scale)
		neck.Parent=t
		he.Parent=holo

		fhe=Instance.new("Part")
		fhe.Name="FakeHead"
		fhe.CanCollide=false
		fhe.Locked=true
		fhe.BrickColor=color
		fhe.Transparency=transparency
		fhe.FormFactor="Custom"
		fhe.Size=Vector3.new(1,1,1)*scale
		fhe.TopSurface="Smooth"
		fhe.BottomSurface="Smooth"
		local fneck=Instance.new("Weld")
		fneck.Name="FakeNeck"
		fneck.Part0=t
		fneck.Part1=fhe
		fneck.C0=CFrame.new(Vector3.new(0,1.5,0)*scale)
		fneck.Parent=t
		fhe.Parent=holo

		la=Instance.new("Part")
		la.Name="Left Arm"
		la.CanCollide=false
		la.Locked=true
		la.BrickColor=color
		la.Transparency=transparency
		la.FormFactor="Custom"
		la.Size=Vector3.new(1,2,1)*scale
		la.TopSurface="Smooth"
		la.BottomSurface="Smooth"
		local leftshoulder=Instance.new("Weld")
		leftshoulder.Name="LeftShoulder"
		leftshoulder.Part0=t
		leftshoulder.Part1=la
		leftshoulder.C0=CFrame.new(Vector3.new(-1.5,0,0)*scale)
		leftshoulder.Parent=t
		la.Parent=holo

		ra=Instance.new("Part")
		ra.Name="Right Arm"
		ra.CanCollide=false
		ra.Locked=true
		ra.BrickColor=color
		ra.Transparency=transparency
		ra.FormFactor="Custom"
		ra.Size=Vector3.new(1,2,1)*scale
		ra.TopSurface="Smooth"
		ra.BottomSurface="Smooth"
		local rightshoulder=Instance.new("Weld")
		rightshoulder.Name="RightShoulder"
		rightshoulder.Part0=t
		rightshoulder.Part1=ra
		rightshoulder.C0=CFrame.new(Vector3.new(1.5,0,0)*scale)
		rightshoulder.Parent=t
		ra.Parent=holo

		ll=Instance.new("Part")
		ll.Name="Left Leg"
		ll.CanCollide=false
		ll.Locked=true
		ll.BrickColor=color
		ll.Transparency=transparency
		ll.FormFactor="Custom"
		ll.Size=Vector3.new(1,2,1)*scale
		ll.TopSurface="Smooth"
		ll.BottomSurface="Smooth"
		local leftshoulder=Instance.new("Weld")
		leftshoulder.Name="LeftHip"
		leftshoulder.Part0=t
		leftshoulder.Part1=ll
		leftshoulder.C0=CFrame.new(Vector3.new(-.5,-2,0)*scale)
		leftshoulder.Parent=t
		ll.Parent=holo

		rl=Instance.new("Part")
		rl.Name="Right Leg"
		rl.CanCollide=false
		rl.Locked=true
		rl.BrickColor=color
		rl.Transparency=transparency
		rl.FormFactor="Custom"
		rl.Size=Vector3.new(1,2,1)*scale
		rl.TopSurface="Smooth"
		rl.BottomSurface="Smooth"
		local rightshoulder=Instance.new("Weld")
		rightshoulder.Name="RightHip"
		rightshoulder.Part0=t
		rightshoulder.Part1=rl
		rightshoulder.C0=CFrame.new(Vector3.new(.5,-2,0)*scale)
		rightshoulder.Parent=t
		rl.Parent=holo

		for i,v in ipairs(ct.Value.Character:GetChildren()) do
			if v.className=="CharacterMesh" then
				local cm=Instance.new("SpecialMesh")
				cm.MeshId="http://www.roblox.com/asset/?id="..tostring(v.MeshId)
				cm.Scale=Vector3.new(1,1,1)*scale
				if v.BodyPart.Name=="Head" then
					cm.Parent=he
				elseif v.BodyPart.Name=="LeftArm" then
					cm.Parent=la
				elseif v.BodyPart.Name=="LeftLeg" then
					cm.Parent=ll
				elseif v.BodyPart.Name=="RightArm" then
					cm.Parent=ra
				elseif v.BodyPart.Name=="RightLeg" then
					cm.Parent=rl
				elseif v.BodyPart.Name=="Torso" then
					cm.Parent=t
				end
			elseif v.className=="Accoutrement" or v.className=="Hat" then
				local hndl=v:FindFirstChild("Handle")
				if hndl~=nil then
					local hndl=hndl:clone()
					hndl.BrickColor=color
					hndl.Transparency=transparency
					hndl.Reflectance=0
					for i2,v2 in ipairs(hndl:GetChildren()) do
						if v2.className=="SpecialMesh" then
							v2.TextureId=""
							v2.Scale=v2.Scale*scale
						end
					end
					local hw=Instance.new("Weld")
					hw.Name="HandleWeld"
					hw.Part0=fhe
					hw.Part1=hndl
					hw.C1=(v.AttachmentPoint*CFrame.new(v.AttachmentPoint.p*(-1)))*CFrame.new(v.AttachmentPoint.p*scale)-Vector3.new(0,.5*scale,0)
					hw.Parent=hndl
					hndl.Parent=holo
				end
			elseif v.Name=="Head" then
				local hm=v:FindFirstChild("Mesh")
				if hm~=nil then
					hm:clone().Parent=fhe
				end
			end
		end

		gui=sp:FindFirstChild("JumpPointGui")
		if gui~=nil then
			local jumpbutton=gui:FindFirstChild("JumpButton")
			local plrgui=ct.Value:FindFirstChild("PlayerGui")
			if plrgui~=nil and jumpbutton~=nil then
				gui.Parent=plrgui
				jumpbutton.MouseButton1Down:connect(function()
					if ct~=nil and ct.Value~=nil and ct.Value.Character~=nil and tick()-lastjump>jumpcooldown then
						local torso=ct.Value.Character:FindFirstChild("Torso")
						local humanoid=ct.Value.Character:FindFirstChild("Humanoid")
						if torso~=nil and humanoid~=nil and humanoid.Health>0 and t~=nil then
							local sound=sp:FindFirstChild("WarpSound")
							if sound~=nil then
								sound:Play()
							end
							local tcf=torso.CFrame
							delay(0,function()
								local p=Instance.new("Part")
								p.BrickColor=color
								p.FormFactor="Custom"
								p.Size=Vector3.new(0,0,0)
								p.Anchored=true
								p.CanCollide=false
								p.TopSurface="Smooth"
								p.BottomSurface="Smooth"
								p.Name="Effect"
								local m=Instance.new("SpecialMesh")
								m.MeshType="Sphere"
								m.Parent=p
								debris:AddItem(p,5)
								p.CFrame=tcf
								p.Parent=game.Workspace

								local p2=Instance.new("Part")
								p2.BrickColor=color
								p2.FormFactor="Custom"
								p2.Size=Vector3.new(0,0,0)
								p2.Anchored=true
								p2.CanCollide=false
								p2.TopSurface="Smooth"
								p2.BottomSurface="Smooth"
								p2.Name="Effect"
								local m2=Instance.new("SpecialMesh")
								m2.MeshType="Sphere"
								m2.Parent=p2
								debris:AddItem(p2,5)
								p2.CFrame=t.CFrame
								p2.Parent=game.Workspace

								frames=.5/rate
								for frame=1,frames do
									local percent=frame/frames
									m.Scale=Vector3.new(5,5,5)*(1-percent)*8
									p.Transparency=percent
									m2.Scale=Vector3.new(5,5,5)*percent*8
									p2.Transparency=percent
									wait(rate)
								end
							end)
							torso.CFrame=t.CFrame
							lastjump=tick()
						end
					end
				end)
			end
		end
		while ct~=nil and ct.Value~=nil and ct.Value.Character~=nil and gui~=nil and gui.Parent~=nil and bp~=nil and bg~=nil and h~=nil and holo~=nil and h.Parent==holo and holo.Parent==sp and h.Health>0 do
			cf=cf*CFrame.Angles(0,.05,0)
			bp.position=sp.Position+Vector3.new(0,4,0)
			bg.cframe=cf
			wait(.15)
		end
	end
end

if bg~=nil then
	bg:remove()
end
if bp~=nil then
	bp:remove()
end
if gui~=nil then
	gui:remove()
end
local e=Instance.new("Explosion")
e.BlastPressure=0
e.Position=sp.Position
e.Parent=game.Workspace
									--Maybe add a sound
wait(.5)
sp:remove()









