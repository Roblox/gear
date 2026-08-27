--Stickmasterluke


sp=script.Parent


anims={"RightSlash","LeftSlash"}
basedamage=2
slashdamage=8
specialprice=16
phi=.618033988
damage=basedamage
lastclick=0
specialdebounce=true


handle=sp:WaitForChild("Handle")
mesh=handle:WaitForChild("Mesh")
specialsound=handle:FindFirstChild("SpecialSound")
slashSound=handle:WaitForChild("SwingSound")
energy=sp:WaitForChild("Energy")
currentattack=sp:WaitForChild("CurrentAttack")
sp:WaitForChild("RunAnim")
debris=game:GetService("Debris")
r=game:service("RunService")




function lunge()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = sp
end

function blow(hit)
	if hit.Parent~=nil then
		local humanoid=hit.Parent:findFirstChild("Humanoid")
		local vCharacter=sp.Parent
		if vCharacter~=nil then
			local vPlayer=game.Players:playerFromCharacter(vCharacter)
			if vPlayer~=nil then
				local hum=vCharacter:findFirstChild("Humanoid")
				if humanoid~=nil then
					if hum~=nil and humanoid~=hum then
						local right_arm=vCharacter:FindFirstChild("Right Arm")
						if right_arm~=nil then
							local joint=right_arm:FindFirstChild("RightGrip")
							if joint~=nil and (joint.Part0==handle or joint.Part1==handle) then
								tagHumanoid(humanoid,vPlayer)
								humanoid:TakeDamage(damage)
							end
						end
					end
				end
			end
		end
	end
end


function tagHumanoid(humanoid,player)
	for i,v in ipairs(humanoid:GetChildren()) do
		if v.Name=="creator" then
			v:remove()
		end
	end
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=player
	creator_tag.Name="creator"
	creator_tag.Parent=humanoid
	debris:AddItem(creator_tag,1)
end

function lunge()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Lunge"
	anim.Parent = sp
end

function tween(thing,value,startv,endv,timev,ratev)
	local timev=timev or 1
	local ratev=ratev or 1/30
	if thing and value and startv and endv then
		local frames=math.floor(timev/ratev)
		local difv
		if value=="CFrame" then
			difv=(endv.p-startv.p)
		else
			difv=(endv-startv)
		end
		for frame=1,frames do
			if not thing then
				break
			end
			thing[value]=startv+difv*(frame/frames)
			wait(ratev)
		end
	end
end


function spawnstick(cframe,lifetime,scale,sdamage)
	local cframe=cframe or CFrame.new()
	local sdamage=sdamage or 16
	local scale=scale or Vector3.new(1,1,1)
	local lifetime=lifetime or 6
	local p=Instance.new("Part")
	p.Name="Stick"
	p.Anchored=true
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	p.BrickColor=BrickColor.new("Brown")
	p.formFactor="Custom"
	p.Size=handle.Size*scale
	local m=Instance.new("SpecialMesh")
	m.MeshId="http://www.roblox.com/asset/?id=123968188"
	m.TextureId="http://www.roblox.com/asset/?id=123968836"
	m.Scale=mesh.Scale*scale
	m.VertexColor=Vector3.new(1,1,1)*(.5+(math.random()*.5))
	m.Parent=p
	debris:AddItem(p,lifetime)
	local dealt=false
	p.Touched:connect(function(hit)
		if hit and hit.Parent then
			local h=hit.Parent:FindFirstChild("Humanoid")
			if h and hit.Parent~=sp.Parent and h.Health>0 and not dealt then
				dealt=true
				local chr=sp.Parent
				if chr~=nil then
					local plr=game.Players:playerFromCharacter(chr)
					if plr then
						tagHumanoid(h,plr)
					end
				end
				h:TakeDamage(sdamage)
			end
		end
	end)
	p.CFrame=cframe
	p.Parent=game.Workspace
	return p
end


