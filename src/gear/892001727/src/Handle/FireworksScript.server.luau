--Made by Stickmasterluke


--This code got messy quick. Forgive me


local sp=script.Parent


local launcher=sp
local debris=game:GetService("Debris")

local bang4=launcher:WaitForChild("Bang4")
local pop2=launcher:WaitForChild("Pop2")
local fountain=launcher:WaitForChild("Fountain")


local bangsounds={160248459,160248479,160248493}
function makerandombang()
	local bang=Instance.new("Sound")
	debris:AddItem(bang,10)
	bang.Volume=1
	bang.Pitch=.8+math.random()*.4
	bang.SoundId="http://www.roblox.com/asset/?id="..bangsounds[math.random(1,3)]
	return bang
end

local colors={"red","blue","white"}
function flare(pos,vel,floaty,timer,color)
	local floaty=floaty or 0
	local timer=timer or 2
	local p=Instance.new("Part")
	p.Name="EffectFlare"
	p.Transparency=1
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	p.formFactor="Custom"
	p.Size=Vector3.new(.4,.4,.4)
	p.CanCollide=false
	p.CFrame=CFrame.new(pos)*CFrame.Angles(math.pi,0,0)
	p.Velocity=vel
	
	local particles={}
	
	local s=Instance.new("Sparkles")
	s.SparkleColor=Color3.new(1,1,0)
	s.Parent=p
	table.insert(particles,s)
	local s2=Instance.new("Sparkles")
	s2.Parent=p
	table.insert(particles,s2)
	
	local s3=Instance.new("Sparkles")
	s3.SparkleColor=Color3.new(1,1,0)
	s3.Parent=p
	table.insert(particles,s3)
	local s4=Instance.new("Sparkles")
	s4.Parent=p
	table.insert(particles,s4)
	
	local f=Instance.new("Fire")
	f.Color=Color3.new(1,1,.5)
	f.SecondaryColor=Color3.new(1,1,1)
	f.Heat=25
	f.Parent=p
	table.insert(particles,f)
	
	if color=="red" then
		s.SparkleColor=Color3.new(1,0,0)
		s3.SparkleColor=Color3.new(1,0,0)
		f.Color=Color3.new(1,0,0)
	elseif color=="blue" then
		s.SparkleColor=Color3.new(0,0,1)
		s3.SparkleColor=Color3.new(0,0,1)
		f.Color=Color3.new(0,0,1)
	elseif color=="white" then
		s.SparkleColor=Color3.new(1,1,1)
		s3.SparkleColor=Color3.new(1,1,1)
		f.Color=Color3.new(1,1,1)
	end
	
	if floaty>0 then
		local bf=Instance.new("BodyForce")
		bf.force=Vector3.new(0,p:GetMass()*196.2*floaty,0)
		bf.Parent=p
	end
	debris:AddItem(p,timer+3)
	p.Parent=game.Workspace
	delay(timer,function()
		for _,v in pairs(particles) do
			if v and v.Parent and v.Enabled then
				v.Enabled=false
			end
		end
	end)
	
	return p
end

