--Made by Stickmasterluke


sp=script.Parent


cooldown=2
longestholdtime=12
spawndistance=61.8
spawnheight=15


check=true
down=false
equipped=false
debris=game:GetService("Debris")


function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

local effectpart=waitfor(sp.Handle,"EffectPart")
local waveanimation=waitfor(sp,"WaveAnim")


function onEquipped(mouse)
	if mouse~=nil then
		equipped=true
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			if mouse~=nil and check then
				check=false
				down=true
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				local h=sp.Parent:FindFirstChild("Humanoid")
				local t=sp.Parent:FindFirstChild("Torso")
				if h~=nil and h.Health>0 and t~=nil then
					waveAnim=h:LoadAnimation(waveanimation)
					if waveAnim then
						waveAnim:Play(nil,nil,.3)
					end
					local spawnlocation=mouse.Hit.p
					if (spawnlocation-t.Position).magnitude>spawndistance then
						spawnlocation=t.Position+(mouse.Hit.p-t.Position).unit*spawndistance
					end
					spawnlocation=spawnlocation+Vector3.new(0,spawnheight,0)
					local p=Instance.new("Part")
					p.Name="Boulder"
					p.BrickColor=BrickColor.new("Brown")
					p.TopSurface="Smooth"
					p.BottomSurface="Smooth"
					p.Anchored=false
					p.CanCollide=true
					p.Locked=true
					p.Shape="Ball"
					p.Size=Vector3.new(4,4,4)
					p.Elasticity=0
					p.Friction=1
					p.CFrame=CFrame.new(spawnlocation)

					local p2=Instance.new("Part")		--this part makes sure it stays lumpy and doesn't roll like a ball.
					p2.Name="Boulder"
					p2.FormFactor="Custom"
					p2.Size=Vector3.new(3,3,3)
					p2.BrickColor=p.BrickColor
					p2.Transparency=1
					p2.TopSurface="Smooth"
					p2.BottomSurface="Smooth"
					p2.CanCollide=true
					p2.Anchored=false
					p2.Locked=true
					p2.Elasticity=0
					p2.Friction=1
					local w=Instance.new("Weld")
					w.Part0=p
					w.Part1=p2
					w.C0=CFrame.Angles(math.random()*math.pi*2,math.random()*math.pi*2,math.random()*math.pi*2)
					w.Parent=p2
					debris:AddItem(p2,30)
					p2.Parent=p

					local m=Instance.new("SpecialMesh")
					m.MeshId="http://www.roblox.com/asset/?id=1290033"
					m.TextureId="http://www.roblox.com/asset/?id=102542003"
					m.Scale=Vector3.new(1,1,1)*2.4
					m.VertexColor=Vector3.new(1,1,1)*1.5
					m.Parent=p

					local sound1=Instance.new("Sound")
					sound1.Name="RockSound"
					sound1.SoundId="http://www.roblox.com/asset/?id=102544922"
					sound1.Volume=1
					sound1.Looped=false
					sound1.PlayOnRemove=false
					sound1.Parent=p

					local sound2=Instance.new("Sound")
					sound2.Name="DirtSound"
					sound2.SoundId="http://www.roblox.com/asset/?id=102546080"
					sound2.Volume=.7
					sound2.Looped=true
					sound2.PlayOnRemove=false
					sound2.Parent=p

					local bp=Instance.new("BodyPosition")
					bp.maxForce=Vector3.new(1,1,1)*10^6
					bp.position=spawnlocation
					bp.Parent=p

					local bav=Instance.new("BodyAngularVelocity")
					bav.maxTorque=Vector3.new(1,1,1)*10^6
					bav.angularvelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*3
					bav.Parent=p

					local ct=Instance.new("ObjectValue")
					ct.Name="creator"
					ct.Value=game.Players.LocalPlayer
					ct.Parent=p

					local dt=Instance.new("IntValue")
					dt.Name="DamageTag"
					dt.Value=12
					dt.Parent=p

					debris:AddItem(p,20)
					p.Parent=game.Workspace
					attachmentparts={}
					for i=1,5 do	--this was supposed to make it look like the rock was gaining mass, but turned out looking like some basic dust effect. :(
						local ap=Instance.new("Part")
						ap.Name="Effect"
						ap.FormFactor="Custom"
						ap.Size=Vector3.new(0,0,0)
						ap.Transparency=1
						ap.TopSurface="Smooth"
						ap.BottomSurface="Smooth"
						ap.CanCollide=false
						ap.Anchored=false
						ap.Locked=true
						local smoke=Instance.new("Smoke")
						smoke.Opacity=.1
						smoke.Color=p.BrickColor.Color
						smoke.RiseVelocity=2.5
						smoke.Size=.1
						smoke.Parent=ap
						local w=Instance.new("Weld")
						w.Part0=p
						w.Part1=ap
						w.C0=CFrame.Angles(math.random()*math.pi*2,math.random()*math.pi*2,math.random()*math.pi*2)*CFrame.new(0,-15,0)
						w.Parent=ap
						table.insert(attachmentparts,ap)
						debris:AddItem(ap,20)
						ap.Parent=p
					end
					starttime=tick()
					delay(.25,function()
						if sound2~=nil then
							sound2:Play()
						end
					end)
					while down and equipped and tick()-starttime<longestholdtime do
						local percent=(tick()-starttime)/longestholdtime
						if bav~=nil then
							bav.angularvelocity=bav.angularvelocity+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*.5)
						end
						local h=sp.Parent:FindFirstChild("Humanoid")
						local t=sp.Parent:FindFirstChild("Torso")
						if mouse~=nil and h~=nil and h.Health>0 and t~=nil then
							if bp~=nil then
								local spawnlocation=mouse.Hit.p
								if (spawnlocation-t.Position).magnitude>spawndistance then
									spawnlocation=t.Position+(mouse.Hit.p-t.Position).unit*spawndistance
								end
								spawnlocation=spawnlocation+Vector3.new(0,spawnheight,0)+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*percent*5)
								bp.position=spawnlocation
							end
						else
							break
						end
						wait(.06)
					end

					if bp~=nil then
						bp:remove()
					end
					if bav~=nil then
						bav:remove()
					end
					local percent=(tick()-starttime)/longestholdtime
					if p~=nil then
						p.Velocity=Vector3.new(0,-100*percent,0)
						local s=script.Script:clone()
						s.Parent=p
						s.Disabled=false
						debris:AddItem(p,6)
					end
					if dt~=nil then
						dt.Value=12+56*percent
					end
					if waveAnim then
						waveAnim:Stop()
					end
					wait(1)
					if attachmentparts then
						for _,v in pairs(attachmentparts) do
							debris:AddItem(v,3)
							local smoke=v:FindFirstChild("Smoke")
							if smoke~=nil then
								smoke.Enabled=false
							end
						end
					end
					wait(cooldown)
					if mouse~=nil then
						mouse.Icon="rbxasset://textures\\GunCursor.png"
					end
				end
				check=true
			end
		end)
		mouse.Button1Up:connect(function()
			down=false
		end)
	end
end

function onUnequipped()
	equipped=false
	if waveAnim then
		waveAnim:Stop()
	end
end

sp.Unequipped:connect(onUnequipped)
sp.Equipped:connect(onEquipped)
