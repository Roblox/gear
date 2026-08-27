--Made by Stickmasterluke


sp=script.Parent


numberofducks=7


check=true
ducks={}
debris=game:GetService("Debris")

function createduckling(follow)
	local duck=Instance.new("Part")
	duck.Name="Duckling"
	duck.BrickColor=BrickColor.new("Cool yellow")
	local m=Instance.new("SpecialMesh")
	m.MeshId="http://www.roblox.com/asset/?id=104502999"
	m.TextureId="http://www.roblox.com/asset/?id=104503246"
	m.Scale=Vector3.new(1,1,1)*.9
	m.Parent=duck
	duck.Shape="Ball"
	duck.Size=Vector3.new(1,1,1)
	duck.TopSurface="Smooth"
	duck.BottomSurface="Smooth"
	duck.Friction=0
	duck.Elasticity=0
	local rp=sp.Handle.Position+Vector3.new(math.random(-5,5),math.random(-1,5),math.random(-5,5))
	duck.CFrame=CFrame.new(rp)
	local s=sp.DuckScript:clone()
	s.Parent=duck
	s.Disabled=false
	local ft=Instance.new("ObjectValue")
	ft.Name="FollowTag"
	ft.Value=follow
	ft.Parent=duck
	local bp=Instance.new("BodyPosition")
	bp.maxForce=Vector3.new(1,0,1)*10^3
	bp.position=rp
	bp.Parent=duck
	local bg=Instance.new("BodyGyro")
	bg.maxTorque=Vector3.new(5,5,5)*10^3
	bg.Parent=duck
	debris:AddItem(duck,5*60)
	table.insert(ducks,duck)
	duck.Parent=game.Workspace
	return duck
end

function onActivated()
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso") or sp.Parent:FindFirstChild("UpperTorso")
	if check and t and h and h.Health>0 then
		check=false

		for _,v in pairs(ducks) do
			if v~=nil then
				v:remove()
			end
		end
		ducks={}
		lastduck=t
		for i=1,numberofducks do
			lastduck=createduckling(lastduck)
		end

		local sound=sp.Handle:FindFirstChild("Sound")
		if sound~=nil then
			sound:Play()
		end
		wait(2)
		check=true
	end
end

sp.Activated:connect(onActivated)