--Made by Stickmasterluke

--Zombie artificial stupidity script
--(Modified for skeletons)

sp=script.Parent
lastattack=0
nextrandom=0
--nextsound=0
nextjump=0
chasing=false

variance=4

damage=11
attackrange=4.5
sightrange=60
runspeed=18
wonderspeed=8
healthregen=false
--colors={"Sand red","Dusty Rose","Medium blue","Sand blue","Lavender","Earth green","Brown","Medium stone grey","Brick yellow"}
colors={"White"}

function raycast(spos,vec,currentdist)
	local hit2,pos2=game.Workspace:FindPartOnRay(Ray.new(spos+(vec*.01),vec*currentdist),sp)
	if hit2~=nil and pos2 then
		if hit2.Transparency>=.8 or hit2.Name=="Handle" or string.sub(hit2.Name,1,6)=="Effect" then
			local currentdist=currentdist-(pos2-spos).magnitude
			return raycast(pos2,vec,currentdist)
		end
	end
	return hit2,pos2
end

function waitForChild(parent,childName)
	local child=parent:findFirstChild(childName)
	if child then return child end
	while true do
		child=parent.ChildAdded:wait()
		if child.Name==childName then return child end
	end
end

-- ANIMATION

-- declarations

local Torso=waitForChild(sp,"Torso")
local Head=waitForChild(sp,"Head")
local RightShoulder=waitForChild(Torso,"Right Shoulder")
local LeftShoulder=waitForChild(Torso,"Left Shoulder")
local RightHip=waitForChild(Torso,"Right Hip")
local LeftHip=waitForChild(Torso,"Left Hip")
local Neck=waitForChild(Torso,"Neck")
local Humanoid=waitForChild(sp,"Humanoid")
local BodyColors=waitForChild(sp,"Body Colors")
local pose="Standing"
--local hitsound=waitForChild(Torso,"HitSound")
--[[
local sounds={
	waitForChild(Torso,"GroanSound"),
	waitForChild(Torso,"RawrSound")
}
--]]
if healthregen then
	local regenscript=waitForChild(sp,"HealthRegenerationScript")
	regenscript.Disabled=false
end
Humanoid.WalkSpeed=wonderspeed

local toolAnim="None"
local toolAnimTime=0

