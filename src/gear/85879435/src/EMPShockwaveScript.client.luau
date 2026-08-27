----- OMG EMP Shockwave -----

-- Convenience vars

local RBX_Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle

-- Character information

local vTorso
local vHumanoid
local vCharacter


-- Shock ball

local shockw = Instance.new("Part")
shockw.CanCollide = false
shockw.Shape = "Ball"
shockw.Size = Vector3.new(3, 3, 3)
shockw.FormFactor = 3
shockw.Transparency = 0.5

local shockMesh = Instance.new("SpecialMesh")
shockMesh.MeshId = "http://www.roblox.com/asset/?id=54068514"
shockMesh.VertexColor = Vector3.new(0.3, 0.5, 1)
shockMesh.TextureId = "http://www.roblox.com/asset/?id=54068645"
shockMesh.Scale = Vector3.new(2, 2, 2)
shockMesh.Parent = shockw

local float = Instance.new("BodyForce")
float.force = Vector3.new(0, shockw:GetMass() * 196.1, 0)
float.Name = "float"
float.Parent = shockw

local animTrack

local onCooldown = false

-- Sound info
local errorSound = Instance.new("Sound")
errorSound.SoundId = "http://www.roblox.com/asset/?id=85715077"
errorSound.Parent = Handle

local zapSound = Instance.new("Sound")
zapSound.SoundId = "http://www.roblox.com/asset/?id=85718743" --85715631"
zapSound.Parent = Handle

local armingSound = Instance.new("Sound")
armingSound.SoundId = "http://www.roblox.com/asset/?id=85727902"
armingSound.Parent = Handle

local criticalErrorSound = Instance.new("Sound")
criticalErrorSound.SoundId = "http://www.roblox.com/asset/?id=85749189"
criticalErrorSound.Parent = Handle

function empShockwave()
		zapSound:Play()

		vTorso.Anchored = true
		
		sw = shockw:Clone()		
		sw.Position = vTorso.Position - Tool.GripPos
		sw.Parent = vCharacter
		sw.RotVelocity = Vector3.new(0, 10, 0)		
		
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)					
		players = game.Players:GetChildren()
		if #players > 1 then 
			for i = 1, #players do 
				if players[i] ~= vPlayer then 
					tempChar = players[i].Character
					if tempChar then
						tempTorso = tempChar:FindFirstChild("Torso")
						if tempTorso then
							distance = (tempTorso.Position - vTorso.Position).magnitude
							if distance < 100 then
								local cChildren = tempChar:GetChildren()
								for i = 1, #cChildren do 
									if cChildren[i]:IsA("Tool")then
										cChildren[i].Parent = game.Workspace
										-- Add some sparkles so they know they got zapped
										local sparkleHolder = Instance.new("Part")
										sparkleHolder.Position = tempChar:FindFirstChild("Right Arm").Position
										sparkleHolder.Transparency = 1
										sparkleHolder.Anchored = true
								     sparkleHolder.Parent = tempChar
										sparkleHolder.CanCollide = false
										local sparkles = Instance.new("Sparkles")
										sparkles.Parent = sparkleHolder
										RBX_Debris:AddItem(sparkleHolder, 2.5)
									end
								end
							end
						end
					end
				end
			end
		end
	
		for i = 1, 20 do 			
			sw.Mesh.Scale = sw.Mesh.Scale + Vector3.new(1, 1, 1)
			sw.RotVelocity = sw.RotVelocity * i
			wait(0.1)			
		end			
		
		vTorso.Anchored = false
		if sw then sw:Remove() end
end


function selfDestruct()
	criticalErrorSound:Play()
	wait(1.5)
	local explosion = Instance.new("Explosion", Workspace)
	explosion.Position = vCharacter:FindFirstChild("Right Arm").Position
	explosion.BlastPressure = 10
	explosion.BlastRadius = 20
	explosion.ExplosionType = Enum.ExplosionType.CratersAndDebris
end

function resetCooldown(cooldownTime)
	Tool.Enabled = false
	wait(cooldownTime)
	onCooldown = false
	Tool.Enabled = true
end

function incrementInDirection(incrementVector, times)
	local i = 0
	while i < times and wait() do
		i = i + 1
		Tool.GripPos = Tool.GripPos + incrementVector
	end
end

function onActivated()
	if onCooldown then 
		-- play on cooldown sound
		errorSound:Play()
		return
	end
	onCooldown = true
	local cooldownCo = coroutine.create(resetCooldown)
	coroutine.resume(cooldownCo, 15)


	armingSound:Play()
	local animTrack = vHumanoid:LoadAnimation(Tool.ArmAnimation)
	animTrack:Play()
	wait(1.5)
	animTrack:Stop()
	
	if math.random(1, 10) == 1 then --explode
		selfDestruct()
	else
		incrementInDirection(Vector3.new(0, -0.5, 0), 15)
	
		empShockwave()

		armingSound:Play()
		animTrack:Play()
		incrementInDirection(Vector3.new(0, 0.5, 0), 15)
	end
	
end


function onEquip()
	vTorso = Tool.Parent:FindFirstChild("Torso")
	vHumanoid = Tool.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
end


function onUnequip()
	-- If they drop the item early, make sure to unanchor them so they aren't stuck
	vTorso.Anchored = false
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquip)
script.Parent.Unequipped:connect(onUnequip)
