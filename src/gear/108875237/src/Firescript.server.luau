--Made by Stickmasterluke



--http://www.roblox.com/Equinox-item?id=19327469

sp=script.Parent
check=true

gundamage=11								--Base output damage per shot.
firerate=.1									--How often the weapon can fire.
automatic=true								--hold down to continue firing
range=300									--Max distance that the weapon can fire.
spread=6										--The bigger the spread, the more inaccurate the shots will be.
clipsize=50									--Shots in a clip
reloadtime=5								--Time it takes to reload the tool.
startingclips=10							--If you want infinit clips, remove the IntValue named "Clips" from the tool.
segmentlength=40							--How long the shot segments are, or the speed of the shot.
fadedelaytime=1/30


barrelpos=CFrame.new(0,2,0.05)		--L,F,U
rate=1/30
intangibles={"Shock","Bolt","Bullet","Plasma","Effect","Laser","Handle","Effects","Effect","Flash"}
colors={BrickColor.new("Cyan"),BrickColor.new("Pastel blue-green"),BrickColor.new("Lime green"),BrickColor.new("New Yeller")}
flashcolors={"Teal","Toothpaste","Cyan","Pastel blue-green"}

reloading=false
local debris=game:GetService("Debris")

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

waitfor(sp,"Aim")
waitfor(sp,"Reloading")
waitfor(sp,"Down")
reloadtrigger=waitfor(sp,"Reload")

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
	if not reloading and ammo.Value<clipsize then
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
end
reloadtrigger.Changed:connect(reload)

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
	if t~=nil then
		local shoulder=t:FindFirstChild("Right Shoulder")
		if shoulder~=nil then
			shoulder.CurrentAngle=1.63
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
				local head=bolthit.Parent:FindFirstChild("Head")
				if head~=nil then
					local sh=bolthit.Parent:FindFirstChild("ShockedHat")
					if sh==nil then
						local p=Instance.new("Part")
						p.Name="ShockedHat"
						p.CanCollide=false
						p.Locked=true
						p.TopSurface="Smooth"
						p.BottomSurface="Smooth"
						p.Material = Enum.Material.Neon
						p.Size=Vector3.new(0,0,0)
						local m=Instance.new("SpecialMesh")
						m.MeshId="http://www.roblox.com/asset/?id=19326912"
						m.TextureId="http://www.roblox.com/asset/?id=19326893"
						m.Scale=Vector3.new(1,1,1)*1.05
						m.Parent=p
						local w=Instance.new("Weld")
						w.Part0=head
						w.Part1=p
						w.C0=CFrame.new(0,.5,0,1,0,0,0,1,0,0,0,1)
						w.C1=CFrame.new(0,-.15,-.05,1,0,0,0,1,0,0,0,1)
						w.Parent=p
						local thefire=Instance.new("Fire")
						thefire.Color=Color3.new(0,1,1)
						thefire.SecondaryColor=Color3.new(1,1,0)
						thefire.Heat=25
						thefire.Parent=p
						local thesmoke=Instance.new("Smoke")
						thesmoke.Color=Color3.new(1,1,1)
						thesmoke.Opacity=.15
						thesmoke.RiseVelocity=1
						thesmoke.Size=.1
						thesmoke.Parent=p
						delay(.2,function()
							if thefire~=nil then
								thefire.Enabled=false
							end
						end)
						debris:AddItem(p,3)
						p.Parent=bolthit.Parent
					else
						local thefire=sh:FindFirstChild("Fire")
						if thefire then
							thefire.Enabled=true
							delay(.2,function()
								if thefire~=nil then
									thefire.Enabled=false
								end
							end)
						end
					end
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
	laser.Size=Vector3.new(.2,.2,dis+.2)
	laser.Material=Enum.Material.Neon
	laser.Locked=true
	laser.TopSurface=0
	laser.BottomSurface=0
	laser.BrickColor=clr
	laser.CFrame=CFrame.new(beamend,beamstart)*CFrame.new(0,0,-dis/2)
	laser.Parent=game.Workspace
	debris:AddItem(laser,fadedelay)
end

function hiteffect(pos)
	local effect=Instance.new("Part")
	effect.Name="Effect"
	effect.Anchored=true
	effect.CanCollide=false
	effect.Shape="Block"
	effect.Size=Vector3.new(.2,.2,.2)
	effect.Material=Enum.Material.Plastic
	effect.Locked=true
	effect.TopSurface=0
	effect.BottomSurface=0
	effect.BrickColor=colors[1]
	local mesh=Instance.new("SpecialMesh")
	mesh.MeshType="Sphere"
	mesh.Scale=Vector3.new(3,3,3)
	mesh.Parent=effect
	effect.CFrame=CFrame.new(pos)
	local effecttime=3
	debris:AddItem(effect,effecttime*2)
	effect.Parent=game.Workspace
	local effectrate=2/10
	for i=1,(1/effectrate)*effecttime do
		wait(effectrate)
		if effect~=nil and mesh~=nil then
			effect.Transparency=i/((1/effectrate)*effecttime)
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
	flash.Size=Vector3.new(.2,.2,.2)
	flash.Material=Enum.Material.Plastic
	flash.Locked=true
	flash.TopSurface=0
	flash.BottomSurface=0
	flash.BrickColor=BrickColor.new(flashcolors[math.random(1,#flashcolors)])
	local mesh=Instance.new("SpecialMesh")
	mesh.MeshId="http://www.roblox.com/asset/?id=25212400"
	local scale=Vector3.new(.1+(math.random()*.1),.4+(math.random()*.4),.1+(math.random()*.1))
	mesh.Scale=scale
	mesh.Parent=flash
	flash.CFrame=sp.Handle.CFrame*barrelpos*CFrame.new(0,scale.y*.9,0)*CFrame.Angles(0,math.pi*2*math.random(),0)
	debris:AddItem(flash,rate*2)
	flash.Parent=game.Workspace
	delay(rate,function()
		if mesh~=nil and mesh.Parent~=nil then
			mesh.Scale=mesh.Scale*Vector3.new(1.2,1.2,1)
		end
	end)
end

sp.Down.Changed:connect(function()
	while sp.Down.Value and check and not reloading do
		check=false
		local humanoid=sp.Parent:FindFirstChild("Humanoid")
		local plr1=game.Players:GetPlayerFromCharacter(sp.Parent)
		if humanoid~=nil and plr1~=nil then
			if humanoid.Health>0 then
				spos1=(sp.Handle.CFrame*barrelpos).p
				delay(0,function() sendbullet(spos1,sp.Aim.Value,spread,segmentlength,sp.Parent,colors[1],gundamage,fadedelaytime) end)
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