BodyColors.HeadColor=BrickColor.new("Grime")
local randomcolor1=colors[math.random(1,#colors)]
BodyColors.TorsoColor=BrickColor.new(randomcolor1)
BodyColors.LeftArmColor=BrickColor.new(randomcolor1)
BodyColors.RightArmColor=BrickColor.new(randomcolor1)
local randomcolor2=colors[math.random(1,#colors)]
BodyColors.LeftLegColor=BrickColor.new(randomcolor2)
BodyColors.RightLegColor=BrickColor.new(randomcolor2)


function onRunning(speed)
	if speed>0 then
		pose="Running"
	else
		pose="Standing"
	end
end
function onDied()
	pose="Dead"
end
function onJumping()
	pose="Jumping"
end
function onClimbing()
	pose="Climbing"
end
function onGettingUp()
	pose = "GettingUp"
end
function onFreeFall()
	pose = "FreeFall"
end
function onFallingDown()
	pose = "FallingDown"
end
function onSeated()
	pose = "Seated"
end
function onPlatformStanding()
	pose = "PlatformStanding"
end

function moveJump()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
  RightShoulder.DesiredAngle=3.14
	LeftShoulder.DesiredAngle=-3.14
	RightHip.DesiredAngle=0
	LeftHip.DesiredAngle=0
end

function moveFreeFall()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity =0.5
	RightShoulder.DesiredAngle=3.14
	LeftShoulder.DesiredAngle=-3.14
	RightHip.DesiredAngle=0
	LeftHip.DesiredAngle=0
end

function moveSit()
	RightShoulder.MaxVelocity = 0.15
	LeftShoulder.MaxVelocity = 0.15
	RightShoulder.DesiredAngle=3.14 /2
	LeftShoulder.DesiredAngle=-3.14 /2
	RightHip.DesiredAngle=3.14 /2
	LeftHip.DesiredAngle=-3.14 /2
end

function animate(time)
	local amplitude
	local frequency
	if (pose == "Jumping") then
		moveJump()
		return
	end
	if (pose == "FreeFall") then
		moveFreeFall()
		return
	end
	if (pose == "Seated") then
		moveSit()
		return
	end
	local climbFudge = 0
	if (pose == "Running") then
		RightShoulder.MaxVelocity = 0.15
		LeftShoulder.MaxVelocity = 0.15
		amplitude = 1
		frequency = 9
	elseif (pose == "Climbing") then
		RightShoulder.MaxVelocity = 0.5 
		LeftShoulder.MaxVelocity = 0.5
		amplitude = 1
		frequency = 9
		climbFudge = 3.14
	else
		amplitude = 0.1
		frequency = 1
	end
	desiredAngle = amplitude * math.sin(time*frequency)
	if not chasing and frequency==9 then
		frequency=4
	end
	if chasing then
		RightShoulder.DesiredAngle=math.pi/2
		LeftShoulder.DesiredAngle=-math.pi/2
		RightHip.DesiredAngle=-desiredAngle*2
		LeftHip.DesiredAngle=-desiredAngle*2
	else
		RightShoulder.DesiredAngle=desiredAngle + climbFudge
		LeftShoulder.DesiredAngle=desiredAngle - climbFudge
		RightHip.DesiredAngle=-desiredAngle
		LeftHip.DesiredAngle=-desiredAngle
	end
end


function attack(time,attackpos)
	if time-lastattack>=1 then
		local hit,pos=raycast(Torso.Position,(attackpos-Torso.Position).unit,attackrange)
		if hit and hit.Parent~=nil and hit.Parent.Name~=sp.Name then
			local h=hit.Parent:FindFirstChild("Humanoid")
			if h then
				local creator=sp:FindFirstChild("creator")
				if creator then
					if creator.Value~=nil then
						if creator.Value~=game.Players:GetPlayerFromCharacter(h.Parent) then
							for i,oldtag in ipairs(h:GetChildren()) do
								if oldtag.Name=="creator" then
									oldtag:remove()
								end
							end
							creator:clone().Parent=h
						else
							return
						end
					end
				end
				h:TakeDamage(damage)
--[[
				hitsound.Volume=.5+(.5*math.random())
				hitsound.Pitch=.5+math.random()
				hitsound:Play()
--]]
				if RightShoulder and LeftShoulder then
					RightShoulder.CurrentAngle=0
					LeftShoulder.CurrentAngle=0
				end
			end
		end
		lastattack=time
	end
end


Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.Climbing:connect(onClimbing)
Humanoid.GettingUp:connect(onGettingUp)
Humanoid.FreeFalling:connect(onFreeFall)
Humanoid.FallingDown:connect(onFallingDown)
Humanoid.Seated:connect(onSeated)
Humanoid.PlatformStanding:connect(onPlatformStanding)


function populatehumanoids(mdl)
	if mdl.ClassName=="Humanoid" then
		table.insert(humanoids,mdl)
	end
	for i2,mdl2 in ipairs(mdl:GetChildren()) do
		populatehumanoids(mdl2)
	end
end
--[[
function playsound(time)
	nextsound=time+5+(math.random()*5)
	local randomsound=sounds[math.random(1,#sounds)]
	randomsound.Volume=.5+(.5*math.random())
	randomsound.Pitch=.5+(.5*math.random())
	randomsound:Play()
end
--]]
while sp.Parent~=nil and Humanoid and Humanoid.Parent~=nil and Humanoid.Health>0 and Torso and Head and Torso~=nil and Torso.Parent~=nil do
	local _,time=wait(1/3)
	humanoids={}
	populatehumanoids(game.Workspace)
	closesttarget=nil
	closestdist=sightrange
	local creator=sp:FindFirstChild("creator")
	for i,h in ipairs(humanoids) do
		if h and h.Parent~=nil then
			if h.Health>0 and h.Parent.Name~=sp.Name and h.Parent~=sp then
				local plr=game.Players:GetPlayerFromCharacter(h.Parent)
				if creator==nil or plr==nil or creator.Value~=plr then
					local t=h.Parent:FindFirstChild("Torso")
					if t~=nil then
						local dist=(t.Position-Torso.Position).magnitude
						if dist<closestdist then
							closestdist=dist
							closesttarget=t
						end
					end
				end
			end
		end
	end
	if closesttarget~=nil then
		if not chasing then
			--playsound(time)
			chasing=true
			Humanoid.WalkSpeed=runspeed
		end
		Humanoid:MoveTo(closesttarget.Position+(Vector3.new(1,1,1)*(variance*((math.random()*2)-1))),closesttarget)
		if math.random()<.5 then
			attack(time,closesttarget.Position)
		end
	else
		if chasing then
			chasing=false
			Humanoid.WalkSpeed=wonderspeed
		end
		if time>nextrandom then
			nextrandom=time+3+(math.random()*5)
			local randompos=Torso.Position+((Vector3.new(1,1,1)*math.random()-Vector3.new(.5,.5,.5))*40)
			Humanoid:MoveTo(randompos,game.Workspace.Terrain)
		end
	end
--[[
	if time>nextsound then
		playsound(time)
	end
--]]
	if time>nextjump then
		nextjump=time+7+(math.random()*5)
		Humanoid.Jump=true
	end
	animate(time)
end

wait(4)
sp:remove() --Rest In Pizza
