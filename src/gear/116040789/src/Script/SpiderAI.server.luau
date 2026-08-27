--Made by Stickmasterluke
-- Fixed for R15 avatars by StarWars


sp=script.Parent


damage=3
range=300

meshes={115977511,115975859}
standingmesh=115973891
--Accidental mesh with no legs. Maybe someone wants it anyways -> 115975800


local head=sp:WaitForChild("Head")
local hum=sp:WaitForChild("Humanoid")
local torso=sp:WaitForChild("Torso")
local mesh=torso:WaitForChild("Mesh")
local ct=sp:WaitForChild("creator")
local debris=game:GetService("Debris")


alive=true
currentmesh=0
nextmove=0


torso.Touched:connect(function(hit)
	if hit and hit.Parent and hit.Parent.Name~=sp.Name and alive then
		local h=hit.Parent:FindFirstChild("Humanoid")
		if h~=nil then
			local plr=game.Players:GetPlayerFromCharacter(hit.Parent)
			if plr then
				if plr==ct.Value then
					return
				end
			end
			for i,v in pairs(h:GetChildren()) do
				if v.Name=="creator" then
					v:Destroy()
				end
			end
			local newct=ct:clone()
			debris:AddItem(newct,1)
			newct.Parent=h
			h:TakeDamage(damage)
		end
	end
end)

hum.Changed:connect(function(prop)
	if hum then
		if hum.Health<=0 then
			alive=false
			if torso then
				hum:Destroy()
				local f=Instance.new("Fire")
				f.Parent=torso
				if head then
					head:Destroy()
				end
				wait(4)
			end
			sp:Destroy()
		end
	else
		alive=false
		sp:Destroy()
	end
end)

while alive do
	local t1,t2=wait(.1)
	if t2>nextmove then
		nextmove=t2+.5+math.random()
		closest=range
		target=nil
		for i,v in ipairs(game.Workspace:GetChildren()) do				--targets every thing named humanoid that is in a model in workspace and is not another spide
			if v and v.className=="Model" and v.Name~=sp.Name then
				local t=v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso")
				local h=v:FindFirstChild("Humanoid")
				if t~=nil and h~=nil and h.Health>0 then
					safe=false
					local plr=game.Players:GetPlayerFromCharacter(v)
					if plr then
						if plr==ct.Value then
							safe=true
						end
					end
					if not safe then
						local mag=(t.Position-torso.Position).magnitude
						if mag<closest then
							target=t
							closest=mag
						end
					end
				end
			end
		end
		if target then
			point=target.Position+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*6)
			--hum.WalkToPoint=point
			hum:MoveTo(point,target)
			if math.random()<.15 then
				hum.Jump=true
			end
		end
	end
	if torso and mesh then
		if torso.Velocity.magnitude>3 then
			currentmesh=currentmesh+1
			mesh.MeshId="http://www.roblox.com/asset/?id="..tostring(meshes[(currentmesh%(#meshes))+1])
		else
			mesh.MeshId="http://www.roblox.com/asset/?id="..tostring(standingmesh)
		end
	end
end


