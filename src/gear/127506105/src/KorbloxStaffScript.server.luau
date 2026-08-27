-----------------
--| Constants |--
-----------------

local COOLDOWN = 4
local DAMAGE = 1000
local BOOM_DAMAGE = 100
local BOOM_SIZE = 24

-----------------
--| Variables |--
-----------------

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')

local Character = nil
local Humanoid = nil
local Torso = nil
local Player = nil

local EffectPart = nil
local Connections = {}

-----------------
--| Functions |--
-----------------

-- Returns a character ancestor and its Humanoid, or nil
local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

-- Removes any old creator tags and applies new ones to the specified target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end

	local creatorTag = Instance.new('ObjectValue')
	creatorTag.Value = Player
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats

	local iconTag = Instance.new('StringValue')
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	iconTag.Parent = creatorTag
	creatorTag.Parent = target
	DebrisService:AddItem(creatorTag, 4)
end

local function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:WaitForChild('Humanoid')
	Torso = Character:WaitForChild('Torso')
	Player = PlayersService:GetPlayerFromCharacter(Character)

	-- Create effects
	EffectPart = Instance.new('Part')
	EffectPart.Name = 'Effect'
	EffectPart.FormFactor = Enum.FormFactor.Custom
	EffectPart.Size = Vector3.new(0, 0, 0)
	EffectPart.BottomSurface = Enum.SurfaceType.Smooth
	EffectPart.TopSurface = Enum.SurfaceType.Smooth
	EffectPart.Transparency = 1
	EffectPart.CanCollide = false
	local fire = Instance.new('Fire')
	fire.Size = 2
	fire.Heat = 25
	fire.Color = Color3.new(0.235294, 0.709804, 0.709804)
	fire.SecondaryColor = Color3.new(0, 0, 0)
	fire.Parent = EffectPart
	local pointLight = Instance.new('PointLight')
	pointLight.Color = Color3.new(0, 1, 1)
	pointLight.Brightness = 1
	pointLight.Range = 8
	pointLight.Parent = EffectPart
	local weld = Instance.new('Weld')
	weld.Part0 = Handle
	weld.Part1 = EffectPart
	weld.C0 = CFrame.Angles(math.pi / 2, 0, 0) + Vector3.new(0, 0, 3)
	weld.Parent = EffectPart
	EffectPart.Parent = Handle
end

local function PleaseStop(part)
	if part then
		part.Anchored = true
		part.Velocity = Vector3.new(0,0,0)
		part.RotVelocity = Vector3.new(0,0,0)
		part.CFrame = part.CFrame + Vector3.new(0, 0.001, 0)
	end
end

local function OnSpearTouched(spear, otherPart, startPoint, index)
	if spear and otherPart and startPoint then
		Connections[index]:disconnect()
		local wooshSound = spear:FindFirstChild('Woosh')
		if wooshSound then
			wooshSound:Play()
		end

		local effectPart = spear:FindFirstChild(EffectPart.Name)
		PleaseStop(spear)
		spear.CFrame = spear.CFrame + Vector3.new(0, 4, 0)
		if effectPart then
			PleaseStop(effectPart)
			effectPart.CFrame = effectPart.CFrame + Vector3.new(0, 4, 0)
		end

		--[[
		local weld = Instance.new('Weld')
		weld.Part0 = otherPart
		weld.Part1 = spear
		weld.C0 = CFrame.Angles(math.pi / 2, 0, 0) + (spear.Position - otherPart.Position)
		weld.Parent = spear
		]]

		local ray = Ray.new(startPoint, (spear.Position - startPoint).unit * 999)
		local hitPart, hitPoint = Workspace:FindPartOnRay(ray, spear)
		spear.CFrame = spear.CFrame - spear.CFrame.p + hitPoint + Vector3.new(0, 2, 0)
		if effectPart then
			local weld = effectPart:FindFirstChild('Weld')
			if weld then
				effectPart.CFrame = spear.CFrame * weld.C0
			end
		end
			

		if hitPart then
			local character, humanoid = FindCharacterAncestor(hitPart)
			if character and humanoid then
				ApplyTags(humanoid)
				humanoid:TakeDamage(DAMAGE)
			end
			wait(2)
			if effectPart then
				local fire = effectPart:FindFirstChild('Fire')
				if fire then
					fire.Size = fire.Size * 2
				end
				local pointLight = effectPart:FindFirstChild('PointLight')
				if pointLight then
					pointLight.Range = pointLight.Range * 2
				end
			end
			wait(2)
			-- Boom
			local boomSound = spear:FindFirstChild('Boom')
			if boomSound then
				boomSound:Play()
			end
			local size = Vector3.new(BOOM_SIZE, BOOM_SIZE, BOOM_SIZE) / 2
			local region = Region3.new(spear.Position - size, spear.Position + size)
			local parts = Workspace:FindPartsInRegion3(region, spear, 100)
			for _, part in pairs(parts) do
				local character, humanoid = FindCharacterAncestor(part)
				if character and humanoid and character ~= Character then
					ApplyTags(humanoid)
					humanoid:TakeDamage(BOOM_DAMAGE)
				end
			end
			for i = 1, 5 do
				if effectPart then
					local effectClone = effectPart:Clone()
					effectClone.CanCollide = true
					effectClone.Anchored = false
					effectClone.Velocity = Vector3.new(math.random(), math.random() * 5, math.random())
					DebrisService:AddItem(effectClone, 1)
					effectClone.Parent = Workspace
				end
			end
			DebrisService:AddItem(spear, 0)
		end
	end
end

local function OnActivated()
	if Tool.Enabled and Humanoid.Health > 0 then
		Tool.Enabled = false

		wait(1)
		Connections = {}
		for i = 1, 12 do
			if Tool.Parent == Character then
				local handleClone = Handle:Clone()
				handleClone.Name = 'Effect'
				local startCFrame = (Torso.CFrame * CFrame.Angles(-math.pi / 2, 0, 0)) + (Torso.CFrame.lookVector * 10 * i) + Vector3.new(0, 100, 0)
				handleClone.CFrame = startCFrame
				handleClone.Velocity = Vector3.new(0, -200, 0)
				handleClone.RotVelocity = Vector3.new(0, 8, 0)
				handleClone.CanCollide = false
				Connections[i] = handleClone.Touched:connect(function(otherPart)
					OnSpearTouched(handleClone, otherPart, startCFrame.p, i)
				end)
				DebrisService:AddItem(handleClone, 8)
				handleClone.Parent = Workspace
			end
			wait(0.25)
		end

		wait(COOLDOWN)
		Tool.Enabled = true
	end
end

local function OnUnequipped()
	EffectPart:Destroy()
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)
