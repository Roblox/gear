--Stickmasterluke


sp=script.Parent


local debris=game:GetService("Debris")
clrcount=0
local explotype=math.random(1,3)


--163373035 Neat texture
--163373470 Neat texture x2
--163372452 Desired Texture


local colors={"red","orange","yellow","green","blue","purple"}
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
	elseif color=="green" then
		s.SparkleColor=Color3.new(0,1,0)
		s3.SparkleColor=Color3.new(0,1,0)
		f.Color=Color3.new(0,1,0)
	elseif color=="yellow" then
		s.SparkleColor=Color3.new(1,1,0)
		s3.SparkleColor=Color3.new(1,1,0)
		f.Color=Color3.new(1,1,0)
	elseif color=="purple" then
		s.SparkleColor=Color3.new(1,0,1)
		s3.SparkleColor=Color3.new(1,0,1)
		f.Color=Color3.new(1,0,1)
	elseif color=="orange" then
		s.SparkleColor=Color3.new(1,.5,0)
		s3.SparkleColor=Color3.new(1,.5,0)
		f.Color=Color3.new(1,.5,0)
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

debris:AddItem(sp,20)
local bt=Instance.new("BodyThrust")
bt.force=Vector3.new(0,sp:GetMass()*196.2*1.5,0)
if explotype==3 then
	bt.force=Vector3.new(0,sp:GetMass()*196.2*1.25,0)
end
bt.Parent=sp
local f=Instance.new("Fire")
f.Parent=sp
sp.RotVelocity=Vector3.new(0,0,0)
sp.Velocity=Vector3.new(0,0,0)
sp.CFrame=CFrame.new(sp.Position)
sp.CanCollide=false
sp.Fountain:Play()
wait(.25)
sp.CanCollide=true
if explotype==3 then
	wait(.25)
	for i=1,24 do
		wait(.12)
		sp.Pop2:Play()
		flare(sp.Position,(sp.CFrame*CFrame.Angles(0,((i%9)/9)*math.pi*2,0)).lookVector*20+sp.Velocity,.8,2,clr)
	end
else
	wait(1.5)
end
f.Enabled=false
sp.CanCollide=false
sp.Anchored=true
sp.Transparency=1


if explotype==1 then
	sp.Bang4:Play()
	sp.Pop2:Play()
	for i=1,14 do
		clrcount=(clrcount+1)%(#colors)
		flare(sp.Position,(sp.CFrame*CFrame.Angles(math.pi*2*math.random(),math.pi*2*math.random(),math.pi*2*math.random())).lookVector*20,.95,2,colors[clrcount+1])
	end
elseif explotype==2 then
	sp.Bang4:Play()
	sp.Pop2:Play()
	local clr=colors[math.random(1,#colors)]
	local ocf=sp.CFrame*CFrame.Angles(math.random()*math.pi*2,math.random()*math.pi*2,math.random()*math.pi*2)
	for i=1,7 do
		flare(sp.Position,(ocf*CFrame.Angles(i/7*math.pi*2,.75,0)).lookVector*20,.95,2,clr)
	end
	local clr=colors[math.random(1,#colors)]
	for i=1,7 do
		flare(sp.Position,(ocf*CFrame.Angles(i/7*math.pi*2,-.75,0)).lookVector*20,.95,2,clr)
	end
elseif explotype==3 then
	flare(sp.Position,sp.Velocity,.8,2,clr)
end
sp.Fountain:Stop()
wait(10)
sp:remove()


