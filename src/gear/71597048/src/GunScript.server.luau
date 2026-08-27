local Tool = script.Parent 
local Sword = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 

Tool.Enabled = true 

local pirateGun
local pirateGunWeld 
local pirateGunMesh

local bullet = Instance.new("Part")
bullet.FormFactor = 3
bullet.Shape = "Ball"
bullet.Size = Vector3.new(0.5, 0.5, 0.5)
bullet.CanCollide = true 
bullet.Transparency = 0.0

local bulletMesh = Instance.new("SpecialMesh")
bulletMesh.MeshId = "http://www.roblox.com/asset/?id=50876274"
bulletMesh.TextureId = ""
bulletMesh.VertexColor = Vector3.new(1, 1, 0)
bulletMesh.Parent = bullet
bulletMesh.Scale = Vector3.new(0.03, 0.03, 0.03) 

local debris = game:GetService("Debris")

local shootSound

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player 
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1)
	end 
end 

function blow(bullet, hit)
	if hit == nil or hit.Parent == nil or vCharacter == nil then return end
	local humanoid = hit.Parent:findFirstChild("Humanoid")	
	if hit.Parent:IsA("Hat") and hit.Parent.Parent then 
		humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
	end 
	if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil then				
		tagHumanoid(humanoid, vPlayer)				
		humanoid:TakeDamage(21)						
	end
	if bullet then bullet:Remove() end 	
end

function shoot(direction)
     
	vCharacter = Tool.Parent     	

	spawnPos = myTorso.Position
	spawnPos = spawnPos + direction.unit * 5.0

	local bulletC = bullet:Clone()
	bulletC.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	bulletC.Parent = game.Workspace

	local bodyForce = Instance.new("BodyForce")
	bodyForce.force = Vector3.new(0.0, bulletC:GetMass() * 196.1, 0.0)
	bodyForce.Parent = bulletC

	bulletC.Velocity = direction.unit * 50.0    

	bulletC.Touched:connect(function(hit) blow(bulletC, hit) end)

	debris:AddItem(bulletC, 2)
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")

	leftArm = vCharacter:FindFirstChild("Left Arm") 

	if vCharacter and vCharacter:FindFirstChild("PirateGun") == nil and leftArm then 
		pirateGun = Instance.new("Part") 
		pirateGun.FormFactor = 3
		pirateGun.Size = Vector3.new(1.5, 1.5, 1.5)
		pirateGun.CanCollide = false 	
		pirateGun.Name = "PirateGun"
		pirateGun.Parent = vCharacter

		pirateGunMesh = Instance.new("SpecialMesh")
		pirateGunMesh.MeshId = "http://www.roblox.com/asset/?id=71525762"
		pirateGunMesh.TextureId = "http://www.roblox.com/asset/?id=71525769"
		pirateGunMesh.Scale = Vector3.new(1.2, 1.2, 1.2)		
		pirateGunMesh.Parent = pirateGun

		pirateGunWeld = Instance.new("Weld")
		pirateGunWeld.Part0 = leftArm 
		pirateGunWeld.Part1 = pirateGun 
		pirateGunWeld.C1 = CFrame.new(0, -1.90000021, -0.399999976, 1, 0, 0, 0, -1, 8.74227766e-008, 0, -8.74227766e-008, -1)
		pirateGunWeld.Name = "PirateGunWeld"
		pirateGunWeld.Parent = leftArm 		
	end 
end 

function onUnequipped()
	if pirateGun then pirateGun:Destroy() end 
	if pirateGunWeld then pirateGunWeld:Destroy() end 
	if shootSound then shootSound:Stop() end
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

while Tool:FindFirstChild("FireGun") == nil do 
	wait()
end

local fireGun = Tool.FireGun

fireGun.Changed:connect(function()
	if fireGun and fireGun.Value == true and myHumanoid and myTorso and pirateGun then 
		local target = myHumanoid.TargetPoint 
		local direction = (target - myTorso.Position).unit 
		shootSound = Sword:FindFirstChild("ShootSound")
		if shootSound then shootSound:Play() end
		shoot(direction)
		wait(1.0)
		fireGun.Value = false 
	end 
end) 
