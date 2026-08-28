local Tool = script.Parent 
local Blowgun = Tool.Handle 

Tool.Enabled = true 

local debris = game:GetService("Debris") 

part = Instance.new("Part") 
part.Size = Vector3.new(0.8, 0.8, 0.8) 
part.Transparency = 0.0
part.CanCollide = false

local fieldMesh = Instance.new("SpecialMesh") 
fieldMesh.MeshType = "FileMesh" 
fieldMesh.Name = "Mesh" 
fieldMesh.MeshId = "http://www.roblox.com/asset/?id=51319089" 
fieldMesh.TextureId = "http://www.roblox.com/asset/?id=51229975" 
fieldMesh.Scale = Vector3.new(1.2, 1.2, 1.2) 
fieldMesh.Parent = part 

local BlowgunSound 

function shoot(pos) 

	vCharacter = Tool.Parent 

	if vCharacter == nil or vCharacter:FindFirstChild("Humanoid") == nil then 
		 print("Humanoid not found") 
		 return 
	end      

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	if vPlayer == nil then 
		 print("Player not found") 
		 return 
	end 

	randomize = math.random(1, 100)/ 100

	for i =1, 3 do 

		BlowgunSound = Tool:FindFirstChild("BlowgunSound") 
      if BlowgunSound then BlowgunSound:Play() end 

		local dart = part:Clone() 

		local spawnPos = vCharacter.PrimaryPart.Position + Vector3.new((i-1)%2 * randomize, (i-1)%2 * randomize, (i-1)%2 * randomize)
		spawnPos = spawnPos + pos.unit * 5.0 

		dart.CFrame = CFrame.new(spawnPos, spawnPos + pos) * CFrame.Angles(-math.pi/2, 0, 0)
		dart.Velocity = pos * 75.0     
		dart.Name ="dart" 
		dart.Parent = game.Workspace 
		dart.CanCollide = false   

		local dartFloat = Instance.new("BodyForce") 
		dartFloat.force = Vector3.new(0.0, dart:GetMass() * 196.1, 0.0) 
		dartFloat.Parent = dart 

		local creatorTag = Instance.new("ObjectValue") 
		creatorTag.Name = "creator" 
		creatorTag.Value = vPlayer 
		creatorTag.Parent = dart 

		local newScript = Tool:FindFirstChild("OnTouchScript"):Clone() 
		newScript.Disabled = false 
		newScript.Parent = dart 

		debris:addItem(dart, 5) 
		wait(0.2)
	end      
end 

function onActivated() 
		if Tool.Enabled == false then 
			 return 
		end 
		Tool.Enabled = false 

		vCharacter = Tool.Parent 
		myHumanoid = vCharacter:FindFirstChild("Humanoid") 
		if myHumanoid == nil then 
			 print("Humanoid not found") 
			 return 
		end 

		myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
		if myTorso == nil then 
			 print("Torso not found") 
			 return 
		end    

		Tool.GripForward = Vector3.new(0, 1, 0)
		Tool.GripPos = Vector3.new(-0.5, 0, 0)
		Tool.GripRight = Vector3.new(0, 0, -1)
		Tool.GripUp = Vector3.new(1, 0, 0)

		local target = myHumanoid.TargetPoint 
		local lookAt = (target - vCharacter.Head.Position).unit        
		wait(0.5) 
		shoot(lookAt) 
		wait(1.0) 

		Tool.GripUp = Vector3.new(0, 1, 0)
		Tool.GripRight = Vector3.new(1, 0, 0)		
		Tool.GripForward = Vector3.new(0, 0, -1)
		Tool.GripPos = Vector3.new(0, -1, 0)
	
		Tool.Enabled = true 
		end 

function onEquipped() 
end 

function onUnequipped() 
	if BlowgunSound then BlowgunSound:Stop() end 
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped)