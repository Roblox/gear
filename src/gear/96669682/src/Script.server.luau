--Made by Stickmasterluke


sp=script.Parent


damage=20						--  +/- 10%
damagewindow=1					--after clicking, how long does the player have to hit the opponent wioth their weapon to deal damage
swingrate=.75

clashsounds={91154405,91154446,91154471,91154503,91154521}
swooshsounds={91154708,91155889}
hitsounds={91154909,91154932,91154954}
anims={"Stab1","Stab2","LeftSlash"}



ready=false
equipped=false
rate=1/30
lastswing=0


function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

reloading=waitfor(sp,"Reloading")
down=waitfor(sp,"MouseDown")
runanim=waitfor(sp,"RunAnim")
sparkles=waitfor(sp.Handle,"Sparkles")
debris=game:getService("Debris")
weaponhud=waitfor(sp,"WeaponHud")
weaponnametag=waitfor(weaponhud,"WeaponName")
guibar=waitfor(weaponhud,"Bar")
guibarfill=waitfor(guibar,"Fill")
weaponnametag.Text=sp.Name

function runsound(id,volume)
	local volume=volume or 1
	local sound=Instance.new("Sound")
	sound.Looped=false
	sound.Pitch=1
	sound.SoundId="http://www.roblox.com/asset/?id="..tostring(id)
	sound.PlayOnRemove=false
	sound.Volume=volume
	debris:AddItem(sound,3)
	sound.Parent=sp.Handle
	wait()
	sound:Play()
end

function billboard(pos,text,time,color)
	local pos=pos or Vector3.new(0,0,0)
	local text=text or "Hello World!"
	local time=time or 2
	local color=color or Color3.new(1,0,0)
	local pos=pos+Vector3.new(0,5,0)
	local ep=Instance.new("Part")
	ep.Name="Effect"
	ep.formFactor="Custom"
	ep.Size=Vector3.new(0,0,0)
	ep.TopSurface="Smooth"
	ep.BottomSurface="Smooth"
	ep.CFrame=CFrame.new(pos)
	ep.Anchored=true
	ep.CanCollide=false
	ep.Transparency=1
	local bb=Instance.new("BillboardGui")
	bb.Size=UDim2.new(3,0,3,0)
	bb.Adornee=ep
	local tl=Instance.new("TextLabel")
	tl.BackgroundTransparency=1
	tl.Size=UDim2.new(1,0,1,0)
	tl.Text=text
	tl.TextColor3=color
	tl.TextScaled=true
	tl.Font="ArialBold"

	tl.Parent=bb
	bb.Parent=ep
	debris:AddItem(ep,time+.1)
	ep.Parent=game.Workspace
	delay(0,function()
		local frames=time/rate
		for frame=1,frames do
			wait(rate)
			local percent=frame/frames
			ep.CFrame=CFrame.new(pos)+Vector3.new(0,5*percent,0)
			tl.TextTransparency=percent
		end
		ep:remove()
	end)
end

function makeblood(part)
	--[[
	if part then
		local b=Instance.new("Part")
		b.BrickColor=BrickColor.new("Bright red")
		b.formFactor="Custom"
		b.Transparency=math.random(0,1)*.5
		if math.random()<.5 then
			b.CanCollide=false
		else
			b.CanCollide=true
		end
		b.TopSurface="Smooth"
		b.BottomSurface="Smooth"
		b.Size=Vector3.new(.2*math.random(1,5),.2*math.random(1,5),.2*math.random(1,5))
		b.Velocity=part.Velocity+(Vector3.new((math.random()-.5),(math.random()-.5),(math.random()-.5))*30)
		b.RotVelocity=part.RotVelocity+(Vector3.new((math.random()-.5),(math.random()-.5),(math.random()-.5))*20)
		b.CFrame=part.CFrame*CFrame.new((math.random()-.5)*3,(math.random()-.5)*3,(math.random()-.5)*3)*CFrame.Angles(math.pi*2*math.random(),math.pi*2*math.random(),math.pi*2*math.random())
		debris:AddItem(b,math.random()*4)
		b.Parent=game.Workspace
	end
	--]]
