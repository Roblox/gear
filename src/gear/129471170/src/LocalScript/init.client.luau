--Made by Stickmasterluke


sp=script.Parent


firerate=.5
power=42

local debris=game:GetService("Debris")
local handle=sp:WaitForChild("Handle")
equipped=false
check=true

function throwstar(start,vec)
	if start and vec then
		local p=handle:clone()
		p.CanCollide=true
		p.Transparency=0
		local c=Instance.new("ObjectValue")
		c.Name="creator"
		c.Value=game.Players.LocalPlayer
		c.Parent=p
		local bf=Instance.new("BodyForce")
		bf.force=Vector3.new(0,p:GetMass()*196.2,0)
		bf.Parent=p
		local smoke=Instance.new("Smoke")
		smoke.Opacity=.25
		smoke.RiseVelocity=1
		smoke.Size=.1
		smoke.Enabled=false
		smoke.Parent=p
		local s=script.Script:clone()
		s.Parent=p
		s.Disabled=false
		local HitSound=Instance.new("Sound")
		HitSound.SoundId="http://www.roblox.com/asset/?id=11113679"
		HitSound.Parent=arrow
		HitSound.Volume=.5
		HitSound.Parent=p
		p.CFrame=CFrame.new(start)
		p.Velocity=vec*power
		p.RotVelocity=Vector3.new(0,100,0)
		debris:AddItem(p,15)
		p.Parent=game.Workspace
	end
end

function onEquipped(mouse)
	equipped=true
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
				local shoulder=t:FindFirstChild("Right Shoulder")
				if shoulder~=nil then
					shoulder.CurrentAngle=3
				end
				local sound=handle:FindFirstChild("Fire")
				if sound then
					sound:Play()
				end
				local basevec=(mouse.Hit.p-t.Position).unit
				throwstar(t.Position+basevec*5.5,basevec)
				--[[local vec=CFrame.Angles(0,-.3,0)*basevec
				throwstar(t.Position+vec*4,vec)
				local vec=CFrame.Angles(0,.3,0)*basevec
				throwstar(t.Position+vec*4,vec)]]

				handle.Transparency=1
				wait(firerate)
				handle.Transparency=0
				mouse.Icon="rbxasset://textures\\GunCursor.png"
				check=true
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





