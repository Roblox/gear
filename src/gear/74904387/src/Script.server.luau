--Stickmasterluke


sp=script.Parent


local debris=game:GetService("Debris")
check=true

prizes={41457719,17407931,61916132,38861951}

sp.Touched:connect(function(hit)
	if hit and hit.Parent~=nil and check then
		local h=hit.Parent:FindFirstChild("Humanoid")
		if h~=nil then
			check=false
			game:GetService("InsertService"):LoadAsset(prizes[math.random(1,#prizes)]):GetChildren()[1].Parent=hit.Parent
			--h.Health=h.MaxHealth
			sp.CoinSound:Play()
			for i=1,7 do
				local p=Instance.new("Part")
				p.CanCollide=false
				p.BrickColor=BrickColor.new(23)
				p.formFactor="Custom"
				p.Size=Vector3.new(1,.2,1)
				p.TopSurface=0
				p.BottomSurface=0
				local a=math.random()*6.28 
				local d=Vector3.new(math.cos(a),2+(math.random()*3),math.sin(a)).unit
				p.Velocity=d*25
				p.RotVelocity=d
				p.CFrame=sp.CFrame+Vector3.new(d.x,d.y+2,d.z)
				local m=Instance.new("SpecialMesh")
				m.MeshId="http://www.roblox.com/asset/?id=19059116"
				m.TextureId="http://www.roblox.com/asset/?id=19059111"
				m.Parent=p
				debris:AddItem(p,2+(math.random()*3))
				p.Parent=game.Workspace
			end
			wait(5)
			sp:remove()
		end
	end
end)


