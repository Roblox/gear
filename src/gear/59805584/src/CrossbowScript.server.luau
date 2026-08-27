local Tool = script.Parent
local Bow = Tool.Handle

local vCharacter
local myHumanoid
local myTorso
local vPlayer

Tool.Enabled = true 

local debris = game:GetService("Debris")

local projectile = Instance.new("Part")

local skullDamage = 25

skull = Instance.new("Part")
skull.FormFactor = 3
skull.Shape = "Block"
skull.Size = Vector3.new(0.4, 0.4, 0.4)
skull.CanCollide = false
skull.Transparency = 0.0

bullet = Instance.new("SpecialMesh")
bullet.MeshId = "http://www.roblox.com/asset/?id=57810032"
bullet.TextureId = "http://www.roblox.com/asset/?id=57809568"
bullet.Parent = skull
bullet.Scale = Vector3.new(2,2,2)

skullFire = Instance.new("Fire")
skullFire.Color = Color3.new(153/255, 255/255, 51/255)
skullFire.Parent = skull
skullFire.Size = 2.0
skullFire.Heat = 2.0

local laughSound

local unholyBlast
local blastCo = nil

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		creatorTag.Value = player
		debris:AddItem(creatorTag, 1.5)
	end
end

function pierce(missile, hit)
	if missile then 
		if hit.Parent and hit then 
			if hit.className == "Hat" then 
				humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
			else
				humanoid = hit.Parent:FindFirstChild("Humanoid")
			end
			if humanoid ~= nil and myHumanoid ~= humanoid and myHumanoid ~= nil then 
				tagHumanoid(humanoid, vPlayer)
				if hit.Name == "Head" or hit.className == "Hat" then 
					humanoid:TakeDamage(80) 
				else humanoid:TakeDamage(skullDamage)	end
			end
		end
	end
end

function fire(direction)
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer == nil then return end

	local spawnPos = Bow.Position + direction * 4.0 
	
	local missile = skull:Clone()
	missile.CFrame = CFrame.new(spawnPos, spawnPos + direction)
	missile.Velocity = direction * 90.0 
	missile.RotVelocity = Vector3.new(0, 10, 0)

	local floatForce = Instance.new("BodyForce")
	floatForce.force = Vector3.new(0, missile:GetMass() * 196.1, 0)
	floatForce.Parent = missile
	
	missile.Parent = game.Workspace

	missile.Touched:connect(function(hit) pierce(missile, hit) end)

	debris:AddItem(missile, 5)
end

function wait18()
	wait(18)
	unholyBlast = Tool:FindFirstChild("UnholyBlast")
	unholyBlast.Value = 0
end

function bringTheDoom()
	local sign = 1
	local missiles = {}
	-- freeze Character
	unholyBlast = Tool:FindFirstChild("UnholyBlast")
	print("1")
	if unholyBlast and unholyBlast.Value == 1 and(blastCo == nil or coroutine.status(blastCo) == "dead") then
		print("Do effects")
		blastCo = coroutine.create(wait18)
		coroutine.resume(blastCo)
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		myTorso = vCharacter:FindFirstChild("Torso")
		if myHumanoid == nil or myTorso == nil then 		
			return
		end
		laughSound = Bow:FindFirstChild("Laugh")
		if laughSound then laughSound:Play() end
		
		myTorso.Anchored = true 
		myHumanoid.WalkSpeed = 0.0				
		for i = 1, 40 do 			
			local direction
			if (i-1)%4.0 == 0 then 					
				wait(0.25) 
			end 
			local num = i%5 
			if num == 0 then 
				direction = myTorso.CFrame.lookVector
			else
				direction = CFrame.Angles(0, (num-1) * sign * math.pi/30, 0) * myTorso.CFrame.lookVector 
			end
			local spawnPos = Bow.Position + direction * 4.0
			sign = sign * -1
			
			missiles[i] = skull:Clone()
			missiles[i].CFrame = (CFrame.new(spawnPos, spawnPos + direction)) 
			missiles[i].Velocity = direction * 90.0
			missiles[i].RotVelocity = Vector3.new(0, 10, 0)

			local floatForce = Instance.new("BodyForce")
			floatForce.force = Vector3.new(0, missiles[i]:GetMass() * 196.1, 0)
			floatForce.Parent = missiles[i]
			
			missiles[i].Parent = game.Workspace		

			missiles[i].Touched:connect(function(hit) pierce(missiles[i], hit) end)
			debris:AddItem(missiles[i], 1.75)			
		end
		-- 
		wait(0.75)
		myTorso.Anchored = false
		myHumanoid.WalkSpeed = 16.0
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myTorso == nil or myHumanoid == nil then 
		return
	end

	local target = myHumanoid.TargetPoint
	local direction = (target - Bow.Position).unit
	fire(direction)

	wait(1.25)
	Tool.Enabled = true
end

function onEquipped()
	unholyBlast = Tool:FindFirstChild("UnholyBlast")	
	if unholyBlast then 
		unholyBlast.Changed:connect(bringTheDoom)
	end		
end

function onUnequipped()
	if laughSound then laughSound:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
