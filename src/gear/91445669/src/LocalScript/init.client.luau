--Made by Stickmasterluke


sp=script.Parent


speed=2
topspeed=50


rapidfiredamage=12

range=400
rate=1/30
barreloffset=Vector3.new(-.05,.5,-1.5)
windvec=Vector3.new(2,-1,1).unit

chargemode=1
rapidfiremode=2


inertia=1-(speed/topspeed)
debris=game:GetService("Debris")
equipped=false
flying=false
check=true
charge=0
controls={forward=0,backward=0,left=0,right=0}
momentum=Vector3.new(0,0,0)
lastmomentum=Vector3.new(0,0,0)
totalmomentum=0
lastflap=0
tilt=0
lasttilt=0
mode=1

local wing=Instance.new("Part")
wing.CanCollide=false 
wing.Shape="Block"
wing.FormFactor="Custom"
wing.TopSurface="Smooth"
wing.Size=Vector3.new(5,3.5,1)

local WingMesh=Instance.new("SpecialMesh")
WingMesh.TextureId="http://www.roblox.com/asset/?id=90708422"
WingMesh.Scale=Vector3.new(2.5,2.5,2.5)
WingMesh.Parent=wing

function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		wait()
	end
	return parent:FindFirstChild(name)
end

local storeWeld=waitfor(sp,"Motor")
local playsound=waitfor(sp,"PlaySound")
local soundname=waitfor(playsound,"SoundName")
local anim=waitfor(sp,"FlyAnimation")
local gui=waitfor(sp,"ArtemisGui")
local ButtonHolder=waitfor(gui,"ButtonHolder")
local button1=waitfor(ButtonHolder,"Button1")
local button2=waitfor(ButtonHolder,"Button2")

function checkintangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(sp.Parent) or hit.Transparency>.8 or hit.Name=="Handle" or hit.Name=="Effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" or hit.Name=="Rail" or hit.Name=="Arrow" then
			return true
		end
	end
	return false
end

function changemode(newmode)
	charge=0
	mode=newmode
	button1.Image="http://www.roblox.com/asset/?id=90879220"
	button2.Image="http://www.roblox.com/asset/?id=90879178"
	if mode==1 then
		button1.Image="http://www.roblox.com/asset/?id=90878963"
	elseif mode==2 then
		button2.Image="http://www.roblox.com/asset/?id=90879149"
	end
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

function fire(targetpos,startpos,damage,fadedelay)
	local fakestartpos=(sp.Handle.CFrame*CFrame.new(barreloffset)).p
	local vec=(targetpos-startpos).unit

	local p=Instance.new("Part")
	p.Name="Arrow"
	p.BrickColor=BrickColor.new("Black")
	p.CanCollide=true
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	p.formFactor="Custom"
	p.Size=Vector3.new(.3,.3,2.7)
	local m=Instance.new("SpecialMesh")
	m.MeshId="http://www.roblox.com/asset/?id=90708690"
	m.TextureId="http://www.roblox.com/asset/?id=90708422"
	m.Scale=Vector3.new(1,1,2)
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

	local damagetag=Instance.new("IntValue")
	damagetag.Name="DamageTag"
	damagetag.Value=damage
	damagetag.Parent=p

	local s=script.Script:clone()
	s.Parent=p
	s.Disabled=false

	local hit,endpos=castray(startpos,vec,range,sp.Parent,false)
	local fakevec=(endpos-fakestartpos).unit
	if hit~=nil then
		local newcf=CFrame.new(endpos,endpos+fakevec)*CFrame.new(0,0,.9+(math.random(0,1)*.4))
		p.CFrame=newcf
		local w=Instance.new("Weld")
		w.Part0=hit
		w.Part1=p
		w.C0=hit.CFrame:inverse()*newcf
		w.C1=newcf:inverse()*newcf
		w.Parent=p
	else
		p.CFrame=CFrame.new(endpos,endpos+fakevec)
		p.Velocity=fakevec*300
		p.Parent=game.Workspace
	end

	debris:AddItem(p,10+(math.random()*10))
	p.Parent=game.Workspace

	delay(0,function()
		drawbeam(fakestartpos,endpos,BrickColor.new("Institutional white"),fadedelay)
	end)

	soundname.Value="FireSound"
	playsound.Value=not playsound.Value

	if sp:FindFirstChild("Handle2") then
		sp.Handle2.Transparency=1
	end
end

function RemoveFlyStuff()
	local plr=game.Players.LocalPlayer
	if plr then
		local chr=plr.Character
		if chr then
			for i,v in ipairs(chr:getChildren()) do
				if v and v.Name=="RightWing" or v.Name=="LeftWing" then
					v:remove()
				end
			end
			local torso=chr:FindFirstChild("Torso")
			if torso~=nil then
				for i,v in ipairs(torso:GetChildren()) do
					if v and (v.Name=="FlightGyro" or v.Name=="FlightVelocity") then
						v:remove()
					end
				end
			end
		end
	end
