--Made by Stickmasterluke


sp=script.Parent


damage=20

alive=true
check=true
nextjump=0
lastmove=0
cycle=0

meshes={114647745,114647773,114647802,114647836,114647881,114647920,114647944}
standmesh=114636624
local link="http://www.roblox.com/asset/?id="

head=sp:WaitForChild("Head")
hum=sp:WaitForChild("Humanoid")
torso=sp:WaitForChild("Torso")
mesh=torso:WaitForChild("Mesh")
ct=sp:WaitForChild("creator")
orders=sp:WaitForChild("Orders")
targettag=sp:WaitForChild("Target")
targetpostag=sp:WaitForChild("TargetPos")


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

while alive do
	t1,t2=wait(.05)
	if orders.Value=="Follow" then
		if ct.Value then
			local chr=ct.Value.Character
			local tt=chr:FindFirstChild("Torso")
			if tt then
				hum.WalkSpeed=15
				hum:MoveTo((tt.CFrame*CFrame.new(-3,0,-5)).p,tt)
			end
		end
	elseif orders.Value=="MoveTo" then
		hum.WalkSpeed=18
		hum:MoveTo(targetpostag.Value,targettag.Value)
		lastmove=t2
		orders.Value="Nothing"
	elseif orders.Value=="Attack" then
		if targettag.Value then
			local tt=targettag.Value:FindFirstChild("Torso")
			local th=targettag.Value:FindFirstChild("Humanoid")
			if tt then	--and th and th.Health>0 then --this is too awesome
				local offset=Vector3.new((math.random()-.5)*5,(math.random()-.5)*5,(math.random()-.5)*5)
				hum.WalkSpeed=22
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
		nextjump=t2+math.random(5,10)
		hum.Jump=true
	end
	if torso.Velocity.magnitude>2 then
		cycle=cycle+1
		mesh.MeshId=link..tostring(meshes[(cycle%#meshes)+1])
	else
		mesh.MeshId=link..tostring(standmesh)
	end
end


