--Stickmasterluke


sp=script.Parent


rate=1/30
ringradius=20
cylinderradius=10
monsters=4

local debris=game:GetService("Debris")



function createmonster(pos)
	local monster=game:GetService("InsertService"):LoadAsset(95401558):GetChildren()[1]
	--local monster=game.Lighting.Shade:clone()
	local ct=sp:FindFirstChild("creator")
	if ct~=nil then
		ct:clone().Parent=monster
	end
	debris:AddItem(monster,40)
	monster.Parent=game.Workspace
	monster:MoveTo(pos)
end


while (sp.Velocity).magnitude>.1 do
	wait(.25)
end
sp.Anchored=true
sp.CanCollide=false

p=Instance.new("Part")
p.Name="Effect"
p.Anchored=true
p.CanCollide=false
p.FormFactor="Custom"
p.TopSurface="Smooth"
p.BottomSurface="Smooth"
p.Size=Vector3.new(.2,.2,.2)
p.BrickColor=BrickColor.new("Cool yellow")
p.Transparency=0
oc=CFrame.new(sp.Position)*CFrame.Angles(math.pi/2,0,0)
p.CFrame=oc

m=Instance.new("SpecialMesh")
m.MeshId="http://www.roblox.com/asset/?id=3270017"
m.Scale=Vector3.new(0,0,0)
m.Parent=p

p2=Instance.new("Part")
p2.Name="Effect"
p2.Anchored=true
p2.CanCollide=false
p2.FormFactor="Custom"
p2.TopSurface="Smooth"
p2.BottomSurface="Smooth"
p2.Size=Vector3.new(.2,.2,.2)
p2.BrickColor=BrickColor.new("New Yeller")
p2.Transparency=0
p2.CFrame=CFrame.new(sp.Position)

m2=Instance.new("CylinderMesh")
m2.Scale=Vector3.new(1,200*5,1)
m2.Offset=Vector3.new(0,(200*.5)-5,0)
m2.Parent=p2



sp.ExplodeSound:Play()

Spawn(function()
	debris:AddItem(p,10)
	p.Parent=game.Workspace
	local frames=1/rate
	for frame=1,frames do
		local percent=frame/frames
		m.Scale=Vector3.new(percent*ringradius*2,percent*ringradius*2,2)
		p.Transparency=percent
		wait(rate)
	end
	p:remove()
end)

sp.WindSound:Play()

wait(.5)

Spawn(function()
	debris:AddItem(p2,10)
	p2.Parent=game.Workspace
	local frames=3/rate
	for frame=1,frames do
		local percent=frame/frames
		local radius=(math.sin(math.pi*.5*percent)*cylinderradius*2)+1
		m2.Scale=Vector3.new(radius,200,radius)*5
		p2.Transparency=1-math.cos(math.pi*.5*percent)
		wait(rate)
	end
	p2:remove()
end)

wait(1)

for i=1,monsters do
	createmonster((CFrame.new(sp.Position)*CFrame.Angles(0,math.pi*2*(i/monsters),0)*CFrame.new(5,0,0)).p)
end

wait(4.5)

sp:remove()




