--Made by Stickmasterluke


sp=script.Parent


firerate=.5
range=50
rate=1/30
barreloffset=Vector3.new(0,0,-1.5)
windvec=Vector3.new(2,-1,1).unit

debris=game:GetService("Debris")
equipped=false
check=true

lasttrap=nil
bolt={}

function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		wait()
	end
	return parent:FindFirstChild(name)
end

local firesound=waitfor(sp,"FireSound")

function checkintangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(sp.Parent) or hit.Parent:FindFirstChild("Humanoid") or hit.Transparency>.8 or hit.CanCollide==false or hit.Name=="Handle" or string.lower(string.sub(hit.Name,1,6))=="effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" or hit.Name=="Rail" or hit.Name=="Arrow" then
			return true
		end
	end
	return false
end

function castray(startpos,vec,length,ignore,delayifhit)
	local hit,endpos2=game.Workspace:FindPartOnRay(Ray.new(startpos,vec*length),ignore)
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

function drawbeam(beamstart,beamend,clr,fadedelay)
	local dist=(beamstart-beamend).magnitude
	local laser=Instance.new("Part")
	laser.Name="Effect"
	laser.Anchored=true
	laser.CanCollide=false
	laser.Shape="Block"
	laser.formFactor="Custom"
	laser.Size=Vector3.new(.2,.2,.2)
	laser.Transparency=5
	laser.Material=Enum.Material.Plastic
	laser.Locked=true
	laser.TopSurface=0
	laser.BottomSurface=0
	laser.BrickColor=clr
	laser.CFrame=CFrame.new(beamend,beamstart)*CFrame.new(0,0,-dist/2)*CFrame.Angles(math.pi/2,0,0)
	local m=Instance.new("SpecialMesh")
	m.Scale=Vector3.new(1,dist*5,1)
	m.Parent=laser
	debris:AddItem(laser,fadedelay*3)
	laser.Parent=game.Workspace

	local frames=math.floor(fadedelay/rate)
	for frame=1,frames do
		wait(rate)
		local percent=frame/frames
		laser.CFrame=laser.CFrame+windvec*rate
		laser.Transparency=.5+(percent*.5)
	end
	wait(1)
	laser:remove()
end

function onEquipped(mouse)
	equipped=true
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local hu=sp.Parent:FindFirstChild("Humanoid")
			local he=sp.Parent:FindFirstChild("Head")
			local t=sp.Parent:FindFirstChild("Torso")
			if check and hu and hu.Health>0 and t and he then
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				firesound.Value=not firesound.Value
				local shoulder=t:FindFirstChild("Right Shoulder")
				if shoulder~=nil then
					shoulder.CurrentAngle=2
				end

				if lasttrap~=nil then
					if bolt[2]~=nil and bolt[1]~=nil then
						bolt[2]:remove()
						table.remove(bolt,2)
						bolt[1]:remove()
						table.remove(bolt,1)
					end
					lasttrap:remove()
					lasttrap=nil
				end
				check=false

				local startpos=he.Position
				local fakestartpos=(sp.Handle.CFrame*CFrame.new(barreloffset)).p
				local vec=(mouse.Hit.p-startpos).unit

				local p=Instance.new("Part")
				p.Name="Effect"
				p.BrickColor=BrickColor.new("Brown")
				p.CanCollide=true
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.formFactor="Custom"
				p.Size=Vector3.new(.2,1.5,.2)
				local m=Instance.new("CylinderMesh")
				m.Parent=p

				local sound=Instance.new("Sound")
				sound.SoundId="http://www.roblox.com/asset/?id=16211030"
				sound.Volume=1
				sound.Parent=p
				sound:Play()

				local hit,endpos=castray(startpos,vec,range,sp.Parent,false)
				local fakevec=(endpos-fakestartpos).unit
				if hit~=nil then
					local newcf=CFrame.new(endpos)+Vector3.new(0,.5,0)
					p.CFrame=newcf
					local w=Instance.new("Weld")
					w.Part0=hit
					w.Part1=p
					w.C0=hit.CFrame:inverse()*newcf
					w.C1=newcf:inverse()*newcf
					w.Parent=p
					debris:AddItem(p,120)
					p.Parent=game.Workspace
					table.insert(bolt,p)
				end

				delay(0,function()
					drawbeam(fakestartpos,endpos,BrickColor.new("Institutional white"),.25)
				end)
				
				if bolt[1]~=nil and bolt[1].Parent==game.Workspace and bolt[2]~=nil and bolt[2].Parent==game.Workspace then
					if (bolt[1].Position-bolt[2].Position).magnitude<range then
						local trip=Instance.new("Model")
						trip.Name="Tripwire"
						trip.Parent=game.Workspace
						bolt[1].Parent=trip
						bolt[2].Parent=trip
						local c=Instance.new("ObjectValue")
						c.Name="creator"
						c.Value=game.Players.LocalPlayer
						c.Parent=trip
						local s=script.Script:clone()
						s.Parent=trip
						s.Disabled=false
						lasttrap=trip
					else
						if bolt[2]~=nil then
							bolt[2]:remove()
							table.remove(bolt,2)
						end
						if bolt[1]~=nil then
							bolt[1]:remove()
							table.remove(bolt,1)
						end
						if lasttrap~=nil then
							lasttrap:remove()
							lasttrap=nil
						end
					end
					wait(2)
				end

				wait(firerate)
				if mouse~=nil then
					mouse.Icon="rbxasset://textures\\GunCursor.png"
				end
				check=true
			end
		end)
	end
	if storeWeld then
		storeWeld.Parent=sp
	end
end

function onUnequipped()
	equipped=false
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)





