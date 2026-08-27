--Made by Stickmasterluke


sp=script.Parent
check=true

gundamage=30								--Base output damage per shot.
firerate=.27								--How often the weapon can fire.
automatic=false								--hold down to continue firing
range=300									--Max distance that the weapon can fire.
spread=2									--The bigger the spread, the more inaccurate the shots will be.
clipsize=12									--Shots in a clip
reloadtime=3								--Time it takes to reload the tool.
startingclips=10							--If you want infinit clips, remove the IntValue named "Clips" from the tool.
segmentlength=35							--How long the shot segments are, or the speed of the shot.
fadedelaytime=1/30


barrelpos=CFrame.new(0,.3,-1)		--R,U,B
rate=1/30
intangibles={"Shock","Bolt","Bullet","Plasma","Effect","Laser","Handle","Effects","Effect","Flash"}
shotcolor=BrickColor.new("Really red")
flashcolors={"Really red","Bright red","Bright orange","New Yeller"}

reloading=false
local debris=game:GetService("Debris")

local ammo=sp:FindFirstChild("Ammo")
if ammo~=nil then
	ammo.Value=clipsize
end
local clips=sp:FindFirstChild("Clips")
if clips~=nil then
	clips.Value=startingclips
end

sp.Equipped:connect(function()
	sp.Handle.Fire:Stop()
	sp.Handle.Reload:Stop()
end)
sp.Unequipped:connect(function()
	sp.Handle.Fire:Stop()
	sp.Handle.Reload:Stop()
end)

function round(number,decimal)
	decimal=decimal or 0
	local mult=10^decimal
	return math.floor(number*mult+.5)/mult
end

function checkintangible(t)
	for i3,v3 in ipairs(intangibles) do
		if string.lower(v3)==string.lower(t.Name) or t.Transparency==1 then
			return true
		end
	end
	return false
end

function reload()
	reloading=true
	sp.Reloading.Value=true
	if clips~=nil then
		if clips.Value>0 then
			clips.Value=clips.Value-1
		else
			reloading=false
			sp.Reloading.Value=false
			return
		end
	end
	sp.Handle.Reload:Play()
	for i=1,clipsize do
		wait(reloadtime/clipsize)
		ammo.Value=i
	end
	reloading=false
	sp.Reloading.Value=false
end

function castray(startpos,vec,length,ignore,delayifhit)
	if length>999 then
		length=999
	end
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

function sendbullet(boltstart,targetpos,fuzzyness,segmentlength,ignore,clr,damage,fadedelay)
	if ammo~=nil then
		if ammo.Value>0 then
			ammo.Value=ammo.Value-1
		else
			reload()
			return
		end
	end
	sp.Handle.Fire:Play()
	muzzleeffect()
	local t=sp.Parent:FindFirstChild("Torso") or sp.Parent:FindFirstChild("UpperTorso")
	local rightArm = sp.Parent:FindFirstChild("Right Arm") or sp.Parent:FindFirstChild("RightUpperArm")
	if t~=nil then
		local shoulder=t:FindFirstChild("Right Shoulder") or rightArm:FindFirstChild("RightShoulder")
		if shoulder~=nil then
			shoulder.CurrentAngle=2
		end
	end

	local boltdist=range
	local clickdist=(boltstart-targetpos).magnitude
	local targetpos=targetpos+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*(clickdist/100)*fuzzyness)
	local boltvec=(targetpos-boltstart).unit
	local totalsegments=math.ceil(boltdist/segmentlength)
	local lastpos=boltstart
	for i=1,totalsegments do
		local newpos=(boltstart+(boltvec*(boltdist*(i/totalsegments))))
		local segvec=(newpos-lastpos).unit
		local boltlength=(newpos-lastpos).magnitude
		local bolthit,endpos=castray(lastpos,segvec,boltlength,ignore,false)
		drawbeam(lastpos,endpos,clr,fadedelay)
		if bolthit~=nil then
			local h=bolthit.Parent:FindFirstChild("Humanoid")
			if h~=nil then
				local plr=game.Players:GetPlayerFromCharacter(sp.Parent)
				if plr~=nil then
					for i,v in ipairs(h:GetChildren()) do
						if v and v.Name=="creator" then
							v:remove()
						end
					end
					local creator=Instance.new("ObjectValue")
					creator.Name="creator"
					creator.Value=plr
					creator.Parent=h
				end
				h:TakeDamage(damage)
			else
				delay(0,function() hiteffect(endpos) end)
			end
			break
		end
		lastpos=endpos
		wait(rate)
	end
