--Made by Stickmasterluke


sp=script.Parent


local debris=game:GetService("Debris")
equipped=false
check=true



sp.Equipped:connect(function(mouse)
	if mouse~=nil then
		equipped=true
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and check and equipped then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				local animobject1=sp:FindFirstChild("ButtonPress")
				local animobject2=sp:FindFirstChild("Toss")
				if t and h and animobject1 and animobject2 and equipped then
					if h.Health>0 then
						check=false
						anim1=h:LoadAnimation(animobject1)
						if anim1 and h and h~=nil and h.Health>0 and equipped then
							anim1:Play()
							wait(1.6)
							sp.Handle.BeepTone:Play()
							wait(.6)
							sp.Handle.BeepTone:Play()
							wait(.5)
						end
						anim2=h:LoadAnimation(animobject2)
						if anim2 and h and h~=nil and h.Health>0 and equipped then
							anim2:Play()
							wait(1.2)
						end
						if equipped then
							local p=sp.Handle:clone()
							p.CanCollide=true
							p.Name="Jump Point"
							p.Anchored=false
							p.Velocity=(t.CFrame.lookVector*20)+Vector3.new(0,20,0)
							local s=sp.Script:clone()
							s.Parent=p
							s.Disabled=false
							local gui=sp.JumpPointGui:clone()
							gui.Parent=p
							local ct=Instance.new("ObjectValue")
							ct.Name="creator"
							ct.Value=game.Players.LocalPlayer
							ct.Parent=p
							local gyro=Instance.new("BodyGyro")		--this will keep the thing standing upright.
							gyro.Parent=p
							p.Parent=game.Workspace
							sp:remove()
						end
						check=true
					end
				end
			end
		end)
	end
end)

sp.Unequipped:connect(function()
	equipped=false
end)

