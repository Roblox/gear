--Made by QuantumSama

local Tool = script.Parent
sp=script.Parent
plr=game.Players.localPlayer


damage=27
local reloadTime = .25
local orb
local Mouse
firerate=1
local range = 250
barreloffset=Vector3.new(0, 0.25, -1.7)
windvec=Vector3.new(2,-1,1).unit

rate=1/30
debris=game:GetService("Debris")
equipped=false
check=true

local PewPew = Tool.Handle:FindFirstChild("PewPew")

if (PewPew == nil) then
	PewPew = Instance.new("Sound")
	PewPew.Name = "PewPew"
	PewPew.SoundId = "http://www.roblox.com/asset/?id=22968437"
	PewPew.Parent = Tool.Handle
	PewPew.Pitch = 1 --.85
	PewPew.Volume = .85
end

local laserSound = Tool.Handle:FindFirstChild("LaserSound")

if (laserSound == nil) then
	laserSound = Instance.new("Sound")
	laserSound.Name = "LaserSound"
	laserSound.SoundId = "http://www.roblox.com/asset/?id=85848355"
	laserSound.Parent = Tool.Handle
	laserSound.Pitch = 1 --.85
	laserSound.Volume = 1
end

 

function tagHumanoid(humanoid)
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=game.Players.LocalPlayer
	creator_tag.Name="creator"
	debris:AddItem(creator,.5)
	creator_tag.Parent=humanoid
end

function damagePartOwner(part, damage)
	if part and part.Parent and Tool and Tool.Parent and plr and Tool.Parent ~= part.Parent then
		local hum = part.Parent:FindFirstChild("Humanoid")
		if hum then
			tagHumanoid(hum)
			hum.Health = hum.Health - damage
			--hum:TakeDamage(damage)
			return true
		end
	end
	return false
end

function checkintangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(Tool.Parent) or hit.Transparency>.9 or hit.Name=="Handle" or hit.Name=="Effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" then
			return true
		end
	end
	return false
end

function castray(startpos,vec,length,ignore,delayifhit)
	local hit,endpos2=game.Workspace:FindPartOnRay(Ray.new(startpos,vec*length),ignore)
	if hit~=nil then
		if checkintangible(hit) then
			if delayifhit then
				wait()
			end
			hit,endpos2=castray(endpos2+(vec*.01),vec,length-((startpos-endpos2).magnitude),ignore,delayifhit)
		end
	end
	return hit,endpos2
end

function drawbeam(beamstart,beamend,clr,charge)
	local dist=(beamstart-beamend).magnitude
	local laser=Instance.new("Part")
	laser.Name="Effect"
	--laser.Anchored=true
	laser.CanCollide=false
	laser.Shape="Block"
	laser.formFactor="Custom"
	laser.Size=Vector3.new(.2,.2,.2)
	laser.Transparency=0
	laser.Material=Enum.Material.Plastic
	laser.Locked=true
	laser.TopSurface=0
	laser.BottomSurface=0
	laser.BrickColor=clr
	laser.CFrame=CFrame.new(beamend,beamstart)*CFrame.new(0,0,-dist/2)*CFrame.Angles(math.pi/2,0,0)
	local mesh=Instance.new("SpecialMesh")
	local scale = math.sqrt(charge/20)
	mesh.Scale=Vector3.new(scale,dist*5,scale)
	mesh.Parent=laser
	return laser 

end

local charge = -100

function fireSmallLaser(charge)
	if orb then
		PewPew:Play()
		--print("firing laser")
		local startpos = orb.Position
		local vec = (Mouse.Hit.p-startpos).unit
		local smallLaser = drawbeam(startpos, startpos + vec * 3, BrickColor.new(Color3.new(1,.3,.3)), charge )
		local bv = Instance.new("BodyVelocity")
		bv.velocity = vec *200
		bv.Parent = smallLaser
		debris:AddItem(smallLaser,5)
		smallLaser.Parent = game.Workspace
		local damage = 5+math.floor(charge/2)
		smallLaser.Touched:connect(function(hit) 
			local didDamage = damagePartOwner(hit,damage)
			--print("hit, ", didDamage)
			if didDamage and smallLaser then smallLaser:Destroy() end
		end)
		orb:Destroy()
	end
end