function fireclassic()
	for i=1,3 do
		delay(0,function()
			local clr=colors[math.random(1,#colors)]
			local b4c=bang4:clone()
			debris:AddItem(b4c,7)
			b4c.Parent=launcher
			local flare1=flare(launcher.Position,(CFrame.Angles(math.pi/2,0,0)*CFrame.Angles((math.random()-.5)*.5,(math.random()-.5)*.5,0)).lookVector*100,.8,2)
			flare1.RotVelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*100
			local b=makerandombang()
			b.Parent=flare1
			wait()
			if b4c then
				b4c:Play()
			end
			wait(2.5)
			if flare1 and b then
				b:Play()
				for i=1,7 do
					local f=flare(flare1.Position,(launcher.CFrame*CFrame.Angles((i/7)*math.pi*2,0,0)).lookVector*20,.95,3,clr)
					if i==7 then
						local s=Instance.new("Sound")
						s.Volume=1
						s.SoundId="http://www.roblox.com/asset/?id=160247625"
						s.Pitch=.5
						s.Parent=f
						wait()
						if s then
							s:Play()
						end
					end
				end
			end
		end)
		wait(.4)
	end
end

local clrcount=0
function firefan()
	fountain:Play()
	for i=1,7 do
		pop2:Play()
		clrcount=(clrcount+1)%(#colors)
		local f=flare(launcher.Position,(launcher.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles((((i-1)/6)-.5)*1.5,0,0)).lookVector*30,.95,2.,colors[clrcount+1])
		local s=Instance.new("Sound")
		s.Pitch=.5+(math.random()*.1)
		s.SoundId="http://www.roblox.com/asset/?id=160248604"
		s.Parent=f
		wait()
		if s then
			s:Play()
		end
		wait(.3)
	end
	wait(.3)
	for i=1,7 do
		pop2:Play()
		clrcount=(clrcount+1)%(#colors)
		local f=flare(launcher.Position,(launcher.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(((1-((i-1)/6))-.5)*1.5,0,0)).lookVector*30,.95,2,colors[clrcount+1])
		local s=Instance.new("Sound")
		s.Pitch=.5+(math.random()*.1)
		s.SoundId="http://www.roblox.com/asset/?id=160248604"
		s.Parent=f
		wait()
		if s then
			s:Play()
		end
		wait(.3)
	end
	fountain:Stop()
end

function firedisplay()
	bang4:Play()
	flare(launcher.Position,(launcher.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(.8,0,0)).lookVector*20,.95,2)
	flare(launcher.Position,(launcher.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(-.8,0,0)).lookVector*20,.95,2)
	wait(.5)
	bang4:Play()
	flare(launcher.Position,(launcher.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(.5,0,0)).lookVector*25,.95,2)
	flare(launcher.Position,(launcher.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(-.5,0,0)).lookVector*25,.95,2)
	wait(.5)
	bang4:Play()
	flare(launcher.Position,(launcher.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(.25,0,0)).lookVector*32,.95,2)
	flare(launcher.Position,(launcher.CFrame*CFrame.Angles(math.pi/2,0,0)*CFrame.Angles(-.25,0,0)).lookVector*32,.95,2)
	wait(1)
	bang4:Play()
	local flare1=flare(launcher.Position,Vector3.new(0,100,0),.8,1)
	local b=Instance.new("Sound")
	debris:AddItem(b,10)
	b.Volume=1
	b.SoundId="http://www.roblox.com/asset/?id=160248522"
	b.Parent=flare1
	wait(1)
	if flare1 and b then
		b:Play()
		for i=1,5 do
			clrcount=(clrcount+1)%(#colors)
			flare(flare1.Position,(launcher.CFrame*CFrame.Angles((i/5)*math.pi*2,0,0)).lookVector*20,.95,2,colors[clrcount+1])
		end
	end
end


wait(.1)
local fuse=Instance.new("Part")
fuse.Name="EffectFuse"
fuse.formFactor="Custom"
fuse.Size=Vector3.new(0,0,0)
fuse.Anchored=false
fuse.CanCollide=false
fuse.Transparency=1
local fusefire=Instance.new("Fire")
fusefire.Size=0
fusefire.Parent=fuse
fuse.Parent=sp
local w=Instance.new("Weld")
w.Part0=sp
w.Part1=fuse
w.C0=CFrame.new(-.3,-1.8,1.4)
w.Parent=sp

wait(7)

if fusefire then
	fusefire.Enabled=false
end
wait(2)
delay(0,firefan)
wait(4.5)
delay(0,firedisplay)
wait(4)
delay(0,firefan)
delay(4.5,firefan)
delay(9,firefan)
wait(7)
delay(0,fireclassic)
wait(7)
delay(0,fireclassic)
wait(1)
delay(0,fireclassic)
wait(2)
--delay(0,firefan)
delay(0,fireclassic)
wait(1)
delay(0,firedisplay)
wait(9)
sp:remove()


