--Stickmasterluke


sp=script.Parent

wait(2.5)

shrapnelvelocity=100
shrapnelcount=math.random(12,14)

meshes={{36869983,36869975},{36780113,36780292},{36780032,36780292},{36780156,36780292},{36780079,36780292},{36780195,36780292}}

local creator=sp:FindFirstChild("creator")
local debris=game:GetService("Debris")

function createshrapnel(pos)
	local p=Instance.new("Part")
	p.Name="Effect"
	p.Material="Wood"
	p.formFactor="Custom"
	p.CanCollide=true
	p.Anchored=false
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	p.Size=Vector3.new(1,2,1)
	local s=script:FindFirstChild("Script")
	if s~=nil then
		local sc=s:clone()
		sc.Parent=p
		sc.Disabled=false
	end
	local m=Instance.new("SpecialMesh")
	local rm=meshes[math.random(1,#meshes)]
	m.MeshId="http://www.roblox.com/asset/?id="..tostring(rm[1])
	m.TextureId="http://www.roblox.com/asset/?id="..tostring(rm[2])
	m.Parent=p
	if creator~=nil then
		creator:clone().Parent=p
	end
	debris:AddItem(p,2.5+math.random())
	p.CFrame=(CFrame.new(pos)+(Vector3.new(math.random()-.5,math.random()*.5,math.random()-.5)*5))*CFrame.Angles(math.random()*math.pi*2,math.random()*math.pi*2,math.random()*math.pi*2)
	p.Velocity=(p.Position-pos).unit*(shrapnelvelocity*(.5+math.random()))
	p.RotVelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*10
	p.Parent=game.Workspace
end

--[[local smoke=Instance.new("Smoke")
smoke.Size=20
smoke.RiseVelocity=20
smoke.Color=Color3.new(0,.8,0)
smoke.Parent=sp]]

local fire=Instance.new("Fire")
fire.Heat=0
fire.Size=100
fire.Color=Color3.new(1,.9,.8)
fire.SecondaryColor=Color3.new(.75,.25,0)
fire.Parent=sp

local explodesound=sp:FindFirstChild("ExplodeSound")
if explodesound then
	explodesound:Play()
end
sp.Anchored=true
sp.Transparency=1
for i=1,shrapnelcount do
	createshrapnel(sp.Position)
end
wait(.3)
sp:remove()
