local Tool = script.Parent 
local Sword = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 
local vPlayer 
local rightArm
local leftArm

local holster
local leftSword 

Tool.Enabled = true 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false

	if rightArm:FindFirstChild("TorsoGrip") then 
		local rightGrip = rightArm.TorsoGrip
		rightGrip.Name = "RightGrip"
		rightGrip.Part0 = rightArm 
		rightGrip.C1 = CFrame.new(0, 0, -1.3, 0, 0, 1, 1, 0, 0, 0, 1, 0)
	end 

	wait(2.0)

	Tool.Enabled = true
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	rightArm = vCharacter:FindFirstChild("Right Arm")
	leftArm = vCharacter:FindFirstChild("Left Arm")

	if vCharacter:FindFirstChild("Holster") == nil then 
		--[[holster = Instance.new("Part")
		holster.Name = "Holster"
		holster.Parent = vCharacter 
		holster.FormFactor = 3
		holster.Size = Vector3.new(2, 2, 2)	

		local holsterMesh = Instance.new("SpecialMesh")
		holsterMesh.MeshId = "http://www.roblox.com/asset/?id=68254867"
		holsterMesh.TextureId = "http://www.roblox.com/asset/?id=68254909"
		holsterMesh.Scale = Vector3.new(1.1, 1.1, 1.1)
		holsterMesh.Parent = holster 
	
		local holsterGrip = Instance.new("Weld")
		holsterGrip.Parent = holster
		holsterGrip.Part1 = holster 
		holsterGrip.Part0 = myTorso 
		holsterGrip.C1 = CFrame.new(0, 0, 1.2) * CFrame.Angles(math.pi/2, 0, 0)
		holsterGrip.Name = "HolsterGrip"]]
	end 

	while rightArm:FindFirstChild("RightGrip") == nil do 
		wait()
	end 

	if rightArm:FindFirstChild("RightGrip") then 
		local rightGrip = rightArm.RightGrip
		rightGrip.Part0 = myTorso 
		rightGrip.Name = "TorsoGrip"
		Tool.GripPos = Vector3.new(0, 0, 0)
		rightGrip.C1 = CFrame.new(0.369999945, -1.14999998, -0.600000024, 0, -0.669130445, 0.743144751, -1, 1.9490335e-007, 1.75491749e-007, -2.62268344e-007, -0.743144751, -0.669130445)
	end 

	if vCharacter:FindFirstChild("LeftSword") == nil then 
		leftSword = Sword:Clone()
		if leftSword.Mesh then leftSword.Mesh.MeshId = "http://www.roblox.com/asset/?id=68258780" end
		leftSword.Name = "LeftSword"
		leftSword.Parent = vCharacter 		

		local leftGrip = Instance.new("Weld")
		leftGrip.Parent = leftArm 
		leftGrip.Name = "LeftGrip"
		leftGrip.Part0 = myTorso 
		leftGrip.Part1 = leftSword 
		leftGrip.C1 = CFrame.new(-1.03000009, -1.14999986, -1.29999971, 7.07265144e-008, -0.743144751, -0.669130683, 1, 1.93668001e-007, -1.09390982e-007, 2.10882533e-007, -0.669130683, 0.743144751)
	end 
end 

function onUnequipped()
	if holster then holster:Destroy() end 
	if leftSword then leftSword:Destroy() end 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
