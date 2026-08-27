vCharacter = script.Parent 

myHumanoid = vCharacter:FindFirstChild("Humanoid") 

myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")

local duration = 3.0

local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
local backpack = nil 

if vPlayer then 
	backpack = vPlayer:FindFirstChild("Backpack") 
end 

local toolInHand = nil 
local backpackItems = {} 

if vCharacter ~= nil and myHumanoid ~= nil and myTorso ~= nil then 
	myHumanoid.WalkSpeed = 0.0 	
	
	local children = vCharacter:GetChildren() 
		for i = 1, #children do 
			if children[i] and children[i]:IsA("Tool") then 
			toolInHand = children[i] 
			toolInHand.Parent = nil 
		end 
	end 

	if backpack then 
		local bChildren = backpack:GetChildren() 
			for j = 1, #bChildren do 
			if bChildren[j] then 
			table.insert(backpackItems, bChildren[j]) 
			bChildren[j].Parent = nil 
			end 
		end 
	end 

	local ice = Instance.new("Part") 
	ice.FormFactor = 3 
	ice.Shape = "Block" 
	ice.Size = Vector3.new(2, 4, 2) 
	ice.CanCollide = true 
	ice.Position = myTorso.Position 
	ice.Transparency = 0.4
	ice.Parent = vCharacter 

	local iceBlockMesh = Instance.new("SpecialMesh") 
	iceBlockMesh.MeshId = "http://www.roblox.com/asset/?id=66876751" 
	iceBlockMesh.TextureId = "http://www.roblox.com/asset/?id=68344795" 
	iceBlockMesh.Scale = Vector3.new(1.0, 1.0, 1.0) 
	iceBlockMesh.Parent = ice 

	local iceWeld = Instance.new("Weld") 
	iceWeld.Parent = myTorso 
	iceWeld.Part0 = myTorso 
	iceWeld.Part1 = ice 
	iceWeld.C1 = CFrame.new(Vector3.new(0, 0, 0)) * CFrame.Angles(math.pi/2, 0, 0) 	
	wait(0.25) 
	myTorso.Anchored = true 
	while duration > 0 do 
		myHumanoid:TakeDamage(3) 
		duration = duration - wait(0.5) 
		wait(0.5) 
	end 
	if ice then ice:Remove() end 
	if iceWeld then iceWeld:Remove() end 
	myHumanoid.WalkSpeed = 16 
	myTorso.Anchored = false 
	if toolInHand then toolInHand.Parent = vCharacter end 
		for a = 1, #backpackItems do 
			if backpackItems[a] then 
			backpackItems[a].Parent = backpack 
		end 
	end 
end 

wait(4) 
script:Remove()