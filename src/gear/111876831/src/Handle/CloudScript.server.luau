--Made by Stickmasterluke


sp=script.Parent


rate=1/30



local debris=game:GetService("Debris")
local mesh=sp:WaitForChild("Mesh")


function checkintangible(hit)
	if hit then
		if hit:IsDescendantOf(sp) or hit.Transparency>.8 or hit.Name=="Handle" or string.lower(string.sub(hit.Name,1,6))=="effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" or hit.Name=="Rail" or hit.Name=="Arrow" then
			return true
		end
	end
	return false
end

function castray(startpos,vec,length,ignore)
	local hit,endpos2=game.Workspace:FindPartOnRay(Ray.new(startpos,vec*length),ignore)
	if hit~=nil then
		if checkintangible(hit) then
			hit,endpos2=castray(endpos2+(vec*.01),vec,length-((startpos-endpos2).magnitude),ignore)
		end
	end
	return hit,endpos2
end






frames=math.floor(3/rate)
for frame=1,frames do
	wait(rate)
	local percent=frame/frames
	mesh.Scale=Vector3.new(3,3,3)+(Vector3.new(1,1,1)*8*percent)
end
	


function grow(part,pos)
	if part and pos then
		local toobjectspace=part.CFrame:toObjectSpace(CFrame.new(pos+Vector3.new(0,-1,0))*CFrame.Angles(0,math.random()*math.pi*2,0))
		wait(5)
		spawn(function()
			if part and toobjectspace then
				local growrate=.1
				local growheight=.5+math.random()
				local p=Instance.new("Part")
				p.Name="EffectFrondescence"
				p.BrickColor=BrickColor.new("Bright green")
				p.Anchored=false
				p.CanCollide=false
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.FormFactor="Custom"
				p.Size=Vector3.new(.2,.2,.2)
				local m=Instance.new("SpecialMesh")
				if math.random()<=.5 then
					m.Scale=Vector3.new(1,3,1)
					m.MeshId="http://www.roblox.com/asset/?id=12212520"
					m.TextureId="http://www.roblox.com/asset/?id=12212536"
					m.VertexColor=Vector3.new(math.random(1,3)*.1,7.8,math.random(1,3)*.1)
				else
					growheight=1+(math.random()*.5)
					if math.random()<=.618 then
						m.MeshId="http://www.roblox.com/asset/?id=111797211"
						local rc=math.random(1,3)
						if rc==1 then
							m.VertexColor=Vector3.new(1,1,1)
						elseif rc==2 then
							m.VertexColor=Vector3.new(1,1,0)
						elseif rc==3 then
							m.VertexColor=Vector3.new(0,1,1)
						end
					else
						m.MeshId="http://www.roblox.com/asset/?id=111796999"
					end
					m.Scale=Vector3.new(.5,.5,.5)
					m.TextureId="http://www.roblox.com/asset/?id=111796880"
				end
				m.Parent=p
				local w=Instance.new("Motor")
				w.Part0=part
				w.Part1=p
				w.C0=toobjectspace
				w.Parent=p
				debris:AddItem(w,15+(math.random()*10))
				debris:AddItem(p,30)
				p.Parent=workspace
				local growframes=math.ceil(5/growrate)
				for i=1,growframes do
					if w then
						wait(growrate)
						w.C1=CFrame.new(0,-(i/growframes)*growheight,0)
					end
				end
			end
		end)
	end
end

function raincast(fallrate)
	local size=sp.Size
	local rainstart=(sp.CFrame*CFrame.new(size*(-.5))*CFrame.new(size.x*math.random(),0,size.z*math.random())).p
	local vec=Vector3.new(-1,-10,.5).unit
	local hit,hitpos=castray(rainstart,vec,50,sp)
	local hitpos=hitpos or vec*50
	local dist=(rainstart-hitpos).magnitude
	
	local p=Instance.new("Part")
	p.Name="EffectRain"
	p.BrickColor=(math.random(1,2)==1 and BrickColor.new("Bright blue")) or BrickColor.new("Deep blue")
	p.Anchored=true
	p.CanCollide=false
	p.FormFactor="Custom"
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	p.Transparency=.5
	local fallframes=math.ceil(dist/fallrate)
	p.Size=Vector3.new(.2,.2,(dist/fallframes)*1.618)
	debris:AddItem(p,3)
	spawn(function()
		if hit and math.random()<=.25 then
			grow(hit,hitpos)
		end	
	end)
	p.Parent=sp
	for i=1,fallframes do
		if p then
			p.CFrame=CFrame.new(rainstart,hitpos)*CFrame.new(0,0,-dist*((i-.5)/fallframes))
			wait()
		end
	end	
	if p then
		p:Destroy()
	end
end

local sound=sp:FindFirstChild("Sound")
if sound then
	sound:Play()
end
rains=90
for i=1,rains do
	wait(math.random()*.1)
	spawn(function()
		--raincast(math.random(1,4)/2+((1-(i/rains))*2))
		raincast(3+((1-(i/rains))*2))
	end)
end
if sound then
	sound:Stop()
end

wait(2)
frames=math.floor(2/rate)
for frame=1,frames do
	wait(rate)
	local percent=frame/frames
	sp.Transparency=percent
end
wait(5)
sp:Destroy()