end

function fly()		--(de)activate fly mode
	if not equipped then
		flying=false
	else
		flying=not flying
	end
	RemoveFlyStuff()
	if flying then
		local torso=sp.Parent:FindFirstChild("Torso")
		local humanoid=sp.Parent:FindFirstChild("Humanoid")
		if torso and humanoid and humanoid.Health>0 then
			momentum=torso.Velocity+(torso.CFrame.lookVector*3)+Vector3.new(0,10,0)

			local gyro=Instance.new("BodyGyro")
			gyro.Name="FlightGyro"
			gyro.P=10^6
			gyro.maxTorque=Vector3.new(gyro.P,gyro.P,gyro.P)
			gyro.cframe=torso.CFrame
			gyro.Parent=torso

			velocity=Instance.new("BodyVelocity")
			velocity.Name="FlightVelocity"
			velocity.velocity=Vector3.new(0,0,0)
			velocity.P=10^4
			velocity.maxForce=Vector3.new(1,1,1)*(10^6)
			velocity.Parent=torso

			LeftWing=wing:Clone()
			LeftWing.Name="LeftWing"
			LeftWing.Mesh.MeshId="http://www.roblox.com/asset/?id=90821133"
		
			LeftWeld=Instance.new("Motor")
			LeftWeld.Name="LeftWeld"
			LeftWeld.Part0=torso
			LeftWeld.Part1=LeftWing
			LeftWeld.MaxVelocity=.2
			LeftWeld.C0=CFrame.new(-.25,1,.25)*CFrame.Angles(math.pi/2,0,0)
			LeftWeld.C1=CFrame.new(2.5,0,-.5)*CFrame.Angles(math.pi/2,0,0)
			LeftWeld.Parent=LeftWing

			LeftWing.Parent=sp.Parent

			RightWing=wing:Clone()
			RightWing.Name="RightWing"
			RightWing.Mesh.MeshId="http://www.roblox.com/asset/?id=90821193"
		
			RightWeld=Instance.new("Motor")
			RightWeld.Name="RightWeld"
			RightWeld.Part0=torso
			RightWeld.Part1=RightWing
			RightWeld.MaxVelocity=.2
			RightWeld.C0=CFrame.new(.25,1,.25)*CFrame.Angles(math.pi/2,0,0)
			RightWeld.C1=CFrame.new(-2.5,0,-.5)*CFrame.Angles(math.pi/2,0,0)
			RightWeld.Parent=RightWing

			RightWing.Parent=sp.Parent

			if flyanim~=nil then
				flyanim:Stop()
			end
			flyanim=humanoid:LoadAnimation(anim)
			if flyanim then
				flyanim:Play()
			end

			while flying and torso and humanoid and humanoid.Health>0 and equipped do
				local movement=game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(controls.left+controls.right,math.abs(controls.forward)*.2,controls.forward+controls.backward))*speed

				momentum=(momentum*inertia)+movement
				totalmomentum=momentum.magnitude
				if totalmomentum>topspeed then
					totalmomentum=topspeed
				end

				local tilt=((momentum*Vector3.new(1,0,1)).unit:Cross(((lastmomentum*Vector3.new(1,0,1)).unit))).y
				if tostring(tilt)=="-1.#IND" or tostring(tilt)=="1.#IND" or tilt==math.huge or tilt==-math.huge then
					tilt=0
				end
				local abstilt=math.abs(tilt)
				if abstilt>.06 or abstilt<.0001 then
					if math.abs(lasttilt)>.0001 then
						tilt=lasttilt*.9
					else
						tilt=0
					end
				else
					tilt=(lasttilt*.77)+(tilt*.25)			--weighted average
				end
				lasttilt=tilt

				if totalmomentum<.5 then
					momentum=Vector3.new(0,0,0)
					totalmomentum=0
					gyro.cframe=game.Workspace.CurrentCamera.CoordinateFrame
				else
					gyro.cframe=CFrame.new(Vector3.new(0,0,0),momentum)*CFrame.Angles(0,0,tilt*(-20))*CFrame.Angles(math.pi*(-.5)*(totalmomentum/topspeed),0,0)
				end
				velocity.velocity=momentum

				local gravitydelta=(((momentum*Vector3.new(0,1,0))-Vector3.new(0,-topspeed,0)).magnitude/topspeed)*.5
				if gravitydelta>.45 and tick()>lastflap then
					lastflap=tick()+.5
					delay(0,function()
						soundname.Value="WingSound"
						playsound.Value=not playsound.Value

						LeftWeld.DesiredAngle=-.5
						RightWeld.DesiredAngle=.5
						wait(.25)
						LeftWeld.DesiredAngle=.5
						RightWeld.DesiredAngle=-.5
						wait(.25)
						LeftWeld.DesiredAngle=0
						RightWeld.DesiredAngle=0
					end)
				end
				lastmomentum=momentum
				wait(rate)
			end
			RemoveFlyStuff()
			if flyanim~=nil then
				flyanim:Stop()
			end
			flying=false
		end
	end
