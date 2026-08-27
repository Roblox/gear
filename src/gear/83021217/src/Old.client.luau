--Made by Stickmasterluke


sp=script.Parent


firerate=3
power=150
rate=1/30
damage=55

debris=game:GetService("Debris")
equipped=false
check=true

sharkids={82821384,82843647,82821384,82843712}

function onEquipped(mouse)
	equipped=true
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local hu=sp.Parent:FindFirstChild("Humanoid")
			if check and hu and hu.Health>0 then
				check=false
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				sp.Handle.Sound:Play()
				local cdamage=0
				local p=Instance.new("Part")
				p.Name="Shark"
				p.BrickColor=BrickColor.new("White")
				p.CanCollide=false
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.formFactor="Custom"
				local m=Instance.new("SpecialMesh")
				m.MeshId="http://www.roblox.com/asset/?id="..tostring(sharkids[1])
				m.TextureId="http://www.roblox.com/asset/?id=82844051"
				m.Scale=Vector3.new(2.5,2.5,2.5)
				m.Parent=p
				p.Size=Vector3.new(.5,1.1,3.5)
				local vec=(mouse.Hit.p-sp.Handle.Position).unit
				p.CFrame=CFrame.new(sp.Handle.Position,sp.Handle.Position+vec)*CFrame.new(0,0,2)
				p.Velocity=(vec*power)+Vector3.new(0,20,0)
				p.Touched:connect(function(hit)
					if hit and hit~=nil and p~=nil and p:FindFirstChild("Bite")==nil then
						if hit.Parent~=sp.Parent and hit.Name~="Handle" and hit.Name~="Effect" and hit.Name~="Shark" then
							local h=hit.Parent:FindFirstChild("Humanoid")
							local t=hit.Parent:FindFirstChild("Torso")
							if h~=nil and t~=nil and h.Health>0 then
								local w=Instance.new("Weld")
								w.Part0=hit
								w.Part1=p
								w.Name="Bite"
								w.C0=CFrame.new(0,0,0)*CFrame.Angles(math.pi*2*math.random(),math.pi*2*math.random(),math.pi*2*math.random())
								w.C1=CFrame.new(0,0,-1.5)*CFrame.Angles(0,0,0)
								w.Parent=p
								for i,v in ipairs(h:GetChildren()) do
									if v.Name=="creator" then
										v:remove()
									end
								end
								local c=Instance.new("ObjectValue")
								c.Name="creator"
								c.Value=game.Players.LocalPlayer
								debris:AddItem(c,15)
								c.Parent=h
								h:TakeDamage(20)
								cdamage=20
								p.Parent=hit.Parent
							else
								p:remove()
							end
						end
					end
				end)
				debris:AddItem(p,15)
				p.Parent=game.Workspace
				delay(0,function()
					local tail=0
					while p~=nil and p.Parent~=nil and p:IsDescendantOf(game.Workspace) and m~=nil and m.Parent~=nil do
						tail=tail+1
						m.MeshId="http://www.roblox.com/asset/?id="..tostring(sharkids[(tail%(#sharkids))+1])
						local bite=p:FindFirstChild("Bite")
						if bite and tail%4==1 then
							if bite.Part0~=nil then
								local h=bite.Part0.Parent:FindFirstChild("Humanoid")
								if h~=nil then
									h:TakeDamage(2)
									cdamage=cdamage+2
								end
							end
						end
						wait(.1)
						if cdamage>damage then
							p:remove()
						end
					end
				end)
				wait(firerate)
				mouse.Icon="rbxasset://textures\\GunCursor.png"
				check=true
			end
		end)
	end
end

function onUnequipped()
	equipped=false
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)





