local Tool = script.Parent
local Gun = Tool.Handle

Tool.Enabled = true 

local minRange = 2
local maxRange = 600

local damage = 20

local gunSound

ray = Instance.new("Part")
ray.FormFactor = 3
ray.Shape = "Ball"
ray.Size = Vector3.new(0.2, 0.2, 0.2)
ray.CanCollide = false
ray.Transparency = 0.7

bullet = Instance.new("SpecialMesh")
bullet.MeshId = "http://www.roblox.com/asset/?id=50876274"
bullet.TextureId = ""
bullet.Parent = ray
bullet.Scale = Vector3.new(0.03, 0.03, 0.03)

local vCharacter

function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

function shoot(pos, target)
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	myTorso = vCharacter:FindFirstChild("Torso")
	if vPlayer == nil or myTorso == nil then 
		return
	end

	spawnPos = myTorso.Position 
	spawnPos = spawnPos+ pos.unit * 5.0

	rayC = ray:Clone()
	rayC.CFrame = CFrame.new(spawnPos, spawnPos + pos)
	rayC.Parent = game.Workspace

	bodyForce = Instance.new("BodyForce")
	bodyForce.force = Vector3.new(0.0, rayC:GetMass() * 196.1, 0.0)
	bodyForce.Parent = rayC

	rayC.Velocity = pos.unit * 500.0

	hit, destination = game.Workspace:FindPartOnRay(Ray.new(Gun.Position + pos*minRange, pos*maxRange), vCharacter) 
	
	if hit then
		if hit.Name == "Head" then damage = 40 else damage = 20 end
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			vChar = hit.Parent
			wait(0.1)
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)		
			wait(0.5)
			untagHumanoid(humanoid)
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if not myTorso then 
		return 
	end

	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if not myHumanoid then 
		return 	
	end

	target  =  myHumanoid.TargetPoint
	direction = (target - Gun.Position).unit

	gunSound = Tool:FindFirstChild("RaygunSound")
	if gunSound then gunSound:Play() end
	shoot(direction, target)
	wait(0.5)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if gunSound then gunSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
