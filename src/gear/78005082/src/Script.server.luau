--Stickmasterluke


sp=script.Parent


rate=1/30
time=2
radius=15
heal=100
local debris=game:GetService("Debris")
humanoids={}

while (sp.Velocity).magnitude>.1 do
	wait(.25)
end
sp.Anchored=true
sp.CanCollide=false

p=Instance.new("Part")
p.Anchored=true
p.CanCollide=false
p.FormFactor="Custom"
p.TopSurface="Smooth"
p.BottomSurface="Smooth"
p.Size=Vector3.new(.2,.2,.2)
p.BrickColor=BrickColor.new("Toothpaste")
p.Transparency=.5
oc=CFrame.new(sp.Position)*CFrame.Angles(math.pi/2,0,0)
p.CFrame=oc
m=Instance.new("SpecialMesh")
m.MeshId="http://www.roblox.com/asset/?id=3270017"
m.Scale=Vector3.new(0,0,0)
m.Parent=p
s=Instance.new("Sound")
s.Volume=1
s.SoundId="http://www.roblox.com/asset/?id=75338443"
s.PlayOnRemove=false
s.Looped=false
s.Parent=p
s2=Instance.new("Sound")
s2.SoundId="http://www.roblox.com/asset/?id=75336185"
s2.PlayOnRemove=false
s2.Looped=false
s2.Parent=p
debris:AddItem(p,10)
p.Parent=game.Workspace
s:Play()
frames=time/rate
for frame=1,frames do
	percent=frame/frames
	m.Scale=Vector3.new(percent*radius*2,percent*radius*2,2)
	wait(rate)
end
s:Stop()
wait(1)
function recursive(a)
	if a and a~=nil and a.Parent~=nil then
		if a.className=="Humanoid" then
			table.insert(humanoids,a)
		end
		for i,v in ipairs(a:GetChildren()) do
			recursive(v)
		end
	end
end
recursive(game.Workspace)
s2:Play()
frames=time/rate
for frame=1,frames do
	percent=frame/frames
	p.Transparency=.5+(.5*percent)
	p.CFrame=oc+Vector3.new(0,10*percent,0)
	for i,h in ipairs(humanoids) do
		if h and h~=nil and h.Parent~=nil and h.Health>0 then
			local t=h.Parent:FindFirstChild("Torso")
			if t~=nil then
				if (t.Position-sp.Position).magnitude<radius+2 then
					h.Health=h.Health+((heal*rate)/time)
				end
			end
		end
	end
	wait(rate)
end

p:remove()
sp:remove()




