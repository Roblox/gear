--Made by Stickmasterluke


sp=script.Parent


local cooldown=.2
local scale=.5

local check=true
local debris=game:GetService("Debris")
local handle=sp:WaitForChild("Handle")
handle.Transparency=0

local handle2=sp:FindFirstChild("Handle2")
if handle2 then
	handle2:remove()
end

function findsquirrel()
	for _,v in pairs(game.Workspace:GetChildren()) do
		if v.Name=="Chupbacabra" then
			local creatortag=v:FindFirstChild("creator")
			if creatortag and creatortag.Value==game.Players.LocalPlayer then
				sp.Handle.Transparency=1
				return v
			end
		end
	end
end

function onEquipped(mouse)
	equipped=true
	local plr=game.Players.LocalPlayer
	if mouse~=nil and plr~=nil then
		handle.Transparency=0
		findsquirrel()
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and check then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				if t and h and h.Health>0 then
					check=false
					mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
					local squirrel=findsquirrel()
					if squirrel==nil then
						local m=Instance.new("Model")
						m.Name="Chupbacabra"
						local p=sp.Handle:clone()
						p.Friction=.2
						p.Name="Torso"
						p.Transparency=0
						p.CanCollide=true
						p.CFrame=CFrame.new()
						p.Size=Vector3.new(1.4,2.45,3.2)
						local rd=Vector3.new((math.random()-.5)*15,(math.random()-.5)*5,(math.random()-.5)*15)
						p.Position=sp.Handle.Position+rd
						p.Velocity=rd
						p.Mesh.MeshId="http://www.roblox.com/asset/?id=126623476"
						p.Mesh.Scale=Vector3.new(1,1,1)*scale
						p.Parent=m
						local he=Instance.new("Part")
						he.Name="Head"
						he.formFactor="Custom"
						he.Transparency=1
						he.Size=Vector3.new(0,0,0)
						he.Parent=m
						local w=Instance.new("Weld")
						w.Name="Neck"
						w.Part0=p
						w.Part1=he
						w.Parent=p
						local h=Instance.new("Humanoid")
						h.MaxHealth=100
						h.Health=100
						h.WalkSpeed=18
						h.Parent=m
						
						local leftarm=Instance.new("Part")
						leftarm.Name="Left Arm"
						leftarm.CanCollide=false
						leftarm.Locked=true
						leftarm.formFactor="Custom"
						leftarm.TopSurface="Smooth"
						leftarm.BottomSurface="Smooth"
						leftarm.BrickColor=BrickColor.new("Grime")
						leftarm.Size=Vector3.new(.4,1.4,1.2)
						local law=Instance.new("Motor")
						law.Name="LeftShoulder"
						law.MaxVelocity=.2
						law.Part0=p
						law.Part1=leftarm
						law.C0=CFrame.new(-.5,0,0)*CFrame.Angles(0,math.pi*.5,0)
						law.C1=CFrame.Angles(0,math.pi*.5,0)*CFrame.new(-.3,.6,0)
						law.Parent=p
						local mesh=Instance.new("SpecialMesh")
						mesh.MeshId="http://www.roblox.com/asset/?id=126634493"--126626289"--126623615"
						mesh.TextureId="http://www.roblox.com/asset/?id=126623259"
						mesh.Scale=Vector3.new(1,1,1)*scale
						mesh.Parent=leftarm
						leftarm.Parent=m
						
						local rightarm=Instance.new("Part")
						rightarm.Name="Right Arm"
						rightarm.CanCollide=false
						rightarm.Locked=true
						rightarm.formFactor="Custom"
						rightarm.TopSurface="Smooth"
						rightarm.BottomSurface="Smooth"
						rightarm.BrickColor=BrickColor.new("Grime")
						rightarm.Size=Vector3.new(.4,1.4,1.2)
						local raw=Instance.new("Motor")
						raw.Name="RightShoulder"
						raw.MaxVelocity=.2
						raw.Part0=p
						raw.Part1=rightarm
						raw.C0=CFrame.new(.5,0,0)*CFrame.Angles(0,math.pi*.5,0)
						raw.C1=CFrame.Angles(0,math.pi*.5,0)*CFrame.new(-.3,.6,0)
						raw.Parent=p
						local mesh=Instance.new("SpecialMesh")
						mesh.MeshId="http://www.roblox.com/asset/?id=126634699"--126626353"--126623701"
						mesh.TextureId="http://www.roblox.com/asset/?id=126623259"
						mesh.Scale=Vector3.new(1,1,1)*scale
						mesh.Parent=rightarm
						rightarm.Parent=m
						
						local leftleg=Instance.new("Part")
						leftleg.Name="Left Leg"
						leftleg.CanCollide=false
						leftleg.Locked=true
						leftleg.formFactor="Custom"
						leftleg.TopSurface="Smooth"
						leftleg.BottomSurface="Smooth"
						leftleg.BrickColor=BrickColor.new("Grime")
						leftleg.Size=Vector3.new(.6,1.7,.9)
						local llw=Instance.new("Motor")
						llw.Name="LeftHip"
						llw.MaxVelocity=.2
						llw.Part0=p
						llw.Part1=leftleg
						llw.C0=CFrame.new(-.3,-.9,.5)*CFrame.Angles(0,math.pi*.5,0)
						llw.C1=CFrame.Angles(0,math.pi*.5,0)*CFrame.new(-.5,.9,0)*CFrame.Angles(0,0,.3)
						llw.Parent=p
						local mesh=Instance.new("SpecialMesh")
						mesh.MeshId="http://www.roblox.com/asset/?id=126634876"--126632542"--126626892"--126623773"
						mesh.TextureId="http://www.roblox.com/asset/?id=126623259"
						mesh.Scale=Vector3.new(1,1,1)*scale
						mesh.Parent=leftleg
						leftleg.Parent=m
						
						local rightleg=Instance.new("Part")
						rightleg.Name="Right Leg"
						rightleg.CanCollide=false
						rightleg.Locked=true
						rightleg.formFactor="Custom"
						rightleg.TopSurface="Smooth"
						rightleg.BottomSurface="Smooth"
						rightleg.BrickColor=BrickColor.new("Grime")
						rightleg.Size=Vector3.new(.6,1.7,.9)
						local rlw=Instance.new("Motor")
						rlw.Name="RightHip"
						rlw.MaxVelocity=.2
						rlw.Part0=p
						rlw.Part1=rightleg
						rlw.C0=CFrame.new(.3,-.9,.5)*CFrame.Angles(0,math.pi*.5,0)
						rlw.C1=CFrame.Angles(0,math.pi*.5,0)*CFrame.new(-.5,.9,0)*CFrame.Angles(0,0,.3)
						rlw.Parent=p
						local mesh=Instance.new("SpecialMesh")
						mesh.MeshId="http://www.roblox.com/asset/?id=126634777"--126632155"--126627016"--126623832"
						mesh.TextureId="http://www.roblox.com/asset/?id=126623259"
						mesh.Scale=Vector3.new(1,1,1)*scale
						mesh.Parent=rightleg
						rightleg.Parent=m
						
						local orders=Instance.new("StringValue")
						orders.Name="Orders"
						orders.Value="Follow"
						orders.Parent=m
						local target=Instance.new("ObjectValue")
						target.Name="Target"
						target.Parent=m
						local targetpos=Instance.new("Vector3Value")
						targetpos.Name="TargetPos"
						targetpos.Parent=m
						local ct=Instance.new("ObjectValue")
						ct.Value=game.Players.LocalPlayer
						ct.Name="creator"
						ct.Parent=m
						local s=script.Script:clone()
						s.Parent=m
						s.Disabled=false
						debris:AddItem(m,5*60)
						m.Parent=game.Workspace
						p.Position=sp.Handle.Position+rd
						sp.Handle.Transparency=1
						
					elseif mouse.Target~=nil then
						local th=mouse.Target.Parent:FindFirstChild("Humanoid") or mouse.Target.Parent.Parent:FindFirstChild("Humanoid")
						if th and th.Parent:FindFirstChild("Torso") then
							squirrel.Target.Value=th.Parent
							squirrel.Orders.Value="Attack"
						else
							squirrel.Target.Value=mouse.Target
							squirrel.TargetPos.Value=mouse.Hit.p
							squirrel.Orders.Value="MoveTo"
						end
					end
					wait(cooldown)
					mouse.Icon="rbxasset://textures\\GunCursor.png"
					check=true
				end
			end
		end)
	end
end

function onUnequipped()
	equipped=false
	handle.Transparency=0
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)
handle.Transparency=0

