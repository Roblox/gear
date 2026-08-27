--Made by Stickmasterluke


sp=script.Parent


damage=22

alive=true
check=true
nextjump=0
nextgrowl=0
nextfade=0
lastmove=0
cycle=0
amplitude=.2
frequency=2
rate=.1

meshes={122293937}
standmesh=122293937
local link="http://www.roblox.com/asset/?id="

head=sp:WaitForChild("Head")
hum=sp:WaitForChild("Humanoid")
torso=sp:WaitForChild("Torso")
mesh=torso:WaitForChild("Mesh")
ct=sp:WaitForChild("creator")
orders=sp:WaitForChild("Orders")
targettag=sp:WaitForChild("Target")
targetpostag=sp:WaitForChild("TargetPos")
local law=torso:WaitForChild("LeftShoulder")
local raw=torso:WaitForChild("RightShoulder")
local llw=torso:WaitForChild("LeftHip")
local rlw=torso:WaitForChild("RightHip")


torso.Touched:connect(function(hit)
	if hit and hit.Parent and hit.Parent.Name~=sp.Name and alive and check then
		local h=hit.Parent:FindFirstChild("Humanoid")
		if h~=nil then
			local plr=game.Players:GetPlayerFromCharacter(hit.Parent)
			if plr then
				if plr==ct.Value then
					return
				end
			end
			check=false
			h:TakeDamage(damage)
			playgrowl()
			wait(1)
			check=true
		end
	end
end)

hum.Changed:connect(function(prop)
	if hum then
		if hum.Health<=0 then
			alive=false
			if torso then
				if mesh then
					mesh.VertexColor=Vector3.new(1,.1,.1)
				end
				hum:remove()
				if head then
					head:remove()
				end
				wait(5)
			end
			sp:remove()
		end
	else
		alive=false
		sp:remove()
	end
end)

function playgrowl()
	if torso then
		local sound=torso:FindFirstChild("GrowlSound1")--..tostring(math.random(1,1)))
		if sound then
			sound.Pitch=1.6+math.random()*.6
			sound:Play()
		end
	end
end

function playfade()
	delay(0,function()
		local frames=1/rate
		for frame=1,frames do
			for _,v in pairs(sp:GetChildren()) do
				if v:IsA("BasePart") and v.Name~="Head" then
					v.Transparency=frame/frames
				end
			end
			wait(rate)
		end
		wait(2)
		local frames=1/rate
		for frame=1,frames do
			for _,v in pairs(sp:GetChildren()) do
				if v:IsA("BasePart") and v.Name~="Head" then
					v.Transparency=1-(frame/frames)
				end
			end
			wait(rate)
		end
	end)
end

while alive do
	t1,t2=wait(.05)
	if orders.Value=="Follow" then
		if ct.Value then
			local chr=ct.Value.Character
			local tt=chr:FindFirstChild("Torso")
			if tt then
				hum.WalkSpeed=15
				hum:MoveTo((tt.CFrame*CFrame.new(4,0,-7)).p,tt)
			end
		end
	elseif orders.Value=="MoveTo" then
		hum.WalkSpeed=20
		hum:MoveTo(targetpostag.Value,targettag.Value)
		lastmove=t2
		orders.Value="Nothing"
	elseif orders.Value=="Attack" then
		if targettag.Value then
			local tt=targettag.Value:FindFirstChild("Torso")
			local th=targettag.Value:FindFirstChild("Humanoid")
			if tt and th and th.Health>0 then
				local offset=Vector3.new((math.random()-.5)*5,(math.random()-.5)*5,(math.random()-.5)*5)
				hum.WalkSpeed=24
				hum:MoveTo(tt.Position+offset,tt)
			else
				orders.Value="Follow"
			end
		end
	elseif orders.Value=="Nothing" then
		if t2-lastmove>=20 then
			orders.Value="Follow"
		end
	end
	if t2>nextjump  then
		nextjump=t2+math.random(10,20)
		hum.Jump=true
	end
	if t2>nextgrowl then
		nextgrowl=t2+math.random(2,4)
		playgrowl()
	end
	if t2>nextfade then
		nextfade=t2+math.random(10,15)
		playfade()
	end
	--[[if torso.Velocity.magnitude>2 then
		cycle=cycle+1
		mesh.MeshId=link..tostring(meshes[(cycle%#meshes)+1])
	else
		mesh.MeshId=link..tostring(standmesh)
	end]]
	if torso.Velocity.magnitude>2 then
		amplitude=1.4
		frequency=hum.WalkSpeed*.8
	else
		amplitude=.2
		frequency=2
	end
	
	--RightShoulder.MaxVelocity=.5 
	--LeftShoulder.MaxVelocity=.5
	climbFudge=math.pi
	desiredAngle=amplitude*math.sin(t2*frequency)
	--desiredAngle2=amplitude*math.sin((t2*frequency)+.5)

	law.DesiredAngle=desiredAngle
	raw.DesiredAngle=-desiredAngle
	llw.DesiredAngle=-desiredAngle
	rlw.DesiredAngle=desiredAngle
end


