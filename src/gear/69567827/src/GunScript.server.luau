local Tool = script.Parent 
local Gun = Tool.Handle 

Tool.Enabled = true 

local damage = 20 

local gunSound 
local vCharacter 
local vPlayer 
local myTorso 
local myHumanoid 

local debris = game:GetService("Debris")

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
		shieldMesh.MeshId = "http://www.roblox.com/asset/?id=69486628"
		shieldMesh.Scale = Vector3.new(1.1, 1.1, 1.1)
		shieldMesh.Name = "Mesh"
		shieldMesh.TextureId = "http://www.roblox.com/asset/?id=69486552"
		shieldMesh.Parent = shield		

		shieldWeld = Instance.new("Weld")
		shieldWeld.Part0 = torso
		shieldWeld.Part1 = shield
		shieldWeld.Name = "ShieldHolder"
		--shieldWeld.C1 =  CFrame.Angles(-math.pi/2, math.pi, 0) * CFrame.new(Vector3.new(0, 0.2, -0.8))
		shieldWeld.C1 =  CFrame.Angles(-math.pi/2, 0, math.pi) * CFrame.new(Vector3.new(0, 0.2, -0.8))
		shieldWeld.Parent = torso			
	end
end

function onUnequipped()	
	if vCharacter then 
		torso = vCharacter:FindFirstChild("Torso")
		if torso then 
			shield = vCharacter:FindFirstChild("Shield") 
			shieldWeld = torso:FindFirstChild("ShieldHolder")
		end
	end 
	if shield then shield:Remove() end
	if shieldWeld then shieldWeld:Remove() end
	
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)