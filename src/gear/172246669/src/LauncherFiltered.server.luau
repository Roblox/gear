--Stickmasterluke


local sp=script.Parent


local weaponevent=sp:WaitForChild("WeaponEvent")
local handle=sp:WaitForChild("Handle")
local firesound=handle:WaitForChild("Fire")
local debris=game:GetService("Debris")
firerate=.4
velocity=200
loaded=false

local Pellet = Instance.new("Part")
Pellet.Name="Paintball"
Pellet.formFactor="Custom"
Pellet.Size=Vector3.new(1,1,1)*.5
--Pellet.Shape="Ball"	--can't be custom size
Pellet.BrickColor=BrickColor.new("Lime green")
Pellet.Material=Enum.Material.Plastic
Pellet.Locked=true
Pellet.CanCollide=false
Pellet.TopSurface=0
Pellet.BottomSurface=0
local m=Instance.new("SpecialMesh")
m.MeshType="Sphere"
m.Scale=Vector3.new(1,1,1)
m.Parent=Pellet
sp:WaitForChild("ProjectileScript"):clone().Parent = Pellet


function gunUp()
	sp.GripPos=Vector3.new(0,-0.3,(.8-0.45))
end

function gunOut()
	sp.GripPos=Vector3.new(0,-0.3,(1-.45))
end

function onEquipped()
	firesound:Stop()
end

function onUnequipped()
	firesound:Stop()
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)


enabled=true
function Fire(pos)
	if enabled and sp and sp.Parent then
		enabled=false
		local chr=sp.Parent
		local h=chr:FindFirstChild("Humanoid")
		local head=chr:FindFirstChild("Head")
		if h and h.Health>0 and head then
			local plr=game.Players:GetPlayerFromCharacter(chr)
			if plr then
				gunUp()
				firesound:Play()
				
				local vec=(pos-head.Position).unit
			
				local missile=Pellet:clone()
				missile.CFrame=CFrame.new(head.Position,head.Position+vec)--*CFrame.new(0,0,-5)
				missile.Velocity=vec*velocity
				missile.ProjectileScript.Disabled=false
				
				local force=Instance.new("BodyForce")
				force.force=Vector3.new(0,missile:GetMass()*.8*196.2,0)
				force.Parent=missile
				
				local creatortag=Instance.new("ObjectValue")
				creatortag.Name="creator"
				creatortag.Value=plr
				creatortag.Parent=missile
				
				debris:AddItem(missile,10)
				missile.Parent=game.Workspace
				
				wait(firerate*.5)
				gunOut()
				wait(firerate*.5)
			end
		end
		enabled=true
	end
end


weaponevent.OnServerEvent:connect(function(plr,...)
	local tuple={...}
	if tuple[1]=="Fire" then
		Fire(tuple[2])
	end
end)






