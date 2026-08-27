-- Sword and shield
-- shield damage 12, sword damage 18
-- health increased by 75, movement speed decreased by 2

local Tool = script.Parent
local Sword = Tool.Handle

local shield
local shieldMesh

local vCharacter

local damage = 16

Tool.Enabled = true

local debris = game:GetService("Debris")

function blow(hit)   -- For the Sword
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then 
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				tick()
				if math.random() < 0.4 then 
					local rightArm = humanoid.Parent:FindFirstChild("Right Arm")
					if rightArm then 
						local rightWeld = rightArm:FindFirstChild("RightGrip")
						if rightWeld then rightWeld:Remove() end
					end
				end	
				if myHumanoid.Health + 1.5 <  myHumanoid.MaxHealth then 
					myHumanoid.Health = myHumanoid.Health + 1.5
				end
			end
		end
	end
end


function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1) 
	end
end

function onActivated()
	if Tool.Enabled == false then
		return 
	end
	Tool.Enabled = false
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		return
	end
	
	wait(0.5)
	Tool.Enabled = true

end

function onEquipped()
	print("On Equip")
	vCharacter = Tool.Parent
	torso = vCharacter:FindFirstChild("Torso")	
	if vCharacter:FindFirstChild("Shield") == nil and torso ~= nil then

		shield = Instance.new("Part")
		shield.FormFactor = 3
		shield.Name = "Shield"
		shield.Size = Vector3.new(2, 0.2, 4)
		shield.Shape = "Block"	
		shield.Parent = vCharacter
		shield.CanCollide = false

		shieldMesh = Instance.new("SpecialMesh")
		shieldMesh.MeshId = "http://www.roblox.com/asset/?id=64862624"
		shieldMesh.Scale = Vector3.new(1, 1, 1)
		shieldMesh.Name = "Mesh"
		shieldMesh.TextureId = "http://www.roblox.com/asset/?id=64862642"
		shieldMesh.Parent = shield		

		shieldWeld = Instance.new("Weld")
		shieldWeld.Part0 = torso
		shieldWeld.Part1 = shield
		shieldWeld.Name = "ShieldHolder"
		shieldWeld.C1 =  CFrame.Angles(math.pi/2, math.pi, 0) * CFrame.new(Vector3.new(0, 0.2, -0.7))
		shieldWeld.Parent = torso			
	end
end

function onUnequipped()
	torso = vCharacter:FindFirstChild("Torso")
	if torso then 
		shield = vCharacter:FindFirstChild("Shield") 
		shieldWeld = torso:FindFirstChild("ShieldHolder")
	end
	if shield then shield:Remove() end
	if shieldWeld then shieldWeld:Remove() end
	
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
--Tool.Activated:connect(onActivated)
Sword.Touched:connect(blow)