magics={
	Wave=function(t)
		specialsound:stop()
		specialsound.Pitch=1
		specialsound:play()
		for i=1,16 do
			local sscf=CFrame.new(t.Position,t.Position+t.CFrame.lookVector*Vector3.new(1,0,1))*CFrame.new(0,-6.5,-((i*3)+5))*CFrame.Angles(0,math.pi*2*math.random(),0)
			local sscf2=sscf*CFrame.new(0,5,0)
			delay((i-1)*.1,function()
				local stick=spawnstick(sscf,4,nil,24)
				tween(stick,"CFrame",sscf,sscf2,.1)
				wait(.2)
				tween(stick,"CFrame",sscf2,sscf,.25)
			end)
		end
		wait(.5)
	end,
	Forest=function(t)
		specialsound:stop()
		specialsound.Pitch=1
		specialsound:play()
		for i=1,22 do
			local sscf=CFrame.new(t.Position)*CFrame.Angles(0,math.pi*2*(i/22),0)*CFrame.new(0,-8,10)*CFrame.Angles(0,math.pi*2*math.random(),0)*CFrame.Angles(math.random()-.5,0,math.random()-.5)
			local sscf2=sscf*CFrame.new(0,10,0)
			delay((i%phi)*2,function()
				local stick=spawnstick(sscf,8,Vector3.new(2,2,2))
				tween(stick,"CFrame",sscf,sscf2,.1)
				wait(5)
				tween(stick,"CFrame",sscf2,sscf,1)
				if stick then
					stick:remove()
				end
			end)
		end
		wait(3)
	end,
	Fort=function(t)
		specialsound:stop()
		specialsound.Pitch=1
		specialsound:play()
		for i=1,22 do
			local myphi=(i%phi)*(1+phi)
			local sscf=CFrame.new(t.Position)*CFrame.Angles(0,math.pi*2*(i/22),0)*CFrame.new(0,-8,1+((1-myphi)*4))*CFrame.Angles(.5,math.pi*2*math.random(),0)
			local sscf2=sscf*CFrame.new(0,5+((1-myphi)*5),0)
			delay(0,function()
				local stick=spawnstick(sscf,8,Vector3.new(2,2,2))
				tween(stick,"CFrame",sscf,sscf2,.1+(myphi*.5))
				wait(3+(1-myphi)*1)
				tween(stick,"CFrame",sscf2,sscf,2-myphi)
				if stick then
					stick:remove()
				end
			end)
		end
		wait(4)
	end,
	Lift=function(t)
		specialsound:stop()
		specialsound.Pitch=1
		specialsound:play()
		delay(0,function()
			local tscf=CFrame.new(t.Position)*CFrame.new(0,-(3+(handle.Size.y*5*.5)),0)*CFrame.Angles(0,math.pi*2*math.random(),0)
			local tscf2=tscf*CFrame.new(0,handle.Size.y*4.8,0)
			local trunk=spawnstick(tscf,20,Vector3.new(7,5,7))
			trunk.Velocity=Vector3.new(0,30/5,0)
			tween(trunk,"CFrame",tscf,tscf2,5)
			trunk.Velocity=Vector3.new(0,0,0)
			wait(5)
			tween(trunk,"CFrame",tscf2,tscf,2)
		end)
		wait(1)
	end,
	Strike=function(t)
		specialsound:stop()
		specialsound.Pitch=1
		specialsound:play()
		local targetcf=CFrame.new(t.Position,t.Position+t.CFrame.lookVector*Vector3.new(1,0,1))*CFrame.new(0,-3,-15)
		for i=1,8 do
			local myphi=(i%phi)*(1+phi)
			delay(0,function()
				local stick=spawnstick(nil,5,Vector3.new(2,.2+((1-myphi)*3),2),22)
				local sscf=targetcf*CFrame.Angles(0,math.random()*math.pi*2,.2*myphi)*CFrame.new(myphi*2,-stick.Size.y*.6,0)*CFrame.Angles(0,math.random()*math.pi*2,0)
				local sscf2=sscf*CFrame.new(0,stick.Size.y,0)
				stick.Velocity=Vector3.new(0,100,0)
				stick.CFrame=sscf
				tween(stick,"CFrame",sscf,sscf2,.25)
				wait(1)
				stick.Velocity=Vector3.new(0,0,0)
				wait(1)
				tween(stick,"CFrame",sscf2,sscf,2)
				if stick then
					stick:remove()
				end
			end)
		end
		wait(1)
	end,
	Blast=function(t)
		specialsound:stop()
		specialsound.Pitch=1
		specialsound:play()
		local targetcf=CFrame.new(t.Position,t.Position+t.CFrame.lookVector*Vector3.new(1,0,1))*CFrame.new(0,-3,-10)
		for i=1,10 do
			local myphi=(i%phi)*(1+phi)
			delay(0,function()
				local stick=spawnstick(nil,8,Vector3.new(2,.2+((1-myphi)*3),2),14)
				local sscf=targetcf*CFrame.Angles(0,math.random()*math.pi*2,-.7*myphi)*CFrame.new(0,-stick.Size.y*.5,0)*CFrame.Angles(0,math.random()*math.pi*2,0)
				local sscf2=sscf*CFrame.new(0,stick.Size.y,0)
				stick.Velocity=Vector3.new(0,100,0)
				stick.CFrame=sscf
				tween(stick,"CFrame",sscf,sscf2,.25)
				stick.Velocity=Vector3.new(0,0,0)
				wait(1)
				stick.Velocity=Vector3.new(0,0,0)
				wait(1)
				tween(stick,"CFrame",sscf2,sscf,2)
				if stick then
					stick:remove()
				end
			end)
		end
		wait(2)
	end,
}

sp.Enabled=true
function onActivated()
	delay(.01,function()
		lastclick=tick()
	end)
	if sp.Enabled then
		sp.Enabled=false
		local character=sp.Parent;
		local humanoid=character.Humanoid
		if humanoid==nil then
			print("Humanoid not found")
			return 
		end
		if (tick()-lastclick)<.2 and energy.Value>specialprice and specialdebounce then
			slashSound.Volume=1
			slashSound:play()
			lunge()
			damage=0
			local t=sp.Parent:FindFirstChild("Torso")
			sp.RunAnim.Value="OverHeadSwing"
			if t~=nil then
				energy.Value=energy.Value-specialprice
				delay(0,function()
					specialdebounce=false
					magics[currentattack.Value](t)
					specialsound:stop()
					specialdebounce=true
				end)
			end
			wait(1)
			sp.RunAnim.Value=""
		else
			slashSound.Volume=.7
			slashSound:play()
			newanim=anims[math.random(1,#anims)]
			while newanim==sp.RunAnim.Value do
				newanim=anims[math.random(1,#anims)]
			end
			sp.RunAnim.Value=newanim
			damage=slashdamage
			wait(.5)
			sp.RunAnim.Value=""
		end
		damage=basedamage
		sp.Enabled=true
	end
end

function onEquipped()
	equipped=true
end
function onUnequipped()
	equipped=false
end

sp.Activated:connect(onActivated)
sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

connection=handle.Touched:connect(blow)

while true do
	if equipped then
		energy.Value=math.min(100,energy.Value+1)
	end
	wait(.3)
end