end

function onEquipped(mouse)
	equipped=true
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			if not down then
				down=true
				while down and equipped do
					local waited=false
					if check then
						if mode==rapidfiremode then
							local hu=sp.Parent:FindFirstChild("Humanoid")
							local he=sp.Parent:FindFirstChild("Head")
							local t=sp.Parent:FindFirstChild("Torso")
							if check and hu and hu.Health>0 and t and he then
								check=false
								sp.Handle.Mesh.Scale=Vector3.new(2,2,2.5)
								storeWeld.C0=CFrame.new(-.05,.5,0)*CFrame.Angles(0,math.pi/2,0)
								wait(.1)
								sp.Handle.Mesh.Scale=Vector3.new(2,2,2)
								fire(mouse.Hit.p,he.Position,rapidfiredamage,.25)
								wait(.15)
								storeWeld.C0=CFrame.new(-.05,.5,-.5)*CFrame.Angles(0,math.pi/2,0)
								if sp:FindFirstChild("Handle2") then
									sp.Handle2.Transparency=0
								end
								wait(.15)
								waited=true
								check=true
							else
								break
							end
						elseif mode==chargemode then
							if charge<100 then
								charge=charge+1
								local percent=(charge/100)
								sp.Handle.Mesh.Scale=Vector3.new(2,2,2+(2*percent))
								storeWeld.C0=CFrame.new(-.05,.5,-.5+percent)*CFrame.Angles(0,math.pi/2,0)
								wait(.05)
								waited=true
							end
						end
					end
					if not waited then
						wait()
					end
				end
			end
		end)
		mouse.Button1Up:connect(function()
			down=false
			if mode==chargemode then
				local hu=sp.Parent:FindFirstChild("Humanoid")
				local he=sp.Parent:FindFirstChild("Head")
				local t=sp.Parent:FindFirstChild("Torso")
				if check and hu and hu.Health>0 and t and he then
					check=false
					fire(mouse.Hit.p,he.Position,charge+10,.25+(charge/50))
					charge=0
					sp.Handle.Mesh.Scale=Vector3.new(2,2,2)
					storeWeld.C0=CFrame.new(-.05,.5,-.5)*CFrame.Angles(0,math.pi/2,0)
					wait(.75)
					if sp:FindFirstChild("Handle2") then
						sp.Handle2.Transparency=0
					end
					wait(.25)
					check=true
				end
			end
		end)
		mouse.KeyDown:connect(function(key2)
			local key=string.byte(key2)
			if key==string.byte("q") then
				changemode(1)
			elseif key==string.byte("e") then
				changemode(2)
			elseif key==32 then					--Space bar
				fly()
				local torso=sp.Parent:FindFirstChild("Torso")
				if torso~=nil then
					torso.Velocity=momentum
				end
			elseif key==string.byte("w") or key==17 then
				controls.forward=-1
			elseif key==string.byte("a") or key==20 then
				controls.left=-1
			elseif key==string.byte("s") or key==18 then
				controls.backward=1
			elseif key==string.byte("d") or key==19 then
				controls.right=1
			end
		end)
		mouse.KeyUp:connect(function(key2)
			local key=string.byte(key2)
			if key==string.byte("w") or key==17 then
				controls.forward=0
			elseif key==string.byte("a") or key==20 then
				controls.left=0
			elseif key==string.byte("s") or key==18 then
				controls.backward=0
			elseif key==string.byte("d") or key==19 then
				controls.right=0
			end
		end)
		local plr=game.Players.LocalPlayer
		if plr then
			local plrgui=plr:FindFirstChild("PlayerGui")
			if plrgui then
				gui.Parent=plrgui
			end
		end
	end
	if storeWeld then
		storeWeld.Parent=sp
	end
end

function onUnequipped()
	equipped=false
	storeWeld.C0=CFrame.new(-.05,.5,-.5)*CFrame.Angles(0,math.pi/2,0)
	gui.Parent=sp
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

button1.MouseButton1Down:connect(function()
	changemode(1)
end)
button2.MouseButton1Down:connect(function()
	changemode(2)
end)
changemode(1)





