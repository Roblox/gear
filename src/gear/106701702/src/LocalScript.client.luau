--Made by Stickmasterluke


sp=script.Parent


smackdamage=26
attacks={"HelicopterSpin","ClawAttack"}
rate=1/30

check=true
check2=true
pageused=false
damage=0
lastclick=0
local debris=game:GetService("Debris")

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

waitfor(sp,"Handle")

sp.Handle.Transparency=0

function smack(hit,part)
	if hit~=nil then
		local h=hit.Parent:FindFirstChild("Humanoid")
		if h~=nil and h.Health>0 and check2 and damage~=0 then
			local chr=sp.Parent
			local plr=game.Players.LocalPlayer
			local mh=chr:FindFirstChild("Humanoid")
			if mh~=nil and mh.Health>0 and h~=mh and plr~=nil then
				check2=false
				for _,v in ipairs(h:GetChildren()) do
					if v.Name=="creator" then
						v:remove()
					end
				end
				local tag=Instance.new("ObjectValue")
				tag.Name="creator"
				tag.Value=plr
				tag.Parent=h
				local smacksound=part:FindFirstChild("SmackSound")
				if smacksound~=nil then
					smacksound.Pitch=.75+(math.random()*.5)
					smacksound:Play()
				end
				h:TakeDamage(damage)
				wait(.2)
				check2=true
			end
		end
	end
end

function makefakearms()
	local chr=sp.Parent
	local mh=chr:FindFirstChild("Humanoid")
	local t=chr:FindFirstChild("Torso")
	if mh~=nil and mh.Health>0 and t then
		local stretchsound=sp.Handle:FindFirstChild("StretchSound")
		if stretchsound~=nil then
			stretchsound.Pitch=.9+(math.random()*.5)
			stretchsound:Play()
		end
		if flarm then
			flarm:remove()
		end
		if frarm then
			frarm:remove()
		end
		for _,v in pairs(chr:GetChildren()) do
			if v.Name=="FakeLeftArm" or v.Name=="FakeRightArm" then
				v:remove()
			end
		end
		local larm=chr:FindFirstChild("Left Arm")
		if larm~=nil then
			larm.Transparency=1
			flarm=larm:Clone()
			flarm:ClearAllChildren()
			sp.Handle.SmackSound:clone().Parent=flarm
			flarm.FormFactor="Custom"
			flarm.CanCollide=false
			flarm.Anchored=false
			flarm.Transparency=0
			flarm.Name="FakeLeftArm"
			lw=Instance.new("Weld")
			lw.Name="Weld"
			lw.Part0=larm
			lw.Part1=flarm
			lw.Parent=flarm
			flarm.Touched:connect(function(hit) smack(hit,flarm) end)
			flarm.Parent=chr
		end
		local rarm=chr:FindFirstChild("Right Arm")
		if rarm~=nil then
			rarm.Transparency=1
			frarm=rarm:Clone()
			frarm:ClearAllChildren()
			sp.Handle.SmackSound:clone().Parent=frarm
			frarm.FormFactor="Custom"
			frarm.CanCollide=false
			frarm.Anchored=false
			frarm.Transparency=0
			frarm.Name="FakeLeftArm"
			rw=Instance.new("Weld")
			rw.Name="Weld"
			rw.Part0=rarm
			rw.Part1=frarm
			rw.Parent=frarm
			frarm.Touched:connect(function(hit) smack(hit,frarm) end)
			frarm.Parent=chr
		end
		for _,v in pairs(chr:GetChildren()) do
			if v.className=="CharacterMesh" then
				if v.BodyPart==Enum.BodyPart.LeftArm and flarm then
					local m=Instance.new("SpecialMesh")
					m.Name="Mesh"
					m.MeshId="http://www.roblox.com/asset/?id="..tostring(v.MeshId)
					--m.TextureId="http://www.roblox.com/asset/?id="..tostring(v.OverlayTextureId)
					m.Parent=flarm
				elseif v.BodyPart==Enum.BodyPart.RightArm and frarm then
					local m=Instance.new("SpecialMesh")
					m.Name="Mesh"
					m.MeshId="http://www.roblox.com/asset/?id="..tostring(v.MeshId)
					--m.TextureId="http://www.roblox.com/asset/?id="..tostring(v.OverlayTextureId)
					m.Parent=frarm
				end
			end
		end
	end
end

