--Made by Stickmasterluke


sp=script.Parent


cooldown=4
power=60
rate=1/30

local debris=game:GetService("Debris")
equipped=false
check=true

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		wait()
	end
	return a:FindFirstChild(b)
end
lastuse=waitfor(sp,"LastUse")

function onEquipped(mouse)
	equipped=true
	if mouse~=nil then
		sp.Handle.Transparency=1
		if tick()-cooldown<lastuse.Value then
			mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
			wait(lastuse.Value-(tick()-cooldown))
			mouse.Icon="rbxasset://textures\\GunCursor.png"
		else
			mouse.Icon="rbxasset://textures\\GunCursor.png"
		end
		sp.Handle.Transparency=0
		mouse.Button1Down:connect(function()
			local hu=sp.Parent:FindFirstChild("Humanoid")
			local t=sp.Parent:FindFirstChild("Torso")
			if check and hu and hu.Health>0 and t then
				check=false
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				local sound=sp.Handle:FindFirstChild("ThrowSound")
				if sound~=nil then
					sound:Play()
				end
				local shoulder=t:FindFirstChild("Right Shoulder")
				if shoulder~=nil then
					shoulder.CurrentAngle=math.pi
				end
				local p=sp.Handle:clone()
				p.Name="Effect"
				p.CanCollide=true
				p.Transparency=0

				local vec=(mouse.Hit.p-t.Position).unit
				p.CFrame=CFrame.new(t.Position,t.Position+vec)*CFrame.new(0,0,-5)
				p.Velocity=(vec*power)+Vector3.new(0,20,0)
				p.RotVelocity=((Vector3.new(1,1,1)*math.random())-Vector3.new(.5,.5,.5))*20

				local c=Instance.new("ObjectValue")
				c.Name="creator"
				c.Value=game.Players.LocalPlayer
				c.Parent=p

				local s=script.Script:clone()
				s.Parent=p
				s.Disabled=false
				debris:AddItem(p,10)
				p.Parent=game.Workspace

				sp.Handle.Transparency=1
				lastuse.Value=tick()
				wait(cooldown)
				sp.Handle.Transparency=0
				if mouse~=nil then
					mouse.Icon="rbxasset://textures\\GunCursor.png"
				end
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





