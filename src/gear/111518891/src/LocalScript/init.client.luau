--Made by Stickmasterluke


sp=script.Parent


firerate=1.25
range=600
power=300
rate=1/30
barreloffset=Vector3.new(0,0,-1.5)
windvec=Vector3.new(2,-1,1).unit

debris=game:GetService("Debris")
equipped=false
check=true

function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		wait()
	end
	return parent:FindFirstChild(name)
end

local storeWeld=waitfor(sp,"BoltWeld")
local firesound=waitfor(sp,"FireSound")

function checkintangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(sp.Parent) or hit.Transparency>.8 or hit.Name=="Handle" or string.lower(string.sub(hit.Name,1,6))=="effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" or hit.Name=="Rail" or hit.Name=="Arrow" then
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
				check=false

				local startpos=he.Position
				local fakestartpos=(sp.Handle.CFrame*CFrame.new(barreloffset)).p
				local vec=(mouse.Hit.p-startpos).unit

				local p=Instance.new("Part")
				p.Name="Arrow"
				p.BrickColor=BrickColor.new("Black")
				p.CanCollide=true
				p.TopSurface="Smooth"
				p.BottomSurface="Smooth"
				p.formFactor="Custom"
				p.Size=Vector3.new(.2,.2,2)
				local m=Instance.new("SpecialMesh")
				m.MeshId="http://www.roblox.com/asset/?id=111513060"
				m.TextureId="http://www.roblox.com/asset/?id=111502821"
				m.Scale=Vector3.new(1,1,1)
				m.Parent=p

				local c=Instance.new("ObjectValue")
				c.Name="creator"
				c.Value=game.Players.LocalPlayer
				c.Parent=p

				local sound=Instance.new("Sound")
				sound.SoundId="http://www.roblox.com/asset/?id=16211030"
				sound.Volume=1
				sound.Parent=p
				sound:Play()

				local s=script.Script:clone()
				s.Parent=p
				s.Disabled=false

				local hit,endpos=castray(startpos,vec,range,sp.Parent,false)
				local fakevec=(endpos-fakestartpos).unit
				if hit~=nil then
					local newcf=CFrame.new(endpos,endpos+fakevec)*CFrame.new(0,0,.5)
					p.CFrame=newcf
					local w=Instance.new("Weld")
					w.Part0=hit
					w.Part1=p
					w.C0=hit.CFrame:inverse()*newcf
					w.C1=newcf:inverse()*newcf
					w.Parent=p
				else
					p.CFrame=CFrame.new(endpos,endpos+fakevec)
					p.Velocity=fakevec*power
					p.Parent=game.Workspace
				end

				debris:AddItem(p,20)
				p.Parent=game.Workspace

				delay(0,function()
					drawbeam(fakestartpos,endpos,BrickColor.new("Institutional white"),.25)
				end)

				firesound.Value=not firesound.Value
				local shoulder=t:FindFirstChild("Right Shoulder")
				if shoulder~=nil then
					shoulder.CurrentAngle=2
				end
				if sp:FindFirstChild("Effect") then
					sp.Effect.Transparency=1
				end
				mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
				wait(firerate)
				if sp:FindFirstChild("Effect") then
					sp.Effect.Transparency=0
				end
				mouse.Icon="rbxasset://textures\\GunCursor.png"
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





