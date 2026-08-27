--Stickmasterluke


local sp=script.Parent
local sword=sp.Handle


basedamage=3
swingdamage=22
dragonrestusage=10
restrate=8
anims={"RightSlash","LeftSlash","OverHeadSwing"}
rate=1/30


damage=basedamage
dragonrest=0
resting=false
equipped=false
check=true
taunting=false
lastanim=""
lastspeed=16
lastspeedtime=0

while sp:FindFirstChild("FireWeld")==nil do 
	wait()
end
local storeWeld=sp.FireWeld
while gui==nil do
	wait()
	gui=sp:FindFirstChild("GreenDragonGui")
end

function swordUp()
	sp.Grip=CFrame.new(0,0,.9)*CFrame.Angles(-math.pi/2,math.pi/2,0)
	sworddowned=false
end

function swordOut()
	sp.Grip=CFrame.new(0,0,.9)*CFrame.Angles(0,-.5,0)*CFrame.Angles(-math.pi/2,2.4,0)
end

function swordDown()
	sp.Grip=CFrame.new(-.1,0,.9)*CFrame.Angles(-math.pi/2,math.pi/2,0)*CFrame.Angles(2.8,-.5,-.2)
	sworddowned=true
end

function playsound(soundname)
	if soundname and sp:FindFirstChild("SoundScript")~=nil then
		local soundtag=Instance.new("StringValue")
		soundtag.Name=soundname
		soundtag.Parent=sp.SoundScript
	end
end

function updaterest()
	if dragonrest>100 then
		dragonrest=100
	elseif dragonrest<0 then
		dragonrest=0
	end
	sword.FirePart.Fire.Enabled=dragonrest>=dragonrestusage
	gui.Bar.Fill.Size=UDim2.new(dragonrest/100,0,1,0)
end

function lunge()
	local t=sp.Parent:FindFirstChild("Torso")
	local h=sp.Parent:FindFirstChild("Humanoid")
	if t and h and equipped then
		local target=h.TargetPoint
		local direction=(target-t.Position)*Vector3.new(1,0,1)
		if direction.magnitude>.01 then
			direction=direction.unit
			local newBV=Instance.new("BodyVelocity")
			newBV.P=100000
			newBV.maxForce=Vector3.new(newBV.P,0,newBV.P)
			newBV.velocity=direction*100
			newBV.Parent=t
			t.CFrame=CFrame.new(t.Position,target*Vector3.new(1,0,1)+Vector3.new(0,t.Position.Y,0))
			playsound("FlashSound")
			wait(.25)
			updaterest()
			if newBV~=nil then
				newBV:remove()
			end
		end
	end
end

function blow(hit)
	if (hit.Parent==nil) then return end -- happens when bullet hits sword
	local humanoid=hit.Parent:findFirstChild("Humanoid")
	local vCharacter=sp.Parent
	local vPlayer=game.Players:playerFromCharacter(vCharacter)
	local hum=vCharacter:findFirstChild("Humanoid") -- non-nil if sp held by a character
	if humanoid~=nil and humanoid~=hum and hum~=nil then
		-- final check, make sure sword is in-hand
		local right_arm=vCharacter:FindFirstChild("Right Arm")
		if (right_arm~=nil) then
			local joint=right_arm:FindFirstChild("RightGrip")
			if (joint~=nil and (joint.Part0==sword or joint.Part1==sword)) then
				tagHumanoid(humanoid,vPlayer)
				humanoid:TakeDamage(damage)
				wait(1)
				untagHumanoid(humanoid)
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=player
	creator_tag.Name="creator"
	creator_tag.Parent=humanoid
end

function untagHumanoid(humanoid)
	if humanoid~=nil then
		local tag=humanoid:findFirstChild("creator")
		if tag~=nil then
			tag.Parent=nil
		end
	end
end

function makeconnection()
	while mh==nil do
		wait(.1)
		mh=sp.Parent:FindFirstChild("Humanoid")
	end
	if connection then
		connection:disconnect()
	end
	connection=mh.Running:connect(moved)
end

function onEquipped(mouse)
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	lastmove=tick()
	equipped=true
	swordUp()
	updaterest()
	local plr=game.Players.LocalPlayer
	if plr~=nil then
		local plrgui=plr:FindFirstChild("PlayerGui")
		if plrgui~=nil then
			gui.Parent=plrgui
		end
	end
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	mouse.KeyDown:connect(function(key)
		key=string.lower(key)
		if key=="l" or key=="t" or key=="g" then			--A fun taunt
			local h=sp.Parent:FindFirstChild("Humanoid")
			if h~=nil and equipped and check and not taunting then
				taunting=true
				tauntanim=h:LoadAnimation(sp.Roar)
				if tauntanim then
					h.WalkSpeed=0
					tauntanim:Play()
					wait(1.5)
					playsound("RoarSound")
					wait(1.3)
					dragonrest=dragonrest+22
					updaterest()
					wait(1)
					h.WalkSpeed=16
				end
				lastmove=tick()
				taunting=false
			end
		end
	end)
	mouse.Button1Down:connect(function()
		if check and equipped and not taunting then
			check=false
			newanim=anims[math.random(1,#anims)]
			while newanim==lastanim do
				newanim=anims[math.random(1,#anims)]
			end
			lastanim=newanim
			local h=sp.Parent:FindFirstChild("Humanoid")
			local t=sp.Parent:FindFirstChild("Torso")
			local anim=sp:FindFirstChild(newanim)
			if t and h and anim then
				theanim=h:LoadAnimation(anim)
				if theanim and h.Health>0 then
					playsound("SlashSound")
					damage=swingdamage
					theanim:Play()
					if dragonrest>=dragonrestusage then
						dragonrest=dragonrest-dragonrestusage
						delay(0,lunge)
					end
					if newanim=="OverHeadSwing" then
						wait(.25)
						swordOut()
						wait(.4)
						swordUp()
					else
						wait(.5)
					end
					lastmove=tick()
					damage=basedamage
				end
			end
			check=true
		end
	end)
	if storeWeld then
		storeWeld.Parent=sp
	end 
	makeconnection()
end

function onUnequipped()
	gui.Parent=sp
	equipped=false
	if connection~=nil then
		connection:disconnect()
	end
end

function moved(speed)
	lastspeed=speed
	lastmove=tick()	
	print(speed)
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)
sword.Touched:connect(blow)

makeconnection()

while true do
	mh=sp.Parent:FindFirstChild("Humanoid")
	if lastspeed==0 and check and equipped and not taunting and mh and mh~=nil and mh.Health>0 then
		currenttime=tick()
		if currenttime-lastmove>=3 then
			if not dragonresting then
				dragonresting=true
				if restanim~=nil then
					restanim:Stop()
				end
				restanim=mh:LoadAnimation(sp.Rest)
				if restanim then
					restanim:Play()
				end
			else
				if currenttime-lastmove>=4 then
					if not sworddowned then
						swordDown()
					end
					dragonrest=dragonrest+(restrate*rate)
					updaterest()
				end
			end
		end
	else
		if dragonresting then
			dragonresting=false
			if restanim~=nil then
				restanim:Stop()
			end
			swordUp()
		end
	end
	wait(rate)
end