function fireLargeLaser()
	local frames = 57
	local largeLaser
	laserSound:Play()
	for i = 1, frames do
		if not orb or not orb.Parent or not Mouse then break end
		local startpos = orb.Position 
		local hit, endPos = castray(startpos, (Mouse.Hit.p-startpos).unit, range, Tool.Parent)
		damagePartOwner(hit,5)
		if largeLaser then largeLaser:Destroy() end
		largeLaser = drawbeam(startpos, endPos, BrickColor.new(Color3.new(1,.2,.2)), 300)
		largeLaser.Anchored = true
		debris:AddItem(largeLaser,.25)
		largeLaser.Parent = game.Workspace
		
		
		wait(1/30)
	end
	if largeLaser then largeLaser:Destroy() end
	if orb then orb:Destroy() end
	wait(6)
end

local isFiring = false
function mouseUp()
	--print("mouseUpped")
	--if Tool.Enabled then return end
	if not orb or not orb.Parent or isFiring then return end
	isFiring = true

	if Mouse then Mouse.Icon = "rbxasset://textures\\GunWaitCursor.png" end
	--TODO: reset characters walkspeed
	if charge > 100 then
		charge = -100
		fireLargeLaser()
	else
		fireSmallLaser(charge)
		charge = -100
	end
	wait(reloadTime)
	isFiring = false
	Tool.Enabled = true
	if Mouse then Mouse.Icon = "rbxasset://textures\\GunCursor.png" end
end


function mouseDown()
	--print("mouseDowned")
	if not Tool.Enabled then return end
	Tool.Enabled = false
	if orb and orb.Parent then return end
	--TODO: nuke characters walkspeed
	charge = 5
	
	orb = Instance.new("Part")
	orb.FormFactor = "Symmetric"
	orb.Shape = "Ball"
	orb.CanCollide = false
	orb.Size = Vector3.new(1,1,1)
	orb.Transparency = .4
	orb.BrickColor = BrickColor.new(Color3.new(1,.3,.3))
	orb.TopSurface = "Smooth"
	orb.BottomSurface = "Smooth"

	local ballMesh = Instance.new("SpecialMesh")
	ballMesh.MeshType = "Sphere"
	ballMesh.Name = "SphereMesh"
	ballMesh.Parent = orb
	local scale = math.sqrt(charge/20)
	ballMesh.Scale = Vector3.new(scale,scale,scale)

	orb.Parent = Tool

	suckPartModel = orb:Clone()
	suckPartModel.Size = suckPartModel.Size * .5
	--suckPartModel.SphereMesh.Scale = suckPartModel.SphereMesh.Scale * .5
	local bv = Instance.new("BodyVelocity")
	bv.Name = "BV"
	bv.Parent = suckPartModel

	local orbWeld = Instance.new("ManualWeld")
	orbWeld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	orbWeld.C1 = CFrame.new(0.049407959, 0.30989188, -1.74499893, 0.999999881, -0.000551184872, -5.29387343e-008, 0.000551184872, 0.999999762, 1.45519152e-011, 4.31729106e-008, -1.45519152e-011, 1)
	orbWeld.Part0 = orb
	orbWeld.Part1 = Tool.Handle
	orbWeld.Parent = orb
	--TODO: make sure gun handle is correct first
	--TODO: weld orb to end of gun

	if Mouse then Mouse.TargetFilter = orb end --stops player from shooting at the special effects

	while orb and ballMesh and charge > 0 do
		local suckPart = suckPartModel:Clone()
		suckPart.CFrame = orb.CFrame + Vector3.new((math.random()-.5)*4,(math.random()-.5)*4,(math.random()-.5)*4)
		suckPart.BV.velocity = (orb.CFrame.p - suckPart.CFrame.p).unit *7
		debris:AddItem(suckPart,(orb.CFrame.p - suckPart.CFrame.p).magnitude/12)
		suckPart.Parent = orb
		
		--TODO: suck in particles
		if charge < 100 then
			scale = math.sqrt(charge/20)
			ballMesh.Scale = Vector3.new(scale,scale,scale)
		else
			local colorVal = math.max(charge %11, 11 - charge%11) --Varies smoothly from 6 to 11 and back
			local scaledColorVal = (colorVal-5)/20
			orb.BrickColor = BrickColor.new(Color3.new(1,scaledColorVal,scaledColorVal))
			--TODO make orb large and change color
		end
		charge = charge +1
		--print(charge)
		wait(1/30)
	end
		
end


function onEquipped(mouse)
	equipped=true

	if mouse~=nil then
		if not Tool.Enabled then 
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			wait(2) 
			Tool.Enabled = true 
		end
		Mouse = mouse
		Mouse.Icon="rbxasset://textures\\GunCursor.png"
		Mouse.Button1Down:connect(mouseDown)
		Mouse.Button1Up:connect(mouseUp)
	end
end

function onUnequipped()
	if orb then orb:Destroy() end
	equipped=false
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)





