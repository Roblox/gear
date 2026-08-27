local Tool = script.Parent
local Gun = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local vPlayer

local shards
local shardFire

local debris = game:GetService("Debris")

local shards

local damage = 20

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end

function blow(hit)
	local humanoid
	if hit and hit.Parent then
		if hit.Parent:IsA("Accessory") and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		else
			humanoid = hit.Parent:FindFirstChild("Humanoid")
		end
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
		end		
	end
end

function fire()	
	shardFire = Tool:FindFirstChild("ShardFire")
	if shardFire and shardFire.Value == 1 then	
		Tool.Enabled = false
		local orbGunSound = Tool:FindFirstChild("OrbGunSound")
		if orbGunSound then orbGunSound:Play() end
		if vCharacter == nil or myTorso == nil or myHumanoid == nil then return end
		shards = vCharacter:FindFirstChild("Shards")
		if shards == nil then return end		
		local target = Tool.ShardFire.pos.Value

		if shards:FindFirstChild("ShardWeld") then 	
			
			shards.ShardWeld:Remove() 
		end			

		if shards:FindFirstChild("FirePart") then 
			damage = 45 
		else 
			damage = 25 
		end
		
		local direction = (target - shards.Position).unit


		local float = Instance.new("BodyForce") --Fix implemented by Luckymaxer
		float.force = direction * shards:GetMass() * 196.20 * 10 + Vector3.new(0, 196.2, 0)*shards:GetMass()
		float.Parent = shards

		shards.CFrame = CFrame.Angles(-math.pi/2, 0, 0) * CFrame.new(Vector3.new(0,2,0), direction) + shards.Position			

		shards.RotVelocity = Vector3.new(0, 0, 15)

		debris:AddItem(shards, 4)
		shards.Touched:connect(blow)

		wait(5.0)
		Tool.Enabled = true
		shardFire.Value = 0
	end
end

function onEquipped()
	local resizeGun = true
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("RightHand")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	local children = vCharacter:GetChildren()
	for i = 1, #children do 
		if children[i].className == "CharacterMesh" and children[i].BodyPart == "RightArm" then 
			resizeGun = false
		end
	end
	--print(resizeGun)
	if resizeGun then 
		Gun.Mesh.Scale = Vector3.new(2, 2, 2)
	end
end

Tool.Equipped:connect(onEquipped)

shardFire = Tool:FindFirstChild("ShardFire")
while shardFire == nil do 
	shardFire = Tool:FindFirstChild("ShardFire")	
	wait()
end

shardFire.Changed:connect(fire)