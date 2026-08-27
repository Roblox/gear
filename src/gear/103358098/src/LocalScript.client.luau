--Made by Stickmasterluke ;D


sp=script.Parent

theface="http://www.roblox.com/asset?id=103838612"
health=80
textureclosed="http://www.roblox.com/asset?id=103920391"
textureopen="http://www.roblox.com/asset?id=103920471"


storedface=""
local debris=game:GetService("Debris")
check=true

sp.Equipped:connect(function(mouse)
	equipped=true
	if mouse~=nil then 
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and check then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				local anim=sp:FindFirstChild("Eat")
				if anim and t and h and h.Health>0 and equipped and check then
					mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
					check=false
					anim2=h:LoadAnimation(anim)
					anim2:Play()
					local handle=sp:FindFirstChild("Handle")
					if handle~=nil then
						local mesh=handle:FindFirstChild("Mesh")
						if mesh~=nil then
							mesh.TextureId=textureopen
						end
					end
					wait(2)
					local s=sp.Handle:FindFirstChild("Sound")
					if s~=nil and equipped and w~=nil then
						w.C0=CFrame.new(0,-1,-.3)*CFrame.Angles(-.3,0,math.pi/4)
						s:Play()
					else
						check=true
						return
					end
					wait(2)
					if h~=nil and h.Health>0 and equipped and w~=nil then
						h:TakeDamage(-math.min(health*.5,h.MaxHealth-h.Health))
						head=nil
						face=nil
						local head=h.Parent:FindFirstChild("Head")
						if head~=nil then
							face=head:FindFirstChild("face")
							if face~=nil then
								storedface=face.Texture
								face.Texture=theface
							end
						end
						w.C0=CFrame.new(0,-1,-.3)*CFrame.Angles(.3,0,math.pi/4)
					else
						check=true
						return
					end
					wait(2)
					local s=sp.Handle:FindFirstChild("Sound")
					if s~=nil and equipped and w~=nil then
						w.C0=CFrame.new(0,-1,-.3)*CFrame.Angles(-.3,0,math.pi/4)
						s:Play()
					else
						check=true
						return
					end
					wait(2)
					if h~=nil and h.Health>0 and equipped and w~=nil then
						h:TakeDamage(-math.min(health*.5,h.MaxHealth-h.Health))
						w.C0=CFrame.new(0,-1,-.3)*CFrame.Angles(0,0,math.pi/4)
					end
					wait(3)
					if mouse~=nil then
						mouse.Icon="rbxasset://textures\\GunCursor.png"
					end
					if face~=nil then
						face.Texture=storedface
					end
					local handle=sp:FindFirstChild("Handle")
					if handle~=nil then
						local mesh=handle:FindFirstChild("Mesh")
						if mesh~=nil then
							mesh.TextureId=textureclosed
						end
					end
					check=true
				end
			end
		end)
	end
	delay(0,function()
		local la=sp.Parent:FindFirstChild("Left Arm")
		if la~=nil then
			if spoon then
				spoon:remove()
			end
			spoon=Instance.new("Part")
			spoon.FormFactor="Custom"
			spoon.Name="Handle"
			spoon.Size=Vector3.new(.2,.2,1.3)
			spoon.TopSurface="Smooth"
			spoon.BottomSurface="Smooth"
			spoon.CanCollide=false
			local m=Instance.new("SpecialMesh")
			m.MeshId="http://www.roblox.com/asset?id=103919885"
			m.TextureId=textureopen
			m.Parent=spoon
			w=Instance.new("Motor")
			w.Part0=la
			w.Part1=spoon
			w.C0=CFrame.new(0,-1,-.3)*CFrame.Angles(0,0,math.pi/4)
			w.Parent=spoon
			debris:AddItem(spoon,600)
			spoon.Parent=game.Workspace
		end
	end)
end)

sp.Unequipped:connect(function()
	equipped=false
	if anim2 then
		anim2:Stop()
	end
	if face~=nil then
		face.Texture=storedface
	end
	local handle=sp:FindFirstChild("Handle")
	if handle~=nil then
		local mesh=handle:FindFirstChild("Mesh")
		if mesh~=nil then
			mesh.TextureId=textureclosed
		end
	end
	if spoon then
		spoon:remove()
	end
end)

