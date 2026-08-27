--Made by Stickmasterluke


sp=script.Parent
plr=game.Players.LocalPlayer


local speed=2
local topspeed=50

local rate=1/30

local inertia=1-(speed/topspeed)
local debris=game:GetService("Debris")
local flying=false
local controls={forward=0,backward=0,left=0,right=0}
local momentum=Vector3.new(0,0,0)
local lastmomentum=Vector3.new(0,0,0)
local totalmomentum=0
local tilt=0
local lasttilt=0

local equipped = false

local anim=script:WaitForChild("FlyAnimation")

function RemoveFlyStuff()
	if plr and plr.Character then
		local torso=plr.Character:FindFirstChild("Torso")
		if torso~=nil then
			for _,v in pairs(torso:GetChildren()) do
				if v and (v.Name=="FlightGyro" or v.Name=="FlightVelocity") then
					v:remove()
				end
			end
		end
	end
	if flyanim~=nil then
		flyanim:Stop()
	end
end

function fly()		--(de)activate fly mode
	flying=not flying
	RemoveFlyStuff()
	if flying then
		if plr and plr.Character then
			local torso=plr.Character:FindFirstChild("Torso")
			local humanoid=plr.Character:FindFirstChild("Humanoid")
			if torso and humanoid and humanoid.Health>0 then
				momentum=torso.Velocity+(torso.CFrame.lookVector*10)+Vector3.new(0,10,0)
	
				local gyro=Instance.new("BodyGyro")
				gyro.Name="FlightGyro"
				gyro.P=10^6
				gyro.maxTorque=Vector3.new(gyro.P,gyro.P,gyro.P)
				gyro.cframe=torso.CFrame
				gyro.Parent=torso
	
				velocity=Instance.new("BodyVelocity")
				velocity.Name="FlightVelocity"
				velocity.velocity=Vector3.new(0,0,0)
				velocity.P=10^4
				velocity.maxForce=Vector3.new(1,1,1)*(10^6)
				velocity.Parent=torso
	
				if flyanim~=nil then
					flyanim:Stop()
				end
				flyanim=humanoid:LoadAnimation(anim)
				if flyanim then
					flyanim:Play()
				end
	
				while equipped and flying and torso and humanoid and humanoid.Health>0 do
					local movement=game.Workspace.CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(controls.left+controls.right,math.abs(controls.forward)*.2,controls.forward+controls.backward))*speed
	
					momentum=(momentum*inertia)+movement
					totalmomentum=momentum.magnitude
					if totalmomentum>topspeed then
						totalmomentum=topspeed
					end
	
					local tilt=((momentum*Vector3.new(1,0,1)).unit:Cross(((lastmomentum*Vector3.new(1,0,1)).unit))).y
					local tstilt=tostring(tilt)
					if tstilt=="-1.#IND" or tstilt=="1.#IND" or tilt==math.huge or tilt==-math.huge or tstilt==tostring(0/0) then
						tilt=0
					end
					
					local abstilt=math.abs(tilt)
					if abstilt>.06 or abstilt<.0001 then
						if math.abs(lasttilt)>.0001 then
							tilt=lasttilt*.9
						else
							tilt=0
						end
					else
						tilt=(lasttilt*.77)+(tilt*.25)			--weighted average
					end
					lasttilt=tilt
	
					if totalmomentum<.5 then
						momentum=Vector3.new(0,0,0)
						totalmomentum=0
						gyro.cframe=game.Workspace.CurrentCamera.CoordinateFrame
					else
						gyro.cframe=CFrame.new(Vector3.new(0,0,0),momentum)*CFrame.Angles(0,0,tilt*(-20))*CFrame.Angles(math.pi*(-.5)*(totalmomentum/topspeed),0,0)
					end
					velocity.velocity=momentum
					lastmomentum=momentum
					wait(rate)
				end
				RemoveFlyStuff()
				flying=false
			end
		end
	end
end

local IsFlying = false

script.Parent.Equipped:connect(function(mouse) --Fix implemented by Luckymaxer
	equipped = true
	mouse.KeyDown:connect(function(key2)
		local key=string.byte(key2)
		if key==32 then					--Space bar
			if IsFlying then
				RemoveFlyStuff()
			else
				fly()
			end
			IsFlying = not IsFlying
		elseif key==string.byte("w") or key==17 then
			controls.forward=-1
		elseif key==string.byte("a") or key==20 then
			controls.left=-1
		elseif key==string.byte("s") or key==18 then
			controls.backward=1
		elseif key==string.byte("d") or key==19 then
			controls.right=1
		end
	end)
	mouse.KeyUp:connect(function(key2)
		local key=string.byte(key2)
		if key==string.byte("w") or key==17 then
			controls.forward=0
		elseif key==string.byte("a") or key==20 then
			controls.left=0
		elseif key==string.byte("s") or key==18 then
			controls.backward=0
		elseif key==string.byte("d") or key==19 then
			controls.right=0
		end
	end)
	delay(0,function()
		fly()
		IsFlying = true
	end)
end)

script.Parent.Unequipped:connect(function()
	--print('inUnequip')
	equipped = false
	if flying then
		--print('inUnequip2')
		RemoveFlyStuff()
		IsFlying = false
	end
	
end)



