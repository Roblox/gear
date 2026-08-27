--Stickmasterluke


sp=script.Parent


local debris=game:GetService("Debris")
equipped=false
check=true

function onEquipped(mouse)
	if mouse~=nil then 
		equipped=true
		if mouse~=nil then
			if check then
				mouse.Icon="rbxasset://textures\\ArrowCursor.png"
			else
				mouse.Icon="rbxasset://textures\\ArrowFarCursor.png"
			end
		end
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and check then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				local animobject1=sp:FindFirstChild("ButtonPress")
				local animobject2=sp:FindFirstChild("Toss")
				if t and h and animobject1 and animobject2 then
					if h.Health>0 and equipped and check then
						check=false
						if mouse~=nil then
							mouse.Icon="rbxasset://textures\\ArrowFarCursor.png"
						end
						anim1=h:LoadAnimation(animobject1)
						if anim1 and h and h~=nil and h.Health>0 then
							anim1:Play()
							wait(1.6)
							if equipped then
								sp.Handle.BeepTone:Play()
								wait(.6)
								if equipped then
									sp.Handle.BeepTone:Play()
									wait(.5)
								end
							end
						end
						if equipped then
							anim2=h:LoadAnimation(animobject2)
							if anim2 and h and h~=nil and h.Health>0 then
								anim2:Play()
								wait(1.2)
							end
							if equipped then	
								p=sp.Handle:clone()
								p.CanCollide=true
								p.Transparency=0
								p.Name="Timebomb"
								p.Anchored=false
								p.Velocity=p.Velocity+(t.CFrame.lookVector*20)+Vector3.new(0,20,0)
								local tag=Instance.new("ObjectValue")
								tag.Name="creator"
								tag.Value=game.Players.LocalPlayer
								tag.Parent=p
								local s=sp.Script:clone()
								s.Parent=p
								s.Disabled=false
								debris:AddItem(p,20)
								p.Parent=game.Workspace
								sp.Handle.Transparency=1
							end
						end
						wait(7)
						sp.Handle.Transparency=0
						if mouse~=nil then
							mouse.Icon="rbxasset://textures\\ArrowCursor.png"
						end
						check=true
					end
				end
			end
		end)
	end
end

function onUnequipped()
	equipped=false
end


sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