end

function drawbeam(beamstart,beamend,clr,fadedelay)
	local dis=(beamstart-beamend).magnitude
	local laser=Instance.new("Part")
	laser.Name="Bullet"
	laser.Anchored=true
	laser.CanCollide=false
	laser.Shape="Block"
	laser.formFactor="Custom"
	laser.Size=Vector3.new(.25,.25,dis+.2)
	laser.Material=Enum.Material.Plastic
	laser.Locked=true
	laser.TopSurface=0
	laser.BottomSurface=0
	laser.BrickColor=clr
	laser.CFrame=CFrame.new(beamend,beamstart)*CFrame.new(0,0,-dis/2)
	local light=Instance.new("PointLight")
	light.Color=shotcolor.Color
	light.Range=20
	light.Parent=laser
	laser.Parent=game.Workspace
	debris:AddItem(laser,fadedelay)
end

function hiteffect(pos)
	local effect=Instance.new("Part")
	effect.Name="Effect"
	effect.Anchored=true
	effect.CanCollide=false
	effect.Shape="Block"
	effect.formFactor="Custom"
	effect.Size=Vector3.new(.2,.2,.2)
	effect.Material=Enum.Material.Plastic
	effect.Locked=true
	effect.TopSurface=0
	effect.BottomSurface=0
	effect.BrickColor=shotcolor
	local mesh=Instance.new("SpecialMesh")
	mesh.MeshType="Sphere"
	mesh.Scale=Vector3.new(3,3,3)
	mesh.Parent=effect
	local light=Instance.new("PointLight")
	light.Color=shotcolor.Color
	light.Range=20
	light.Parent=effect
	effect.CFrame=CFrame.new(pos)
	local effecttime=3
	debris:AddItem(effect,effecttime*2)
	effect.Parent=game.Workspace
	local effectrate=2/10
	local frames=(1/effectrate)*effecttime
	for i=1,frames do
		wait(effectrate)
		if effect~=nil and mesh~=nil and light~=nil then
			light.Range=(1-(i/frames))*20
			effect.Transparency=i/frames
		end
	end
	if effect~=nil then
		effect.Parent=nil
	end
end

function muzzleeffect()
	local flash=Instance.new("Part")
	flash.Name="Effect"
	flash.Anchored=true
	flash.CanCollide=false
	flash.Shape="Block"
	flash.formFactor="Custom"
	flash.Size=Vector3.new(.2,.2,.2)
	flash.Material=Enum.Material.Plastic
	flash.Locked=true
	flash.TopSurface=0
	flash.BottomSurface=0
	flash.BrickColor=BrickColor.new(flashcolors[math.random(1,#flashcolors)])
	local mesh=Instance.new("SpecialMesh")
	mesh.MeshId="http://www.roblox.com/asset/?id=25212400"
	local scale=Vector3.new(.2+(math.random()*.1),.4+(math.random()*.4),.2+(math.random()*.1))
	mesh.Scale=scale
	mesh.Parent=flash
	flash.CFrame=sp.Handle.CFrame*barrelpos*CFrame.Angles(-math.pi/2,math.pi*2*math.random(),0)*CFrame.new(0,scale.y*.9,0)
	debris:AddItem(flash,rate)
	flash.Parent=game.Workspace
end

sp.Down.Changed:connect(function()
	while sp.Down.Value and check and not reloading do
		check=false
		local humanoid=sp.Parent:FindFirstChild("Humanoid")
		local plr1=game.Players:GetPlayerFromCharacter(sp.Parent)
		if humanoid~=nil and plr1~=nil then
			if humanoid.Health>0 then
				spos1=(sp.Handle.CFrame*barrelpos).p
				delay(0,function() sendbullet(spos1,sp.Aim.Value,spread,segmentlength,sp.Parent,shotcolor,gundamage,fadedelaytime) end)
			else
				check=true
				break
			end
		else
			check=true
			break
		end
		wait(firerate)
		check=true
		if not automatic then
			break
		end
	end
end)



