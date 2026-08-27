--Stickmasterluke


sp=script.Parent


local debris=game:GetService("Debris")

function onEquipped(mouse)
	if mouse~=nil then 
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and sp.Enabled then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				local animobject1=sp:FindFirstChild("ButtonPress")
				local animobject2=sp:FindFirstChild("Toss")
				if t and h and animobject1 and animobject2 then
					if h.Health>0 then
						sp.Enabled=false
						anim1=h:LoadAnimation(animobject1)
						if anim1 and h and h~=nil and h.Health>0 then
							anim1:Play()
							wait(1.6)
							sp.Handle.BeepTone:Play()
							wait(.6)
							sp.Handle.BeepTone:Play()
							wait(.5)
						end
						anim2=h:LoadAnimation(animobject2)
						if anim2 and h and h~=nil and h.Health>0 then
							anim2:Play()
							wait(1.2)
						end
						p=sp.Handle:clone()
						p.CanCollide=true
						p.Name="Medpack"
						p.Anchored=false
						p.Velocity=(t.CFrame.lookVector*20)+Vector3.new(0,20,0)
						local s=sp.Script:clone()
						s.Parent=p
						s.Disabled=false
						debris:AddItem(p,60)
						p.Parent=game.Workspace
						sp:remove()
					end
				end
			end
		end)
	end
end


sp.Equipped:connect(onEquipped)

