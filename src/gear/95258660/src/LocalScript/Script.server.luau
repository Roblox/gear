--Stickmasterluke


sp=script.Parent

wait(2.5)

local creator=sp:FindFirstChild("creator")
local debris=game:GetService("Debris")


local fire=Instance.new("Fire")
fire.Heat=0
fire.Size=100
fire.Color=Color3.new(1,1,153/255)
fire.SecondaryColor=Color3.new(153/255,51/255,0)
fire.Parent=sp

local explodesound=sp:FindFirstChild("ExplodeSound")
if explodesound then
	explodesound:Play()
end
sp.Anchored=true
sp.Transparency=1

local e=Instance.new("Explosion")
e.BlastRadius=12
e.BlastPressure=1.5*10^6
e.Position=sp.Position
e.ExplosionType=0
e.Hit:connect(function(hit)
	if hit~=nil and hit.Parent~=nil and (hit.Name=="Head" or hit.Name=="Torso") then
		local h=hit.Parent:FindFirstChild("Humanoid")
		local ct=sp:FindFirstChild("creator")
		if h~=nil and ct~=nil then
			for _,v in pairs(h:GetChildren()) do
				if v~=nil then
					v:remove()
				end
			end
			ct:clone().Parent=h
		end
	end
end)
e.Parent=game.Workspace

wait(.3)
fire.Enabled=false
wait(1)
sp:remove()