end

sp.Handle.Touched:connect(function(hit)
	if ready and equipped and hit and hit.Parent~=nil and hit:IsDescendantOf(sp.Parent)==false and string.lower(string.sub(hit.Name,1,6))~="effect" and (tick()-lastswing)<=damagewindow then
		if hit:FindFirstChild("CanBlock") and sp.Handle:FindFirstChild("Blockable") then
			ready=false
			runsound(clashsounds[math.random(1,#clashsounds)])
			sparkles.Enabled=true
			delay(.2,function()
				sparkles.Enabled=false
			end)
			billboard(sp.Handle.Position,"Block",2,Color3.new(1,1,0))
		end
		local mh=sp.Parent:FindFirstChild("Humanoid")
		local eh=hit.Parent:FindFirstChild("Humanoid")
		local ra=sp.Parent:FindFirstChild("Right Arm")
		local plr=game.Players:GetPlayerFromCharacter(sp.Parent)
		if mh and eh and eh~=mh and mh.Health>0 and eh.Health>0 and ra and plr~=nil then
			if not plr.Neutral then
				local eplr=game.Players:GetPlayerFromCharacter(eh.Parent)
				if eplr~=nil and eplr.Neutral==false and eplr.TeamColor==plr.TeamColor then
					return	--No team killing
				end
			end
			ready=false
			for i,v in ipairs(eh:GetChildren()) do
				if v.Name=="creator" then
					v:remove()
				end
			end
			local creator=Instance.new("ObjectValue")
			creator.Name="creator"
			creator.Value=plr
			creator.Parent=eh
			debris:AddItem(creator,1)
			local localdamage=math.floor(damage*(.9+(math.random()*.2)))
			eh:TakeDamage(localdamage)
			billboard(hit.Position,"-"..tostring(localdamage))
			runsound(hitsounds[math.random(1,#hitsounds)])
			local bloodeffects=math.ceil(localdamage/10)
			for i=1,math.random(bloodeffects-1,bloodeffects+1) do
				--[[if math.random()<.5 then
					makeblood(sp.Handle)
				else]]
					makeblood(hit)
				--end
			end
		end
	end
end)


function Activate()
	if equipped and (tick()-lastswing)>=swingrate then
		ready=true
		reloading.Value=true

		runsound(swooshsounds[math.random(1,#swooshsounds)],.5)

		newanim=anims[math.random(1,#anims)]
		while newanim==runanim.Value do
			newanim=anims[math.random(1,#anims)]
		end
		runanim.Value=newanim

		lastswing=tick()
		updategui()

		wait(swingrate)

		reloading.Value=false
		if down.Value then
			Activate()
		end
	end
end

down.Changed:connect(function()
	if down.Value then
		Activate()
	end
end)

function updategui()
	local swingpercent=math.min((tick()-lastswing)/swingrate,1)
	if swingpercent<.5 then	--fade from red to yellow then to green
		guibarfill.BackgroundColor3=Color3.new(1,swingpercent*2,0)
	else
		guibarfill.BackgroundColor3=Color3.new(1-((swingpercent-.5)/.5),1,0)
	end
	guibarfill.Size=UDim2.new(swingpercent,0,1,0)
end

sp.Equipped:connect(function(mouse)
	lastswing=tick()
	updategui()

	reloading.Value=true
	ready=false
	equipped=true

	delay(0,function()		--HAAB (Hacking around a bug)
		local plr=game.Players:GetPlayerFromCharacter(sp.Parent)
		if plr~=nil then
			local plrgui=plr:FindFirstChild("PlayerGui")
			if plrgui~=nil and weaponhud~=nil then
				weaponhud.Parent=plrgui
				while equipped do
					updategui()
					wait(rate)
				end
			end
		end
	end)

	wait(swingrate)

	reloading.Value=false
	if down.Value then
		Activate()
	end
end)

sp.Unequipped:connect(function()
	ready=false
	equipped=false
	delay(0,function()	--HAAB
		weaponhud.Parent=sp
	end)
end)







