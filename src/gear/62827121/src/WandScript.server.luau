local Tool = script.Parent
local Wand = Tool.Handle

local vCharacter 
local myTorso
local myHumanoid
local vPlayer

local box = Instance.new("Part")
box.FormFactor = 3
box.CanCollide = true
--box.Size = Vector3.new(5, 3, 6.5)
box.Size = Vector3.new(1, 1, 1)

local boxMesh = Instance.new("SpecialMesh")
boxMesh.MeshId = "http://www.roblox.com/asset/?id=62744344"
boxMesh.TextureId = "http://www.roblox.com/asset/?id=62744255"
boxMesh.Parent = box
boxMesh.Scale = Vector3.new(0.8, 0.8, 0.8)

local door = Instance.new("Part")
door.FormFactor = 3
door.CanCollide = true 
--door.Size = Vector3.new(1, 5.5, 6.5)
door.Size = Vector3.new(1, 1, 1)

local screamSound

local doorMesh = Instance.new("SpecialMesh")
doorMesh.MeshId = "http://www.roblox.com/asset/?id=62722732"
doorMesh.TextureId = "http://www.roblox.com/asset/?id=62744255"
doorMesh.Parent = door
doorMesh.Scale = Vector3.new(0.8, 0.8, 0.8)

local ball = Instance.new("Part") 
ball.FormFactor = 3 
ball.Shape = "Block" 
ball.Size = Vector3.new(0.4, 0.4, 0.4) 
ball.CanCollide = false 
ball.Transparency = 0.8

local mesh = Instance.new("SpecialMesh") 
mesh.MeshId = "http://www.roblox.com/asset/?id=57810032" 
mesh.TextureId = "http://www.roblox.com/asset/?id=57809568" 
mesh.Parent = ball 
mesh.Scale = Vector3.new(2, 2, 2) 

local sparkls = Instance.new("Sparkles")
sparkls.Parent = ball
sparkls.SparkleColor = Color3.new(165/255, 0, 33/255)

local activateSpell = Tool:FindFirstChild("ActivateSpell")

local debris = game:GetService("Debris")

while activateSpell == nil do 
	wait()
	activateSpell = Tool:FindFirstChild("ActivateSpell")
end
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
				humanoid:TakeDamage(30)
			end 
		end 
	end 
end 

function fire(direction) 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	if vPlayer == nil then return end 

	local spawnPos = Wand.Position + direction * 3.0 

	local missile = ball:Clone() 
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

function smack(humanoid, weld, box, door, head)
	wait(1.0)
	if weld then
		local initC1 = weld.C1
		for i = 1, 20 do 
			weld.C1 = initC1 * CFrame.Angles(0, 0, -math.pi/40 * i) + Vector3.new(-1/20 * i, 1/6.5 * i, 0)
			wait()
		end
	end
	wait()
	screamSound = Wand:FindFirstChild("ScreamSound")
	if screamSound then screamSound:Play() end
	if humanoid then humanoid:TakeDamage(55) humanoid.WalkSpeed = 16.0 end
	if head then head.Anchored = false end
	wait(1.0)
	if box then box:Remove() end
	if door then door:Remove() end
end

function doom()
	local foundPlayer = false
	activateSpell = Tool:FindFirstChild("ActivateSpell")
	if activateSpell and activateSpell.Value == 1 then 
		if myTorso and myHumanoid then 
			local players = game.Players:GetChildren()
			for i = 1, #players do 
				if players[i] and players[i] ~= vPlayer and players[i].Character and players[i].Character:FindFirstChild("Torso") and players[i].Character:FindFirstChild("Humanoid") then 
					local torso = players[i].Character.Torso
					local head = players[i].Character.Head
					local humanoid = players[i].Character.Humanoid
					local distance = (torso.Position - myTorso.Position).magnitude
					if distance < 40 then 
						foundPlayer = true
						humanoid.WalkSpeed = 0.0						
						local boxClone = box:Clone()
						boxClone.Parent = game.Workspace
						boxClone.CFrame = torso.CFrame
						boxClone.Name = "Box"												

						local boxWeld = Instance.new("Weld")
						boxWeld.Part0 = torso
						boxWeld.Part1 = boxClone
						boxWeld.Parent = boxClone
						boxWeld.C1 = CFrame.new(0, 0, 0.2) * CFrame.Angles(math.pi/2, 0, 0) 
						boxWeld.Name = "BoxWeld"
				
						local doorClone = door:Clone()
						doorClone.Parent = boxClone
						doorClone.Name = "Door"
						
						local doorWeld = Instance.new("Weld")
						doorWeld.Part0 = boxClone 
						doorWeld.Part1 = doorClone
						doorWeld.Parent = doorClone
						doorWeld.C1 = CFrame.new(Vector3.new(1.5, -3, -1.8))
						doorWeld.C1 = doorWeld.C1 * CFrame.Angles(0, math.pi, 0)
						doorWeld.C1 = doorWeld.C1 + Vector3.new(0, 0, 1.8)
						doorWeld.Name = "DoorWeld"

						head.Anchored = true							

						coroutine.resume(coroutine.create(function() smack(humanoid, doorWeld, boxClone, doorClone, head) end))
					end
				end	
				if foundPlayer == true then 
					wait(10.0) 
				else 
					fire((myHumanoid.TargetPoint - Wand.Position).unit)
					wait(3.0)
				end
			end
		end
	
		activateSpell.Value = 0
	end
end

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end

function onUnequipped()
	if screamSound then screamSound:Stop() end
end

Tool.Equipped:connect(onEquipped)

activateSpell.Changed:connect(doom)


