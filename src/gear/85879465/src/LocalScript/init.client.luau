--Made by Stickmasterluke


sp=script.Parent


firerate=.8
power=250
rate=1/30

debris=game:GetService("Debris")
equipped=false
check=true

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		wait()
	end
	return a:FindFirstChild(b)
end

waitfor(script,"Script")
waitfor(script,"Animate2")
waitfor(sp.Handle,"Sound")

function onEquipped(mouse)
	equipped=true
	print("Equipped")
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local hu=sp.Parent:FindFirstChild("Humanoid")
			local t=sp.Parent:FindFirstChild("Torso")
			if check and hu and hu.Health>0 and t then
				check=false
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				local sound=sp.Handle:FindFirstChild("Sound")
				if sound~=nil then
					sound:Play()
				end
				local rshoulder=t:FindFirstChild("Right Shoulder")
				if rshoulder~=nil then
					rshoulder.CurrentAngle=1.5
				end
				local lshoulder=t:FindFirstChild("Left Shoulder")
				if lshoulder~=nil then
					lshoulder.CurrentAngle=-1.5
				end
				local rhip=t:FindFirstChild("Right Hip")
				if rhip~=nil then
					rhip.CurrentAngle=.5
				end
				local lhip=t:FindFirstChild("Left Hip")
				if lhip~=nil then
					lhip.CurrentAngle=-.5
				end
				local p=Instance.new("Part")
				p.Name="Effect"
				p.Shape="Ball"
				p.Elasticity=0
				p.BrickColor=BrickColor.new("Black")--"Dark stone grey")
				p.Material="Concrete"
				p.CanCollide=true
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.formFactor="Custom"
				
				local f=Instance.new("Fire")
				f.Parent=p
				p.Size=Vector3.new(1.5,1.5,1.5)
				local vec=(mouse.Hit.p-t.Position).unit
				p.CFrame=CFrame.new(t.Position,t.Position+vec)*CFrame.new(0,0,-5)
				p.Velocity=(vec*power)+Vector3.new(0,20,0)
				t.CFrame=CFrame.new(t.Position-vec,t.Position)
				local c=Instance.new("ObjectValue")
				c.Name="creator"
				c.Value=game.Players.LocalPlayer
				c.Parent=p
				local s=script.Script:clone()
				s.Parent=p
				s.Disabled=false
				debris:AddItem(p,7)
				p.Parent=game.Workspace
				wait(firerate)
				mouse.Icon="rbxasset://textures\\GunCursor.png"
				check=true
			end
		end)
	end
	local animate=sp.Parent:FindFirstChild("Animate")
	if animate~=nil then
		animateclone=animate:clone()
		animateparent=sp.Parent
		animate:remove()
	end
	if sp.Parent:FindFirstChild("Animate2")==nil then
		newanimate=script.Animate2:clone()
		newanimate.Parent=sp.Parent
		newanimate.Disabled=false
	end
	wait(.1)
	local t=sp.Parent:FindFirstChild("Torso")
	local ra=sp.Parent:FindFirstChild("Right Arm")
	if t~=nil and ra~=nil then
		local rg=ra:FindFirstChild("RightGrip")
		if rg~=nil then
			rg.Part0=t
		end
	end
end

function onUnequipped()
	equipped=false
	if animateclone then
		animateclone.Parent=animateparent
	end
	if animateparent and animateparent~=nil then
		for i,v in ipairs(animateparent:GetChildren()) do
			if v.Name=="Animate2" then
				v:remove()
			end
		end
	end
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)





