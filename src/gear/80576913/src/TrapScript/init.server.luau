local Trap = script.Parent 
local debounce = false
local vCharacter
local torso

local debris = game:GetService("Debris")

local creatorTag

if Trap.CFrame.lookVector:Dot(Vector3.new(0, 1, 0)) > 0 then Trap.CFrame = Trap.CFrame * CFrame.Angles(0, -math.pi, 0) end

wait(1.5)
Trap.Transparency = 0.9

local burnSound 

function burnAWhile(humanoid, torso)
	local duration = 7
	if humanoid and torso then 
		fire = Instance.new("Fire")
		fire.Parent = torso
		fire.Heat = -1 
		fire.Size = 5 	
		while duration > 0 do 	
			duration  = duration - 1 
			humanoid:TakeDamage(7)
			wait(0.5)
		end
		if fire then fire:Remove() end
	end
end

function tagHumanoid(humanoid)
	if humanoid then 
		creatorTag = script:FindFirstChild("creator")
		if creatorTag then 
			creatorTag.Parent = humanoid 
			debris:AddItem(creator, 2.5) 
		end
	end
end

local lightningPart = Instance.new("Part")
lightningPart.Name = "Lightning"
lightningPart.FormFactor = 3
lightningPart.Size = Vector3.new(1, 1, 10)
lightningPart.Anchored = true

local lightningMesh = Instance.new("SpecialMesh")
lightningMesh.Scale = Vector3.new(1, 1, 1)
lightningMesh.MeshId = "http://www.roblox.com/asset/?id=65419828"
lightningMesh.TextureId = "http://www.roblox.com/asset/?id=65419395"
lightningMesh.Parent = lightningPart


function summonBoltShield()	
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vCharacter == nil or vPlayer == nil then
		return
	end

	for i = 1, 16 do
		local pos = CFrame.Angles(0, i * math.pi/8, 0) * torso.CFrame.lookVector

		local spawnPos = torso.Position
		spawnPos = spawnPos + (pos * 4.25)

		lightningProjectile = lightningPart:Clone()
		lightningProjectile.Name = "rope"
		lightningProjectile.CFrame = CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(-0.872664626, 0, 0)
		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, lightningPart:GetMass() * 196.1, 0)
		floatForce.Parent = lightningProjectile
		lightningProjectile.Velocity = pos * 75.0
		lightningProjectile.Parent = game.Workspace
		--lightningProjectile.Touched:connect(function(hit) blow(lightningProjectile, boltDamage,  hit) end)
		debris:addItem(lightningProjectile, 4)
	end
end

function trapThem(trap, hit)
	if trap == nil or hit == nil or hit.Parent == nil then return end 	
	local humanoid = hit.Parent:FindFirstChild("Humanoid")
	if humanoid and not debounce then 
		vCharacter = humanoid.Parent
		debounce = true		
		humanoid.WalkSpeed = 0.0
		torso = hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso")
		if torso then 
			torso.Anchored = true 
			trap.CFrame = torso.CFrame * CFrame.Angles(-math.pi/2, 0, 0)
			trap.Anchored = true
		end 
		--if trap:FindFirstChild("Mesh") then trap.Mesh.Scale = Vector3.new(0.8, 0.8, 1.3) end 
		trap.Transparency = 0.0 
		--wait(1.5)
		if trap:FindFirstChild("Fire") then
			burnSound = script:FindFirstChild("BurnSound")
			if burnSound then burnSound:Play() end
			summonBoltShield()
			--trap.Fire.Size = 20
		end
		tagHumanoid(humanoid)	
		
		for i = 1, 26 do
			humanoid:TakeDamage((i % 2) + 1)
			if i == 26 then
				wait(0.3)
			elseif i % 2 == 0 then
				wait(0.1)
			else
				wait(0.2)
			end
		end	
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--			
--			
--
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)
--		
--		
--
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--			
--
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)	
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.1)
--		humanoid:TakeDamage(2)		
--		wait(.2)	
--		humanoid:TakeDamage(1)		
--		wait(.3)	
		

		
		
		
		if trap then trap:Destroy() end 
		--coroutine.resume(coroutine.create(function() burnAWhile(humanoid, torso) end))
		if humanoid then humanoid.WalkSpeed = 16.0 end
		if torso then torso.Anchored = false end	
		debounce = false
	end
end

Trap.Touched:connect(function(hit) trapThem(Trap, hit) end)
wait(75) 
if Trap then Trap:Destroy() end
if script then script:Destroy() end
