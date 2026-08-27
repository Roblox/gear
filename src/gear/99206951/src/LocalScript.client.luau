--Made by Stickmasterluke


sp=script.Parent
plr=game.Players.localPlayer


colors={"Bright red","Bright green","Really red","Lime green"}
firerate=1
range=100
barreloffset=Vector3.new(0,.1,-1.5)	--R,U,B

rate=1/30
debris=game:GetService("Debris")
equipped=false
check=true

function checkintangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(sp.Parent) or hit.Transparency>.8 or hit.Name=="Handle" or hit.Name=="Effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" then
			return true
		end
	end
	return false
end

function castray(startpos,vec,length,ignore,delayifhit)
	hit,endpos2=game.Workspace:FindPartOnRay(Ray.new(startpos,vec*length),ignore)
	if hit~=nil then
		if checkintangible(hit) then
			if delayifhit then
				wait()
			end
			hit,endpos2=castray(endpos2+(vec*.01),vec,length-((startpos-endpos2).magnitude),ignore,delayifhit)
		end
	end
	return hit,endpos2
end

function drawbeam(beamstart,beamend,fadedelay)
	local dist=(beamstart-beamend).magnitude
	local laser=Instance.new("Part")
	laser.Name="Effect"
	laser.Anchored=true
	laser.CanCollide=false
	laser.Shape="Block"
	laser.formFactor="Custom"
	laser.Size=Vector3.new(.2,.2,.2)
	laser.Transparency=0
	laser.Material=Enum.Material.Plastic
	laser.Locked=true
	laser.TopSurface=0
	laser.BottomSurface=0
	laser.BrickColor=BrickColor.new(colors[math.random(1,#colors)])
	laser.CFrame=CFrame.new(beamend,beamstart)*CFrame.new(0,0,-dist/2)*CFrame.Angles(math.pi/2,0,0)
	local m=Instance.new("SpecialMesh")
	m.Scale=Vector3.new(1,dist*5,1)
	m.Parent=laser
	debris:AddItem(laser,fadedelay*3)
	laser.Parent=game.Workspace
	wait(.25)
	local frames=fadedelay/rate
	for frame=1,frames do
		wait(rate)
		local percent=frame/frames
		m.Scale=Vector3.new(1+(20*percent),dist*5,1+(20*percent))
		laser.Transparency=.5+(percent*.5)
	end
	wait(2)
	laser:remove()
end

function onEquipped(mouse)
	equipped=true
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local he=sp.Parent:FindFirstChild("Head")
			local hu=sp.Parent:FindFirstChild("Humanoid")
			if check and he and hu and hu.Health>0 then
				check=false
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				local startpos=he.Position
				local vec=(mouse.Hit.p-startpos).unit
				local hit,endpos=castray(startpos,vec,range,sp.Parent,false)
				sp.Handle.Sound:Play()
				if hit and hit~=nil then
					local h=hit.Parent:FindFirstChild("Humanoid")
					local t=hit.Parent:FindFirstChild("Torso")
					if h~=nil and h.Health>0 and t~=nil and hit.Parent:FindFirstChild("LightWrap")==nil then
						local p=Instance.new("Part")
						p.Name="LightWrap"
						p.Anchored=false
						p.CanCollide=false
						p.Locked=true
						p.BrickColor=BrickColor.new(colors[math.random(1,#colors)])
						p.TopSurface="Smooth"
						p.BottomSurface="Smooth"
						p.FormFactor="Custom"
						p.Size=Vector3.new(0,0,0)
						local m=Instance.new("SpecialMesh")
						m.MeshId="http://www.roblox.com/asset/?id=19105988"
						m.TextureId="http://www.roblox.com/asset/?id=19105951"
						m.Scale=Vector3.new(1.5,1.5,1.5)
						m.Parent=p
						local s2=sp:FindFirstChild("Script")
						if s2~=nil then
							local s=s2:clone()
							s.Parent=p
							s.Disabled=false
						end
						local w=Instance.new("Weld")
						w.Part0=t
						w.Part1=p
						w.Parent=p
						debris:AddItem(p,10)
						p.Parent=t.Parent
					end
				end
				delay(0,function()	--This is nessecery to fire multible shots at the same time. For those who don't know, delay() is a poor man's coroutine.
					drawbeam((sp.Handle.CFrame*CFrame.new(barreloffset)).p,endpos,.5)
				end)
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





