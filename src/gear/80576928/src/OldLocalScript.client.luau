--Made by Stickmasterluke


sp=script.Parent


firerate=3
power=150
rate=1/30

baseid="http://www.roblox.com/asset/?id="
debris=game:GetService("Debris")
equipped=false
check=true
shirtid=79219345
while sp:FindFirstChild("ShirtGui")==nil do
	wait()
end
gui=sp:FindFirstChild("ShirtGui")

function updateid()
	if gui:FindFirstChild("Frame") and gui.Frame:FindFirstChild("ImageLabel") and gui.Frame:FindFirstChild("Frame") then
		shirtid=tonumber(tostring(gui.Frame.Frame.TextBox.Text)) or 0
		gui.Frame.ImageLabel.Image=baseid..tostring(shirtid-1)
		gui.Frame.Frame.TextBox.Text=tostring(shirtid)
	end
end

gui.Frame.Frame.TextBox.Changed:connect(updateid)
updateid()

function onEquipped(mouse)
	equipped=true
	local plr=game.Players.LocalPlayer
	if plr~=nil then
		local plrgui=plr:FindFirstChild("PlayerGui")
		if plrgui~=nil then
			gui.Parent=plrgui
		end
	end
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local hu=sp.Parent:FindFirstChild("Humanoid")
			if check and hu and hu.Health>0 then
				check=false
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				sp.Handle.Sound:Play()
				local p=Instance.new("Part")
				p.Name="Effect"
				p.BrickColor=BrickColor.new("White")
				p.CanCollide=false
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.formFactor="Symmetric"
				local m=Instance.new("SpecialMesh")
				m.MeshId="http://www.roblox.com/asset/?id=80179115"
				m.TextureId="http://www.roblox.com/asset/?id=80172875"
				m.Parent=p
				p.Size=Vector3.new(2,2,3)
				local vec=(mouse.Hit.p-sp.Handle.Position).unit
				p.CFrame=CFrame.new(sp.Handle.Position,sp.Handle.Position+vec)*CFrame.new(0,0,2)
				p.Velocity=(vec*power)+Vector3.new(0,20,0)
				p.Touched:connect(function(hit)
					if hit and hit~=nil then
						if hit.Parent~=sp.Parent and hit.Name~="Handle" and hit.Name~="Effect" then
							local h=hit.Parent:FindFirstChild("Humanoid")
							if h~=nil then
								for i,v in ipairs(hit.Parent:GetChildren()) do
									if v.className=="Shirt" then
										v:remove()
									end
								end
								local shirt=Instance.new("Shirt")
								shirt.ShirtTemplate=baseid..tostring(shirtid-1)
								shirt.Parent=hit.Parent
							end
							p:remove()
						end
					end
				end)
				debris:AddItem(p,10)
				p.Parent=game.Workspace
				wait(firerate)
				mouse.Icon="rbxasset://textures\\GunCursor.png"
				check=true
			end
		end)
	end
end

function onUnequipped()
	equipped=false
	gui.Parent=sp
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)





