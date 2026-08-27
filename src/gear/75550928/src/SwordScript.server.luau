local Tool = script.Parent
local Sword = Tool.Handle

local shield
local shieldMesh

local vCharacter

local damage = 12

Tool.Enabled = true

local debris = game:GetService("Debris")

local chanceToBreak = 4 -- Wooden Swords have a 4% of breaking your bones, true story!

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
				if math.random(1, 100) <= chanceToBreak then 
					if hit then hit:BreakJoints() end
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
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		return
	end
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
		shieldMesh.MeshId = "http://www.roblox.com/asset/?id=75521015"
		shieldMesh.Scale = Vector3.new(1.3, 1.3, 1.3)
		shieldMesh.Name = "Mesh"
		shieldMesh.TextureId = "http://www.roblox.com/asset/?id=75521030"
		shieldMesh.Parent = shield		

		shieldWeld = Instance.new("Weld")
		shieldWeld.Part0 = torso
		shieldWeld.Part1 = shield
		shieldWeld.Name = "ShieldHolder"
		shieldWeld.C1 =  CFrame.new(0.100000061, 1.49011612e-008, -0.550000012, 1.31134158e-007, 1, 8.74227837e-008, -1, 1.31134158e-007, -8.74227695e-008, -8.74227766e-008, -8.74227695e-008, 1)
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
Tool.Activated:connect(onActivated)
Sword.Touched:connect(blow)