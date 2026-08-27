--Stickmasterluke


sp=script.Parent


cooldown=2.1
spraysize=5
range=10

baseid="http://www.roblox.com/asset/?id="
sprayid=80373024
local debris=game:GetService("Debris")
equipped=false
check=true

while gui==nil do
	wait()
	gui=sp:FindFirstChild("SprayGui")
end

function updateid()
	if gui:FindFirstChild("Frame") and gui.Frame:FindFirstChild("ImageLabel") and gui.Frame:FindFirstChild("Frame") then
		sprayid=tonumber(tostring(gui.Frame.Frame.TextBox.Text)) or 0
		gui.Frame.ImageLabel.Image=baseid..tostring(sprayid-1)
		gui.Frame.Frame.TextBox.Text=tostring(sprayid)
	end
end

gui.Frame.Frame.TextBox.Changed:connect(updateid)
updateid()

function onEquipped(mouse)
	equipped=true
	local plr=game.Players.LocalPlayer
	if mouse~=nil and plr~=nil then
		local plrgui=plr.PlayerGui
		if plrgui~=nil then
			gui.Parent=plrgui
		end
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and check and mouse.Target~=nil and mouse.TargetSurface~=nil and mouse.Target.Name~="Spray" and mouse.Target.Name~="Effect" and sprayid>0 then
				local surface=mouse.TargetSurface
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				local animobject=sp:FindFirstChild("SprayPaint")
				if t and h and animobject then
					if h.Health>0 then
						check=false
						anim=h:LoadAnimation(animobject)
						if anim then
							anim:Play()
							sp.Handle.Sound:Play()
						end
						if (t.Position-mouse.Hit.p).magnitude<range then
							local canspray=false
							if (surface==Enum.NormalId.Front or surface==Enum.NormalId.Back) and mouse.Target.Size.x>=spraysize and mouse.Target.Size.y>=spraysize then
								canspray=true
							elseif (surface==Enum.NormalId.Left or surface==Enum.NormalId.Right) and mouse.Target.Size.y>=spraysize and mouse.Target.Size.z>=spraysize then
								canspray=true
							elseif (surface==Enum.NormalId.Top or surface==Enum.NormalId.Bottom) and mouse.Target.Size.x>=spraysize and mouse.Target.Size.z>=spraysize then
								canspray=true
							end
							if canspray then
								local p=Instance.new("Part")
								local d=Instance.new("Decal")
								d.Texture=baseid..tostring(sprayid-1)
								d.Face=surface
								d.Parent=p
								p.Name="Spray"
								p.formFactor="Custom"
								p.Anchored=false
								p.CanCollide=false
								p.Transparency=1
								if surface==Enum.NormalId.Front or surface==Enum.NormalId.Back then
									p.Size=Vector3.new(spraysize,spraysize,.2)
								elseif surface==Enum.NormalId.Left or surface==Enum.NormalId.Right then
									p.Size=Vector3.new(.2,spraysize,spraysize)
								elseif surface==Enum.NormalId.Top or surface==Enum.NormalId.Bottom then
									p.Size=Vector3.new(spraysize,.2,spraysize)
								end
								local w=Instance.new("Weld")
								w.Part0=mouse.Target
								w.Part1=p
								local cf=CFrame.new(mouse.Target.CFrame:pointToObjectSpace(mouse.Hit.p))
								w.C0=cf
								w.C1=CFrame.new(0,0,0)
								w.Parent=mouse.Target
								p.CFrame=mouse.Target.CFrame:toWorldSpace(cf)		--this is here to position the spray other wise it will be at 0,0,0 if the target is anchored
								debris:AddItem(p,60)
								p.Parent=game.Workspace
							end
						end
						wait(cooldown)
						sp.Handle.Sound:Stop()
						check=true
					end
				end
			end
		end)
	end
end

function onUnequipped()
	gui.Parent=sp
	equipped=false
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

