zombieParent = false

while zombieParent == false do

	wait(0.5)
	if script.Parent.Name == "SummonedZombie" then
		zombieParent = true
	end

end

model = script.Parent
backup = model:Clone()
regentime = 1 --5 minutes

------------------
--SPAWNING--
------------------
miked=script.Parent

itlh=miked.Torso:findFirstChild("Left Hip")
itlh.Part0=miked.Torso
itlh.Part1=miked:findFirstChild("Left Leg")
itlh.C0=CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)

itrh=miked.Torso:findFirstChild("Right Hip")
itrh.Part0=miked.Torso
itrh.Part1=miked:findFirstChild("Right Leg")
itrh.C0=CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)

itls=miked.Torso:findFirstChild("Left Shoulder")
itls.Part1=miked.Torso
itls.C0=CFrame.new(2, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
itls.Part0=miked:findFirstChild("Left Arm")

itrs=miked.Torso:findFirstChild("Right Shoulder")
itrs.Part1=miked.Torso
itrs.C0=CFrame.new(-2, 0.5, 0, 0, 0, 1, 0, -1, 0, 1, 0, 0)
itrs.Part0=miked:findFirstChild("Right Arm")

miked.Head:makeJoints()

wait(3)
miked:findFirstChild("Left Arm").Anchored = false
miked:findFirstChild("Right Arm").Anchored = false
------------------
------------------


function waitForChild(parent, childName)
	while true do
		local child = parent:findFirstChild(childName)
		if child then
			return child
		end
		parent.ChildAdded:wait()
	end
end

local Figure = script.Parent
local Torso = waitForChild(Figure, "Torso")
local RightShoulder = waitForChild(Torso, "Right Shoulder")
local LeftShoulder = waitForChild(Torso, "Left Shoulder")
local RightHip = waitForChild(Torso, "Right Hip")
local LeftHip = waitForChild(Torso, "Left Hip")
local Neck = waitForChild(Torso, "Neck")
local Humanoid = waitForChild(Figure, "Zombie")
local pose = "Standing"

local toolAnim = "None"
local toolAnimTime = 0

local isSeated = false


function onRunning(speed)
	if isSeated then return end

	if speed>0 then
		pose = "Running"
	else
		pose = "Standing"
	end
end

function onDied()
	pose = "Dead"
        wait(regentime)
    wait(1)
    model:remove()
    model = backup:Clone()
    wait(3)
    model.Parent = game.Workspace
    model:MakeJoints()
end

function onJumping()
	isSeated = false
	pose = "Jumping"
end

function onClimbing()
	pose = "Climbing"
end

function onGettingUp()
	pose = "GettingUp"
end

function onFreeFall()
	pose = "FreeFall"
end

function onDancing()
	pose = "Dancing"
end

function onFallingDown()
	pose = "FallingDown"
end

function onSeated()
	isSeated = true
	pose = "Seated"
end



function moveJump()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -3.14
	LeftShoulder.DesiredAngle = -3.14
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
end

function moveFreeFall()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -1
	LeftShoulder.DesiredAngle = -1
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
end

function moveFloat()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -1.57
	LeftShoulder.DesiredAngle = 1.57
	RightHip.DesiredAngle = 1.57
	LeftHip.DesiredAngle = -1.57
end

function moveBoogy()
while pose=="Boogy" do
	wait(.5)
	RightShoulder.MaxVelocity = 1
	LeftShoulder.MaxVelocity = 1
	RightShoulder.DesiredAngle = -3.14
	LeftShoulder.DesiredAngle = 0
	RightHip.DesiredAngle = 1.57
	LeftHip.DesiredAngle = 0
	wait(.5)
	RightShoulder.MaxVelocity = 1
	LeftShoulder.MaxVelocity = 1
	RightShoulder.DesiredAngle = 0
	LeftShoulder.DesiredAngle = -3.14
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 1.57
end
end

function moveZombie()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -1.57
	LeftShoulder.DesiredAngle = 1.57
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
end

function movePunch()
	script.Parent.Torso.Anchored=true
	RightShoulder.MaxVelocity = 60
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -1.57
	LeftShoulder.DesiredAngle = 0
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
wait(1)
script.Parent.Torso.Anchored=false
pose="Standing"

end

function moveKick()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 0
	LeftShoulder.DesiredAngle = 0
	RightHip.MaxVelocity = 40
	RightHip.DesiredAngle = 1.57
	LeftHip.DesiredAngle = 0
wait(1)
pose="Standing"

end

function moveFly()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = 0
	LeftShoulder.DesiredAngle = 0
	RightHip.MaxVelocity = 40
	RightHip.DesiredAngle = 1.57
	LeftHip.DesiredAngle = 0
wait(1)
pose="Standing"

end


function moveClimb()
	RightShoulder.MaxVelocity = 0.5
	LeftShoulder.MaxVelocity = 0.5
	RightShoulder.DesiredAngle = -3.14
	LeftShoulder.DesiredAngle = 3.14
	RightHip.DesiredAngle = 0
	LeftHip.DesiredAngle = 0
end

function moveSit()
	RightShoulder.MaxVelocity = 0.15
	LeftShoulder.MaxVelocity = 0.15
	RightShoulder.DesiredAngle = -3.14 /2
	LeftShoulder.DesiredAngle = -3.14 /2
	RightHip.DesiredAngle = 3.14 /2
	LeftHip.DesiredAngle = -3.14 /2
end

function getTool()
	
	kidTable = Figure:children()
	if (kidTable ~= nil) then
		numKids = #kidTable
		for i=1,numKids do
			if (kidTable[i].className == "Tool") then return kidTable[i] end
		end
	end
	
	return nil
end

function getToolAnim(tool)

	c = tool:children()
	for i=1,#c do
		if (c[i].Name == "toolanim" and c[i].className == "StringValue") then
			return c[i]
		end
	end
	return nil
end

function animateTool()
	
	if (toolAnim == "None") then
		RightShoulder.DesiredAngle = -1.57
		return
	end

	if (toolAnim == "Slash") then
		RightShoulder.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = 0
		return
	end

	if (toolAnim == "Lunge") then
		RightShoulder.MaxVelocity = 0.5
		LeftShoulder.MaxVelocity = 0.5
		RightHip.MaxVelocity = 0.5
		LeftHip.MaxVelocity = 0.5
		RightShoulder.DesiredAngle = -1.57
		LeftShoulder.DesiredAngle = 1.0
		RightHip.DesiredAngle = 1.57
		LeftHip.DesiredAngle = 1.0
		return
	end
end

function move(time)
	local amplitude
	local frequency

	if (pose == "Jumping") then
		moveJump()
		return
	end

	if (pose == "Zombie") then
		moveZombie()
		return
	end

	if (pose == "Boogy") then
		moveBoogy()
		return
	end

	if (pose == "Float") then
		moveFloat()
		return
	end

	if (pose == "Punch") then
		movePunch()
		return
	end

	if (pose == "Kick") then
		moveKick()
		return
	end

	if (pose == "Fly") then
		moveFly()
		return
	end

	if (pose == "FreeFall") then
		moveFreeFall()
		return
	end

	if (pose == "Climbing") then
		moveClimb()
		return
	end

	if (pose == "Seated") then
		moveSit()
		return
	end

		amplitude = 0.1
		frequency = 1

	RightShoulder.MaxVelocity = 0.15
	LeftShoulder.MaxVelocity = 0.15
	if (pose == "Running") then
		amplitude = 1
		frequency = 9
	elseif (pose == "Dancing") then
		amplitude = 2
		frequency = 16
	end


	desiredAngle = amplitude * math.sin(time*frequency)
	if pose~="Dancing" then
		RightShoulder.DesiredAngle = -desiredAngle
		LeftShoulder.DesiredAngle = desiredAngle
		RightHip.DesiredAngle = -desiredAngle
		LeftHip.DesiredAngle = -desiredAngle
	else
		RightShoulder.DesiredAngle = desiredAngle
		LeftShoulder.DesiredAngle = desiredAngle
		RightHip.DesiredAngle = -desiredAngle
		LeftHip.DesiredAngle = -desiredAngle
	end
		


	local tool = getTool()

	if tool ~= nil then
	
		animStringValueObject = getToolAnim(tool)

		if animStringValueObject ~= nil then
			toolAnim = animStringValueObject.Value
			-- message recieved, delete StringValue
			animStringValueObject.Parent = nil
			toolAnimTime = time + .3
		end

		if time > toolAnimTime then
			toolAnimTime = 0
			toolAnim = "None"
		end

		animateTool()

		
	else
		toolAnim = "None"
		toolAnimTime = 0
	end
end


-- connect events
-----------------------------------------------------------------------------------------------------------------------

function unequip()
	local items=script.Parent:children()
	for i=1, #items do
		if items[i].className=="Tool" then items[i]:remove() end
	end
end

function onChatted(msg, recipient) 
	msg = string.lower(msg)

	if string.match(msg, string.lower(script.Parent.Name))~=nil or string.match(msg, "everyone") then
		if string.match(msg, "equip") then 
			if game.Workspace:findFirstChild("Hub") then
				if string.match(msg, "rocket") then unequip()
					game.Workspace.Hub.Rocket:clone().Parent=script.Parent
				elseif string.match(msg, "slingshot") then unequip()
					game.Workspace.Hub.Slingshot:clone().Parent=script.Parent
				elseif string.match(msg, "sword") then unequip()
					game.Workspace.Hub.Sword:clone().Parent=script.Parent
				elseif string.match(msg, "pbg") then unequip()
					game.Workspace.Hub.PBG:clone().Parent=script.Parent
				elseif string.match(msg, "superball") then unequip()
					game.Workspace.Hub.Superball:clone().Parent=script.Parent
				elseif string.match(msg, "trowel") then unequip()
					game.Workspace.Hub.Trowel:clone().Parent=script.Parent
				elseif string.match(msg, "bomb") then unequip()
					game.Workspace.Hub.Bomb:clone().Parent=script.Parent
				end
			end
		end
		if string.match(msg, "unequip") then unequip() end
		if string.match(msg, "run") then onRunning(1) end
		if string.match(msg, "climb") then onClimbing() end
		if string.match(msg, "jump") then onJumping() end
		if string.match(msg, "zombie") then pose="Zombie" end
		if string.match(msg, "disco") then pose="Boogy" end
		if string.match(msg, "float") then pose="Float" end
		if string.match(msg, "punch") then pose="Punch" end
		if string.match(msg, "kick") then pose="Kick" end
		if string.match(msg, "fly") then pose="Fly" end
		if string.match(msg, "heal") then script.Parent.Humanoid.Health=script.Parent.Humanoid.MaxHealth end
		if string.match(msg, "defend") then defence() end
		if string.match(msg, "stop") then pose="Standing"; proxkill=false; following=false; stopmoving() end
		if string.match(msg, "go home") then following=false; gohome() end
		if string.match(msg, "follow") then
			if string.match(msg, "all") then
				followany()
			else
				local egg=game.Players:children()
				for i=1, #egg do
					if string.match(msg, string.lower(egg[i].Name)) then
						follow(egg[i].Name)
						return
					end
				end
			end
		end
		if string.match(msg, "kill") then
			if string.match(msg, "all") then
				attackany()
			else
				local egg=game.Players:children()
				for i=1, #egg do
					if string.match(msg, string.lower(egg[i].Name)) then
						attack(egg[i].Name)
						return
					end
				end
			end
		end

	end
end

if game.Players.NumPlayers>1 then
	x=game.Players:children()
	
	for i=1, #x do
		if script.Parent:findFirstChild("Commander")~=nil then
			if script.Parent.Commander:children()~=nil or script.Parent.Commander:children()>0 then
				local ch=script.Parent.Commander:children()
				for i=1, #ch do
					if string.lower(ch[i].Name)==string.lower(x[i].Name) then
						x[i].Chatted:connect(function(msg, recipient) onChatted(msg, recipient) end) 
					end
				end
			elseif string.lower(script.Parent.Commander.Value)==string.lower(x[i].Name) then
				x[i].Chatted:connect(function(msg, recipient) onChatted(msg, recipient) end) 
			end
		else
			x[i].Chatted:connect(function(msg, recipient) onChatted(msg, recipient) end)
		end
	end
end


function onPlayerEntered(Player) 
	while Player.Name==nil do
		wait(2)
	end
	if script.Parent:findFirstChild("Commander")~=nil then
		if script.Parent.Commander:children()~=nil or script.Parent.Commander:children()>0 then
			local ch=script.Parent.Commander:children()
			for i=1, #ch do
				if string.lower(ch[i].Name)==string.lower(Player.Name) then
					Player.Chatted:connect(function(msg, recipient) onChatted(msg, recipient) end) 
				end
			end
		elseif string.lower(script.Parent.Commander.Value)==string.lower(Player.Name) then
			Player.Chatted:connect(function(msg, recipient) onChatted(msg, recipient) end) 
		end
	else
		Player.Chatted:connect(function(msg, recipient) onChatted(msg, recipient) end)
	end
end

game.Players.ChildAdded:connect(onPlayerEntered) 



-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
dist=20

function followany()
following=true
	while following==true do

		local ch=game.Players:children()
		for i=1, #ch do
			local l=game.Workspace:findFirstChild(ch[i].Name)
			if l~=nil then
				local s=l.Torso
				local p=l.Torso.Position
				local q=script.Parent.Torso.Position
				local d=math.sqrt( ((p.x-q.x)^2)+((p.y-q.y)^2)+((p.z-q.z)^2) )
				if smallest==nil then
					smallest=d
					target=s
				elseif d<smallest then
					smallest=d
					target=s
				end
			end
		end

		if smallest==nil then stopmoving() return end
		
		if smallest>6*dist then return end
		
		script.Parent.Humanoid:MoveTo(target.Position, target)

		wait(0.5)
		for i=1, 6 do
			if target.Parent.Humanoid.Health<1 then stopmoving() else	wait(0.5) end
		end
	end
end



function gohome()
	script.Parent.Humanoid:MoveTo(Vector3.new(0,0,0), game.Workspace.Bases.Base)
end
function stopmoving()
	script.Parent.Humanoid:MoveTo(script.Parent.Torso.Position, script.Parent.Torso)
end

function follow(name)
	following=true

	local p=game.Workspace:findFirstChild(name)
	if p==nil then return end
	while following==true do	
		script.Parent.Humanoid:MoveTo(p.Torso.Position, p.Torso)
		wait(0.5)
		for i=1, 3 do
			if p.Humanoid.Health<1 then following=false; stopmoving() return end
			wait(0.5)
		end
	end
end

function attack(name)
	if script.Parent:findFirstChild("Sword")~=nil then	
		following=true
		local p=game.Workspace:findFirstChild(name)
		if p==nil then return end
		while following==true do
			script.Parent.Humanoid:MoveTo(p.Torso.Position, p.Torso)
			wait(0.5)
			for i=1, 3 do
				if p.Humanoid.Health<1 then following=false; stopmoving() return end
				local l=p.Torso.Position
				local q=script.Parent.Torso.Position
				local d=math.sqrt( ((l.x-q.x)^2)+((l.y-q.y)^2)+((l.z-q.z)^2) )
				if d<10 then
					script.Parent.Humanoid:MoveTo(p.Torso.Position, p.Torso); slash()
					if (q.y-l.y)>3 and (q.y-l.y)<7 then
						script.Parent.Humanoid:MoveTo(p.Torso.Position+Vector3.new(math.random(-4,4),0,math.random(-4,4)), p.Torso);
					end
				end
				wait(1)
			end
		end
	end
end

function attackany()
if script.Parent:findFirstChild("Sword")~=nil then	

	following=true
		while following==true do

			local ch=game.Players:children()
			for i=1, #ch do
				local l=game.Workspace:findFirstChild(ch[i].Name)
				if l~=nil then
					local s=l.Torso
					local p=l.Torso.Position
					local q=script.Parent.Torso.Position
					local d=math.sqrt( ((p.x-q.x)^2)+((p.y-q.y)^2)+((p.z-q.z)^2) )
					if smallest==nil then
						smallest=d
						target=s
					elseif d<smallest then
						smallest=d
						target=s
					end
				end
			end

			if smallest==nil then stopmoving() return end
			
			if smallest>6*dist then return end
			
			script.Parent.Humanoid:MoveTo(target.Position, target)

			if smallest<10 then
				slash()
			end
			if target.Parent==nil then stopmoving() return end
			wait(0.5)
			for i=1, 3 do
				if target.Parent.Humanoid.Health<1 then 
					stopmoving() 
				else
					local p=target.Position
					local q=script.Parent.Torso.Position
					local d=math.sqrt( ((p.x-q.x)^2)+((p.y-q.y)^2)+((p.z-q.z)^2) )
					if d<10 then
						script.Parent.Humanoid:MoveTo(target.Position, target); slash()
						if (q.y-p.y)>3 and (q.y-p.y)<7 then
							script.Parent.Humanoid:MoveTo(p.Torso.Position+Vector3.new(math.random(-4,4),0,math.random(-4,4)), p.Torso);
						end
					end
					wait(1)
				end
			end
		end
	end
end


function patrol()
	if points==nil then
		points=0
		if game.Workspace:findFirstChild("pp1")~=nil then
		pp1=game.Workspace:findFirstChild("pp1")
		local points=points+1
			if game.Workspace:findFirstChild("pp2")~=nil then
			pp2=game.Workspace:findFirstChild("pp2")
		local points=points+1
				if game.Workspace:findFirstChild("pp3")~=nil then
				pp3=game.Workspace:findFirstChild("pp3")
		local points=points+1
					if game.Workspace:findFirstChild("pp4")~=nil then
					pp4=game.Workspace:findFirstChild("pp4")
		local points=points+1
						if game.Workspace:findFirstChild("pp5")~=nil then
						pp5=game.Workspace:findFirstChild("pp5")
		local points=points+1
							if game.Workspace:findFirstChild("pp6")~=nil then
							pp6=game.Workspace:findFirstChild("pp6")
		local points=points+1
								if game.Workspace:findFirstChild("pp7")~=nil then
								pp7=game.Workspace:findFirstChild("pp7")
		local points=points+1
									if game.Workspace:findFirstChild("pp8")~=nil then
									pp8=game.Workspace:findFirstChild("pp8")
		local points=points+1
										if game.Workspace:findFirstChild("pp9")~=nil then
										pp9=game.Workspace:findFirstChild("pp9")
		local points=points+1
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if points<1 then return end
	patrolling=true
	local time=2
	if points==1 then return end
	if points>1 then
		while patrolling==true do
			script.Parent.Humanoid:MoveTo(pp1.Position, pp1)
			wait(time)
			script.Parent.Humanoid:MoveTo(pp2.Position, pp2)
			wait(time)
			if points>2 then
				script.Parent.Humanoid:MoveTo(pp3.Position, pp3)
				wait(time)
				if points>3 then
					script.Parent.Humanoid:MoveTo(pp4.Position, pp4)
					wait(time)
					if points>4 then
						script.Parent.Humanoid:MoveTo(pp5.Position, pp5)
						wait(time)
						if points>5 then
							script.Parent.Humanoid:MoveTo(pp6.Position, pp6)
							wait(time)
							if points>6 then
								script.Parent.Humanoid:MoveTo(pp7.Position, pp7)
								wait(time)
								if points>7 then
									script.Parent.Humanoid:MoveTo(pp8.Position, pp8)
									wait(time)
									if points>8 then
										script.Parent.Humanoid:MoveTo(pp9.Position, pp9)
										wait(time)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end


function goto(pos,part)
while true do
end
end


function slash()
	for i=1, 3 do
		wait(.3)
		RightShoulder.MaxVelocity = 2
		LeftShoulder.MaxVelocity = 1
		RightShoulder.DesiredAngle = -2.14
		LeftShoulder.DesiredAngle = 0
		RightHip.DesiredAngle = 0
		LeftHip.DesiredAngle = 0
		wait(.2)
		RightShoulder.MaxVelocity = 2
		LeftShoulder.MaxVelocity = 1
		RightShoulder.DesiredAngle = 0
		LeftShoulder.DesiredAngle = 0
		RightHip.DesiredAngle = 0
		LeftHip.DesiredAngle = 0
	end
end

function defence()
	proxkill=true
	while proxkill==true do
		local ch=game.Players:children()
		for i=1, #ch do
			local p=game.Workspace:findFirstChild(ch[i].Name)
			if p~=nil then
				local p=p.Torso.Position
				local q=script.Parent.Torso.Position
				local d=math.sqrt( ((p.x-q.x)^2)+((p.y-q.y)^2)+((p.z-q.z)^2) )
				if d<dist and d>8 then
					local ex=Instance.new("Explosion")
					ex.Position=p
					ex.Parent=game.Workspace
				end
			end		
		end
		wait(1)
	end
end




-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------


Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(onJumping)
Humanoid.Climbing:connect(onClimbing)
Humanoid.GettingUp:connect(onGettingUp)
Humanoid.FreeFalling:connect(onFreeFall)
Humanoid.FallingDown:connect(onFallingDown)
Humanoid.Seated:connect(onSeated)


--[[

function newSound(id)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Parent = script.Parent.Head
	return sound
end


local sDied = newSound("rbxasset://sounds/uuhhh.wav")
local sFallingDown = newSound("rbxasset://sounds/splat.wav")
local sFreeFalling = newSound("rbxasset://sounds/swoosh.wav")
local sGettingUp = newSound("rbxasset://sounds/hit.wav")
local sJumping = newSound("rbxasset://sounds/button.wav")
local sRunning = newSound("rbxasset://sounds/bfsl-minifigfoots1.mp3")
sRunning.Looped = true

local Figure = script.Parent
local Head = waitForChild(Figure, "Head")
local Humanoid = waitForChild(Figure, "Humanoid")


function onDied()
	sDied:play()
end

function onState(state, sound)
	if state then
		sound:play()
	else
		sound:pause()
	end
end

function onRunning(speed)
	if speed>0 then
		sRunning:play()
	else
		sRunning:pause()
	end
end


Humanoid.Died:connect(onDied)
Humanoid.Running:connect(onRunning)
Humanoid.Jumping:connect(function(state) onState(state, sJumping) end)
Humanoid.GettingUp:connect(function(state) onState(state, sGettingUp) end)
Humanoid.FreeFalling:connect(function(state) onState(state, sFreeFalling) end)
Humanoid.FallingDown:connect(function(state) onState(state, sFallingDown) end)
--]]

local nextTime = 0
local runService = game:service("RunService");

while Figure.Parent~=nil do
	time = runService.Stepped:wait()
	if time > nextTime then
		move(time)
		nextTime = time + 0.1
	end
end