function Equipped(mouse)
	if mouse~=nil then
		mouse.Button1Down:connect(function()
			if not pageused then
				pageused=true
				sp.CanBeDropped=false
				sp.Handle.Transparency=1
				local fakehandle=sp.Handle:clone()
				local bf=Instance.new("BodyForce")
				bf.force=Vector3.new(0,(fakehandle:GetMass()*196.2)+.5,0)
				bf.Parent=fakehandle
				fakehandle.Name="Effect"
				fakehandle.Transparency=0
				fakehandle.CanCollide=false
				fakehandle.RotVelocity=Vector3.new(0,10,0)
				local fire=Instance.new("Fire")
				fire.Parent=fakehandle
				delay(0,function()
					wait(1)
					if fakehandle~=nil then
						fakehandle.Transparency=1
					end
					wait(1)
					if fire~=nil then
						fire.Enabled=false
					end
				end)
				debris:AddItem(fakehandle,3)
				fakehandle.Parent=game.Workspace
				makefakearms()
				wait(1)
			else
				lastclick=tick()
				print(tick())
				if check then
					check=false
					wait(.2)
					local stretchsound=sp.Handle:FindFirstChild("StretchSound")
					if stretchsound~=nil then
						stretchsound.Pitch=.9+(math.random()*.5)
						stretchsound:Play()
					end
					--local attack=attacks[math.random(1,#attacks)]
					print("check",tick()-lastclick)
					if tick()-lastclick<.19 then
						attack=attacks[1]
					else
						attack=attacks[2]
					end
					local anim=sp:FindFirstChild(attack)
					local chr=sp.Parent
					local mh=chr:FindFirstChild("Humanoid")
					local t=chr:FindFirstChild("Torso")
					if anim and mh and t then
						theanim=mh:LoadAnimation(anim)
						if theanim and mh.Health>0 then
							theanim:Play()
							if attack=="HelicopterSpin" then
								delay(0,function()
									local initialcf=t.CFrame
									local bg=Instance.new("BodyGyro")
									bg.maxTorque=Vector3.new(1,1,1)*10^6
									bg.P=10^4
									bg.D=10^3
									bg.cframe=initialcf
									bg.Parent=t
									rframes=2/.1
									for rframe=1,rframes do
										local rpercent=rframe/rframes
										if bg~=nil then
											bg.cframe=initialcf*CFrame.Angles(0,math.pi*6*rpercent,0)
										end
										wait(.1)
									end
									if bg~=nil then
										bg:remove()
									end
								end)
							end
							damage=smackdamage
							local frames=.5/rate
							for frame=1,frames do
								local percent=frame/frames
								if flarm~=nil and lw~=nil then
									flarm.Size=Vector3.new(1,2+(percent*8),1)
									local m=flarm:FindFirstChild("Mesh")
									if m~=nil then
										m.Scale=Vector3.new(1,1+(percent*4),1)
									end
									lw.C1=CFrame.new(0,(flarm.Size.y-2)/2,0)
									lw.Parent=flarm
								end
								if frarm~=nil and rw~=nil then
									frarm.Size=Vector3.new(1,2+(percent*8),1)
									local m=frarm:FindFirstChild("Mesh")
									if m~=nil then
										m.Scale=Vector3.new(1,1+(percent*4),1)
									end
									rw.C1=CFrame.new(0,(frarm.Size.y-2)/2,0)
									rw.Parent=frarm
								end
								wait(rate)
							end
							damage=smackdamage*.618
							local frames=2/rate
							if attack=="ClawAttack" then
								frames=1/rate
							end
							for frame=1,frames do
								local percent=1-(frame/frames)
								if flarm~=nil and lw~=nil then
									flarm.Size=Vector3.new(1,2+(percent*8),1)
									local m=flarm:FindFirstChild("Mesh")
									if m~=nil then
										m.Scale=Vector3.new(1,1+(percent*4),1)
									end
									lw.C1=CFrame.new(0,(flarm.Size.y-2)/2,0)
									lw.Parent=flarm
								end
								if frarm~=nil and rw~=nil then
									frarm.Size=Vector3.new(1,2+(percent*8),1)
									local m=frarm:FindFirstChild("Mesh")
									if m~=nil then
										m.Scale=Vector3.new(1,1+(percent*4),1)
									end
									rw.C1=CFrame.new(0,(frarm.Size.y-2)/2,0)
									rw.Parent=frarm
								end
								wait(rate)
							end
						end
					end
					damage=0
					check=true
				end
			end
		end)
	end
end

sp.Equipped:connect(Equipped)


