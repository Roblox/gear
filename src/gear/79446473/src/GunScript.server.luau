--Made by Stickmasterluke
--[[
	Fixed by ArceusInator 2/18/2015
	- Works with FE
	- No longer bumps unanchored blocks around
	- No longer moves anchored blocks
	- No longer teamkills
	- Now uses velocity to push bricks and it looks way cooler
--]]


sp=script.Parent
plr=game.Players.localPlayer

local GLib = require(206209239)

damage=27
firerate=1
range=150
barreloffset=Vector3.new(0, 0.25, -1.7)
windvec=Vector3.new(2,-1,1).unit

rate=1/30
debris=game:GetService("Debris")
equipped=false
check=true

function tagHumanoid(humanoid)
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=game.Players.LocalPlayer
	creator_tag.Name="creator"
	debris:AddItem(creator,3)
	creator_tag.Parent=humanoid
end

function checkintangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(sp.Parent) or hit.Transparency>.8 or hit.Name=="Handle" or hit.Name=="Effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" or hit.Name=="Rail" then
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
	m.Scale=Vector3.new(2,dist*5,2)
	m.Parent=laser
	debris:AddItem(laser,fadedelay*3)
	laser.Parent=game.Workspace
	--wait(.25)
	local frames=fadedelay/rate
	for frame=1,frames do
		wait(rate)
		local percent=frame/frames
		--m.Scale=Vector3.new(1+(20*percent),dist*5,1+(20*percent))
		laser.CFrame=laser.CFrame+windvec*rate
		laser.Transparency=.5+(percent*.5)
	end
	wait(2)
	laser:remove()
end

function onEquipped(mouse)
	equipped=true
end


script.Parent.Click.OnServerEvent:connect(function(client, hit)
	if client.Character == script.Parent.Parent then
		local he=sp.Parent:FindFirstChild("Head")
		local hu=sp.Parent:FindFirstChild("Humanoid")
		if check and he and hu and hu.Health>0 then
			check=false
			local startpos=he.Position
			local vec=(hit-startpos).unit
			local hit,endpos=castray(startpos,vec,range,sp.Parent,false)
			local fakevec=(endpos-(sp.Handle.CFrame*CFrame.new(barreloffset)).p).unit
			sp.PlaySound.Value=tick()
			local rail=Instance.new("Part")
			rail.Friction=1
			rail.Name="Rail"
			rail.Anchored=false
			rail.CanCollide=true
			rail.formFactor="Custom"
			rail.Size=Vector3.new(.6,.4,8)
			rail.TopSurface="Smooth"
			rail.BottomSurface="Smooth"
			rail.BrickColor=BrickColor.new("Dark stone grey")
			debris:AddItem(rail,10)
			if hit and hit~=nil then
				local h=hit.Parent:FindFirstChild("Humanoid")
				if h~=nil and h.Health>0 and GLib.IsTeammate(GLib.GetPlayerFromPart(script), GLib.GetPlayerFromPart(h))~=true then
					tagHumanoid(h)
					h:TakeDamage(damage)
				end
				if not hit.Anchored then
					rail.Velocity=fakevec*200
					if h==nil then
						hit:BreakJoints()
						hit.Velocity = vec*(hit:GetMass()+rail:GetMass())*10
					else
						hit.Velocity = vec*(hit:GetMass()+rail:GetMass())*10
					end
				end
				local newcf=CFrame.new(endpos,endpos+fakevec)*CFrame.new(0,0,(math.random()*(rail.Size.z-2))-((rail.Size.z-2)/2))
				rail.CFrame=newcf
				local w=Instance.new("Weld")
				w.Part0=hit
				w.Part1=rail
				w.C0=hit.CFrame:toObjectSpace(newcf)
				w.Parent=rail
				local soundscript=sp.SoundScript:clone()
				soundscript.Parent=rail
				soundscript.Disabled=false
				rail.Parent=game.Workspace
				if not hit.Anchored then
					hit.Velocity=hit.Velocity+fakevec*50
				end
			else
				rail.CFrame=CFrame.new(endpos,endpos+fakevec)
				rail.Velocity=fakevec*300
				rail.Parent=game.Workspace
			end
			delay(0,function()	--This is nessecery to fire multible shots at the same time. For those who don't know, delay() is a poor man's coroutine.
				drawbeam((sp.Handle.CFrame*CFrame.new(barreloffset)).p,endpos,BrickColor.new("Institutional white"),2)
			end)
			wait(firerate)
			check=true
		end
	end
end)

function onUnequipped()
	equipped=false
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)





