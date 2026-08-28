--[[
	Fixed by ArceusInator.  Now works with FE and has a mobile button for equipping the second kodachi.  Fixed teamkilling.  Fixed an issue with the animation freezing.
--]]

-- Right Sword 51288759 
-- Left Sword 51286923
-- Kodachi without Right Sword 51287154 
-- Sheath Only 51286751
-- Full Kodachi 51237272
-- Texture 51237309

local GLib = require(206209239)

local Tool = script.Parent
local Kodachi = Tool.Handle

local vCharacter 
local swordActive = Tool.SwordActive

Tool.Enabled = true

local Sword

local connection

local hiddenBladeActive = Tool.HiddenBladeActive

local damage = 20

local sheath

local batto = Tool.Batto

function blow(hit)
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	local tPlayer = GLib.GetPlayerFromPart(hit)
	if humanoid ~= nil and humanoid ~= myHumanoid and myHumanoid ~= nil and (not tPlayer or not GLib.IsTeammate(tPlayer, vPlayer)) then 
		rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild('RightHand')
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then 
				tagHumanoid(humanoid, vPlayer)
				if hiddenBladeActive.Value == 0 then damage = 30 else damage = 20 end
				humanoid:TakeDamage(damage)
				wait(1.0)
				untagHumanoid(humanoid)
			end
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
	end
end

function untagHumanoid(humanoid)
	if humanoid then 
		tag = humanoid:FindFirstChild("creator")
		if tag then tag:Remove() end
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
		return
	end
	if swordActive.Value == 0 then
		wait(0.2)
		leftArm = vCharacter:FindFirstChild("Left Arm") or vCharacter:FindFirstChild('LeftHand')
		if leftArm then 
			leftGrip = leftArm:FindFirstChild("LeftGrip")
			if leftGrip then 
				Kodachi.Mesh.MeshId = "http://www.roblox.com/asset/?id=51287154"
			end
		end

		Sword = Instance.new("Part")
		Sword.Name = "Sword"
		Sword.FormFactor = 3
		Sword.Shape = "Block"
		Sword.Size = Vector3.new(0.45, 3, 0.42)
		Sword.CanCollide = false
		
		rightSwordMesh = Instance.new("SpecialMesh")
		rightSwordMesh.Parent = Sword
		rightSwordMesh.MeshId = "http://www.roblox.com/asset/?id=51288759"
		rightSwordMesh.TextureId = "http://www.roblox.com/asset/?id=51237309"
		rightSwordMesh.Scale = Vector3.new(0.6, 0.6, 0.6)

		Sword.Parent = vCharacter

		rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild('RightHand')
		rightGrip = Instance.new("Weld")
		rightGrip.Part0 = rightArm
		rightGrip.Part1 = Sword
		if myHumanoid then
			if myHumanoid.RigType == Enum.HumanoidRigType.R6 then
				rightGrip.C1 = (CFrame.new(Vector3.new(0, 0, 0)) * CFrame.Angles(math.pi/2, 0.0, math.pi/2)) + Vector3.new(-1, -1.25, 0)
			elseif myHumanoid.RigType == Enum.HumanoidRigType.R15 then
				rightGrip.C1 = (CFrame.new(Vector3.new(0, 0, 0)) * CFrame.Angles(math.pi/2, 0.0, math.pi/2)) + Vector3.new(-0.2, -1.25, 0)
			end
		end
		rightGrip.Name = "RightGrip"
		rightGrip.Parent = rightArm
		connection = Sword.Touched:connect(blow)
		swordActive.Value = 1
	end

	wait(1.0)	
	batto.Value = 1
	Tool.Enabled = true 
end

function onEquipped()
--	print("ON EQUIP")
	vCharacter = Tool.Parent
	torso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild('UpperTorso')
	if torso ~= nil then 
		rightArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild('RightHand')
		leftArm = vCharacter:FindFirstChild("Left Arm") or vCharacter:FindFirstChild('LeftHand')
		if rightArm then rightGrip = rightArm:FindFirstChild("RightGrip") end
		if rightGrip then 
			rightGrip.Parent = leftArm
			rightGrip.Name = "LeftGrip"
			rightGrip.Part0 = leftArm
			rightGrip.Part1 = Kodachi	
			rightGrip.C1 = rightGrip.C1 * CFrame.Angles(0, math.pi/2, 0)
		end
	end
end

function onUnequipped()
	if Sword then Sword:Destroy() end

	if connection then connection:disconnect() end
	if Kodachi then 
		Kodachi.Mesh.MeshId = "http://www.roblox.com/asset/?id=51237272" 
		if Kodachi then Kodachi.Transparency = 0.0 end
	end
	if swordActive then swordActive.Value = 0 end
	if batto then batto.Value = 0 end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
