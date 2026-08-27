--Made by Stickmasterluke


sp=script.Parent


local weaponevent=sp:WaitForChild("WeaponEvent")

damage=22
firerate=.25
range=200
barreloffset=Vector3.new(0,1.9,.3)

blackholeduration=3.5
force=3000
eventhorizon=2
effectradius=20

rate=1/30
debris=game:GetService("Debris")
lastblackhole=0
equipped=false
check=true


function tagHumanoid(humanoid)
	for _,v in pairs(humanoid:GetChildren()) do
		if v and v.Name=="creator" then
			v:remove()
		end
	end
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=lastplr
	creator_tag.Name="creator"
	debris:AddItem(creator,3)
	creator_tag.Parent=humanoid
end

function checkintangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(sp.Parent) or hit.Transparency>.8 or string.lower(string.sub(hit.Name,1,6))=="effect" or hit.Name=="Handle" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" then
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

function recursive(item,cntrpos)
	if item~=nil and item.Parent~=nil then
		if item:IsA("BasePart") then
			if not item.Anchored and item:FindFirstChild("BlackHoleForce")==nil then
				if (item.Position-cntrpos).magnitude<effectradius then
					local bp=Instance.new("BodyPosition")
					bp.Name="BlackHoleForce"
					bp.position=cntrpos
					local massforce=item:GetMass()*force
					bp.maxForce=Vector3.new(massforce,massforce,massforce)
					bp.D=massforce*0
					bp.P=massforce*.05
					debris:AddItem(bp,.99)
					bp.Parent=item
				end
			end
		end
		for i,v in ipairs(item:GetChildren()) do
			recursive(v,cntrpos)
		end
	end
end

function makeblackhole(centerpos)
	if tick()-lastblackhole>=blackholeduration then
		lastblackhole=tick()
		local singularity=Instance.new("Part")
		singularity.Shape="Ball"
		singularity.Size=Vector3.new(1,1,1)--Vector3.new(eventhorizon*2,eventhorizon*2,eventhorizon*2)
		singularity.CanCollide=false
		singularity.Anchored=true
		singularity.Transparency=1
		singularity.Name="Singularity"
		singularity.BrickColor=BrickColor.new("Really black")
		singularity.CFrame=CFrame.new(centerpos)

		local bhgui=sp.BillboardGui:clone()
		bhgui.Size=UDim2.new(0,0,0,0)
		bhgui.ImageLabel.Visible=true
		bhgui.Parent=singularity

		local bsound=sp.Handle.SoundScript:clone()
		bsound.Parent=singularity
		bsound.Disabled=false

		singularity.Touched:connect(function(deadpart)
			if deadpart~=nil and deadpart.Parent~=nil then
				if not deadpart.Anchored then
					local h=deadpart.Parent:FindFirstChild("Humanoid")
					if h then
						tagHumanoid(h)
					end
					deadpart:remove()
				end
			end
		end)
		debris:AddItem(singularity,blackholeduration+3)
		singularity.Parent=game.Workspace

		bframes=1/rate
		for bframe=1,bframes do
			local bpercent=bframe/bframes
			bhgui.Size=UDim2.new(bpercent*eventhorizon*2,0,bpercent*eventhorizon*2,0)
			wait(rate)
		end

		for iw=1,blackholeduration/.25 do
			recursive(game.Workspace,centerpos)
			wait(.25)
		end

		bframes=.5/rate
		for bframe=1,bframes do
			local bpercent=1-(bframe/bframes)
			bhgui.Size=UDim2.new(bpercent*eventhorizon*2,0,bpercent*eventhorizon*2,0)
			wait(rate)
		end
	end
end

function drawbeam(beamstart,beamend,clr,fadedelay)
	local dist=(beamstart-beamend).magnitude
	local laser=Instance.new("Part")
	laser.Name="Laser"
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
	laser.BrickColor=clr
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

function fire(target)
	local he=sp.Parent:FindFirstChild("Head")
	local hu=sp.Parent:FindFirstChild("Humanoid")
	if check and he and hu and hu.Health>0 then
		check=false
		local startpos=he.Position
		local vec=(target-startpos).unit
		local hit,endpos=castray(startpos,vec,range,sp.Parent,false)
		sp.Handle.Sound:Play()
		if hit and hit~=nil then
			local h=hit.Parent:FindFirstChild("Humanoid")
			if h~=nil and h.Health>0 then
				if h.Health<=damage then		--Fun unique weapon effect time! :D
					delay(0,function()
						makeblackhole(endpos)
					end)
				end
				tagHumanoid(h)
				h:TakeDamage(damage)
			end
		end
		delay(0,function()	--This is nessecery to fire multible shots at the same time. For those who don't know, delay() is a poor man's coroutine.
			drawbeam((sp.Handle.CFrame*CFrame.new(barreloffset)).p,endpos,BrickColor.new("Really black"),.5)
		end)
		wait(firerate)
		check=true
	end
end

weaponevent.OnServerEvent:connect(function(plr,...)
	if plr then
		local tuple={...}
		if tuple[1]=="Fire" then
			if plr and tuple[2] then
				lastplr=plr
				fire(tuple[2])
			end
		end
	end
end)


