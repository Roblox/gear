local Tool = script.Parent

local LeftArm = Tool:WaitForChild('LeftArm')
local RightArm = Tool:WaitForChild('RightArm')
local LeftArmMesh = Tool:WaitForChild('ApeArm_Left')
local RightArmMesh = Tool:WaitForChild('ApeArm_Right')

local LeftArmMeshClone
local RightArmMeshClone
local LeftFistClone
local RightFistClone
local LeftFistConnection
local RightFistConnection

local LeftFist = Instance.new('Part')
LeftFist.FormFactor = Enum.FormFactor.Custom
LeftFist.Size = Vector3.new(1.2, 1.6, 1)
LeftFist.Transparency = 1.0
LeftFist.CanCollide = false
local RightFist = LeftFist:Clone()

local LEFT_FIST_C1 = CFrame.new(0.1, 1.86, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local RIGHT_FIST_C1 = CFrame.new(-0.1, 1.86, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

local NORMAL_DAMAGE = 10
local EXTRA_DAMAGE = 20
local NORMAL_FORCE_MAGNITUDE = 2E4
local EXTRA_FORCE_MAGNITUDE = 3E4
local TIME_OF_FORCE = 0.2

local Debris = game:GetService('Debris')

local Anims = {}

local ANIMS_AND_LENGTHS = {
	{name = 'Punch1Anim', length = 2},
	{name = 'Punch2Anim', length = 2},
	{name = 'Punch3Anim', length = 2},
}

local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid.ClassName == 'Humanoid' then
			local unloadedAnim = Tool:FindFirstChild(animationName)
			if unloadedAnim then
				Anims[animationName] = humanoid:LoadAnimation(unloadedAnim)
			end
		end
	end
	if Anims[animationName] then
		Anims[animationName]:Play()
	end
end

local function Stop(animationName)
	if Anims[animationName] then 
		Anims[animationName]:Stop()
	end
end

function OnTouched(torso, part, hasHat)
	local character = part.Parent
	if character:IsA('Accoutrement') then character = character.Parent end
	if character and character:FindFirstChild('Humanoid') and character ~= Tool.Parent and not character:FindFirstChild('ApeArmsDebounce') then
		local humanoid = character.Humanoid
		local debounce = Instance.new('BoolValue')
		debounce.Name = 'ApeArmsDebounce'
		debounce.Parent = character
		Debris:AddItem(debounce, 0.3)
		local tag = Instance.new('ObjectValue')
		tag.Name = 'creator'
		tag.Value = game.Players.LocalPlayer
		tag.Parent = character
		Debris:AddItem(tag, 2)
		
		local shove = Instance.new('BodyForce')
		local offset = part.Position - torso.Position
		local shoveDirection = Vector3.new(offset.x, math.abs(offset.y), offset.z).unit
			
		if hasHat then
			-- extra damage
			humanoid:TakeDamage(EXTRA_DAMAGE)
			shove.force = shoveDirection * EXTRA_FORCE_MAGNITUDE
		else
			humanoid:TakeDamage(NORMAL_DAMAGE)
			shove.force = shoveDirection * NORMAL_FORCE_MAGNITUDE
			print(tostring(shove.force))
		end
		
		shove.Parent = part
		Debris:AddItem(shove, TIME_OF_FORCE)
	end
end

function OnActivated()
	if Tool.Enabled then
		Tool.Enabled = false
		local character = Tool.Parent
		local torso = character:FindFirstChild('Torso')
		local hasHat = character and character:FindFirstChild('KingKingHead')
		if LeftFistClone and not LeftFistConnection then
			if not torso then torso = LeftFistClone end
			LeftFistConnection = LeftFistClone.Touched:connect(function(part)
				OnTouched(torso, part, hasHat)
			end)
		end
		if RightFistClone and not RightFistConnection then
			RightFistConnection = RightFistClone.Touched:connect(function(part)
				if not torso then torso = RightFistClone end
				OnTouched(torso, part, hasHat)
			end)
		end
		
		local randIndex = math.random(#ANIMS_AND_LENGTHS)
		local anim = ANIMS_AND_LENGTHS[randIndex].name
		local length = ANIMS_AND_LENGTHS[randIndex].length
		
		Play(anim)
		if Anims[anim] then
			wait(length)
		end
		LeftFistConnection:disconnect()
		LeftFistConnection = nil
		RightFistConnection:disconnect()
		RightFistConnection = nil
		Tool.Enabled = true	
	end
end


function OnEquipped()
	local character = Tool.Parent
	if character and character:FindFirstChild('Humanoid') and not character:FindFirstChild('ApeArmsTag') then
		local tag = Instance.new('BoolValue')
		tag.Name = 'ApeArmsTag'	-- without this tag, OnEquipped runs infinitely many times. Apparently Equipped fires
								-- when the arm mesh changes?
		tag.Parent = character
		Debris:AddItem(tag, 0.1)
		LeftArm.Transparency = 1.0
		RightArm.Transparency = 1.0

		if character:FindFirstChild('Left Arm') then
			LeftArmMeshClone = LeftArmMesh:Clone()
			LeftArmMeshClone.Parent = character
			LeftFistClone = LeftFist:Clone()
			LeftFistClone.Parent = character
			local leftWeld = Instance.new('Weld')
			leftWeld.Part0 = character['Left Arm']
			leftWeld.Part1 = LeftFistClone
			leftWeld.C0 = CFrame.new()
			leftWeld.C1 = LEFT_FIST_C1
			leftWeld.Name = "FistWeld"
			leftWeld.Parent = character['Left Arm']
		end
		if character:FindFirstChild('Right Arm') then
			RightArmMeshClone = RightArmMesh:Clone()
			RightArmMeshClone.Parent = character
			RightFistClone = RightFist:Clone()
			RightFistClone.Parent = character
			local rightWeld = Instance.new('Weld')
			rightWeld.Part0 = character['Left Arm']
			rightWeld.Part1 = RightFistClone
			rightWeld.C0 = CFrame.new()
			rightWeld.C1 = RIGHT_FIST_C1
			rightWeld.Name = "FistWeld"
			rightWeld.Parent = character['Right Arm']
		end		
		Play('IdleAnim')
	end
end

function OnUnequipped()
	if LeftFistConnection then LeftFistConnection:disconnect() end
	if RightFistConnection then RightFistConnection:disconnect() end
	Tool.Enabled = true
	if LeftArmMeshClone then LeftArmMeshClone:Destroy() end
	if RightArmMeshClone then RightArmMeshClone:Destroy() end 
	LeftArm.Transparency = 0.0
	RightArm.Transparency = 0.0
	Stop('IdleAnim')
	for anim, _ in pairs(Anims) do
		Stop(anim)
	end
end
	

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)

