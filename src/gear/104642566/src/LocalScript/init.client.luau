--Made by Stickmasterluke


sp=script.Parent


firerate=22
power=50
rate=1/30

debris=game:GetService("Debris")
equipped=false
check=true


function onEquipped(mouse)
	equipped=true
	if mouse~=nil then
		if check then
			mouse.Icon="rbxasset://textures\\GunCursor.png"
			sp.Handle.Transparency=0
		else
			mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
			sp.Handle.Transparency=1
		end
		mouse.Button1Down:connect(function()
			local hu=sp.Parent:FindFirstChild("Humanoid")
			local t=sp.Parent:FindFirstChild("Torso")
			if check and hu and hu.Health>0 and t then
				check=false
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				sp.Handle.Transparency=1
				local sound=sp.Handle:FindFirstChild("Throw")
				if sound~=nil then
					sound:Play()
				end
				local shoulder=t:FindFirstChild("Right Shoulder")
				if shoulder~=nil then
					shoulder.CurrentAngle=2
				end
				local p=sp.Handle:clone()
				p.CanCollide=true
				p.Transparency=0
				local vec=(mouse.Hit.p-t.Position).unit
				p.CFrame=CFrame.new(t.Position,t.Position+vec)*CFrame.new(0,0,-5)
				p.Velocity=(vec*power)+Vector3.new(0,20,0)
				local s=script.Script:clone()
				s.Parent=p
				s.Disabled=false
				local ct=Instance.new("ObjectValue")
				ct.Name="creator"
				ct.Value=game.Players.LocalPlayer
				ct.Parent=p
				debris:AddItem(p,firerate+10)
				p.Parent=game.Workspace
				wait(firerate)
				sp.Handle.Transparency=0
				mouse.Icon="rbxasset://textures\\GunCursor.png"
				check=true
			end
		end)
	end
end

function onUnequipped()
	equipped=false
	sp.Handle.Transparency=0
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)





