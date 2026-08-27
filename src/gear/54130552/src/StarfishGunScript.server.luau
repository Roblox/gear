local Tool = script.Parent
local Gun = Tool.Handle

local vCharacter
local myTorso

local gunSound

local debris = game:GetService("Debris")

Tool.Enabled = true

local starfish = Instance.new("Part")
starfish.Size = Vector3.new(0.5, 0.5, 0.5)
starfish.FormFactor = 3
starfish.CanCollide = false
starfish.Shape = "Block"

starfishMesh = Instance.new("SpecialMesh")
starfishMesh.MeshId = "http://www.roblox.com/asset/?id=54036122"
starfishMesh.TextureId = "http://www.roblox.com/asset/?id=54035123"
starfishMesh.Scale = Vector3.new(1.5 ,1.5 ,1.5)
starfishMesh.Parent = starfish


local float = Instance.new("BodyForce")
float.force = Vector3.new(0.0, starfish:GetMass() * workspace.Gravity, 0.0)
float.Name = "Floating"

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creator = Instance.new("ObjectValue")
		creator.Value = player
		creator.Name = "creator"
		creator.Parent = humanoid
		debris:addItem(creator, 1)
	end
end

function poison(starfishProjectile, hit)
	if hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
	end
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then  		
		tagHumanoid(humanoid, vPlayer)
		humanoid:TakeDamage(15)
		poisonScript = humanoid.Parent:FindFirstChild("StarPoisonScript")
		if poisonScript == nil then
			poisonScript = Tool.StarPoisonScript:Clone()
			poisonScript.Parent = humanoid.Parent
			poisonScript.Disabled = false			
		end
		if starfishProjectile then starfishProjectile:Destroy() end
	end
end

function shoot(pos)
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vCharacter == nil or vPlayer == nil then 
		return
	end

	local spawnPos = vCharacter.HumanoidRootPart.Position
	spawnPos = spawnPos + (pos * 5.0)
	
	starfishProjectile = starfish:Clone()
	starfishProjectile.Name = "Ammo"
	starfishProjectile.CFrame = CFrame.new(spawnPos, spawnPos + pos)

	floatForce = float:Clone()
	floatForce.Parent = starfishProjectile
	starfishProjectile.Velocity = pos * 65.0	
	
	starfishProjectile.Parent = game.Workspace

	starfishProjectile.Touched:connect(function(hit) poison(starfishProjectile, hit) end)

	debris:addItem(starfishProjectile, 50)
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	if myHumanoid == nil or myTorso == nil then 
		return
	end

	target = myHumanoid.TargetPoint 
	direction = (target - myTorso.Position).unit
	shoot(direction)

	wait(2.0)
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
