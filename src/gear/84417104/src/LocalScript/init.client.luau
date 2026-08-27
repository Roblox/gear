--Made by Stickmasterluke


sp=script.Parent


firerate=1
power=150
rate=1/30

debris=game:GetService("Debris")
equipped=false
check=true

meshids={
	{16150760,16150753},	--Head
	{27120789,16150753},	--Torso
	{27120452,47846054},	--Left Arm
	{27120597,47846054},	--Right Arm
	{27120565,47846077},	--Left Leg
	{27120624,47846077},	--Right Leg
}

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
					shoulder.CurrentAngle=2
				end
				local p=Instance.new("Part")
				p.Name="Effect"
				p.BrickColor=BrickColor.new("White")
				p.CanCollide=true
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.formFactor="Custom"
				local selectedmesh=meshids[math.random(1,#meshids)]
				local m=Instance.new("SpecialMesh")
				m.MeshId="http://www.roblox.com/asset/?id="..tostring(selectedmesh[1])
				m.TextureId="http://www.roblox.com/asset/?id="..tostring(selectedmesh[2])
				m.Scale=Vector3.new(1,1,1)
				m.Parent=p
				local f=Instance.new("Fire")
				f.Parent=p
				p.Size=Vector3.new(1,2,1)
				local vec=(mouse.Hit.p-t.Position).unit
				p.CFrame=CFrame.new(t.Position,t.Position+vec)*CFrame.new(0,0,-5)
				p.Velocity=(vec*power)+Vector3.new(0,20,0)
				local c=Instance.new("ObjectValue")
				c.Name="creator"
				c.Value=game.Players.LocalPlayer
				c.Parent=p
				local s=script.Script:clone()
				s.Parent=p
				s.Disabled=false
				debris:AddItem(p,15)
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
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)





