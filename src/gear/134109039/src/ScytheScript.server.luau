-----------------
--| Constants |--
-----------------

local HIT_DAMAGE = 20
local LIMB_DEBRIS_TIME = 4 --NOTE: Should be less than respawn time

local SLASH_COOLDOWN = 0.7

local IGNORE_LIST = {torso = 1, handle = 1, effect = 1, water = 1} --NOTE: Keys must be lowercase, values must evaluate to true

-- Scythe special vars
local GRAVE_ASSET_ID = 134082925
local GRAVE_DEBOUNCE_MIN = 4
local GRAVE_EXPAND_TIME = 1.5
local GRAVE_HIT_DMG = 30
local GRAVE_HIT_DEBOUNCE = 0.1

-----------------
--| Variables |--
-----------------

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')
local InsertService = Game:GetService('InsertService')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local MyModel = nil
local MyPlayer = nil

-- Scythe special vars
local LastGraveAttack = tick()
local FudgeFactor = math.random() * 3

local Grave = InsertService:LoadAsset(GRAVE_ASSET_ID):GetChildren()[1]

local GongSound = ToolHandle:WaitForChild('Gong')

-------------------------
--| Utility Functions |--
-------------------------

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
	creatorTag.Value = MyPlayer
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats

	local iconTag = Instance.new('StringValue')
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	iconTag.Parent = creatorTag
	creatorTag.Parent = target
	DebrisService:AddItem(creatorTag, 4)
end

local function Burninate(target, color, secondaryColor, debrisTime)
	local fire = Instance.new('Fire')
	fire.Color = color
	fire.SecondaryColor = secondaryColor
	DebrisService:AddItem(fire, debrisTime)
	fire.Parent = target
end

-----------------------
--| Other Functions |--
-----------------------

local function OnTouched(otherPart)
	if otherPart and not IGNORE_LIST[string.lower(otherPart.Name)] then
		local character, humanoid = FindCharacterAncestor(otherPart)
		if character and humanoid and character ~= MyModel then
			ApplyTags(humanoid)
			humanoid:TakeDamage(HIT_DAMAGE)
			if humanoid.Health > 0 and humanoid.Torso then -- Cut limbs
				for _, child in pairs(humanoid.Torso:GetChildren()) do
					if child:IsA('JointInstance') and (child.Part0 == otherPart or child.Part1 == otherPart) then
						child:Destroy()
						DebrisService:AddItem(otherPart, LIMB_DEBRIS_TIME)
						otherPart.Parent = Workspace
						otherPart.CanCollide = true
					end
				end
			end
		end
	end
end

-- Special Scythe attack
local function GraveAttack(character, startCFrame)
	--print("SPECIAL GRAVE ATTACK!")
	local playerHumanoid = character:FindFirstChild('Humanoid')

	-- Create the blast sphere
	local blast = Instance.new('Part')
	blast.Shape = Enum.PartType.Ball
	blast.FormFactor = Enum.FormFactor.Custom
	blast.Size = Vector3.new(0.2, 0.2, 0.2)
	blast.BrickColor = BrickColor.new(0, 0, 0)
	blast.TopSurface = Enum.SurfaceType.Smooth
	blast.BottomSurface = Enum.SurfaceType.Smooth
	blast.Transparency = 0.7
	blast.Anchored = true
	blast.CFrame = startCFrame
	DebrisService:AddItem(blast, GRAVE_EXPAND_TIME)
	blast.Parent = character

	-- Connect the damage-giving
	local hitList = {}
	blast.Touched:connect(function(otherPart)
		local enemy, enemyHumanoid = FindCharacterAncestor(otherPart)
		if enemy and enemyHumanoid and enemy.Name ~= 'Lost Soul' then
			local now = tick()
			local hitData = hitList[enemy]
			if not hitData or now - hitData.LastHitTime > GRAVE_HIT_DEBOUNCE then
				local damage = GRAVE_HIT_DMG
				--print("GRAVE attack - Damaging", enemy, "for", damage, "damage")
				ApplyTags(enemyHumanoid)
				enemyHumanoid:TakeDamage(damage)
				hitList[enemy] = {LastHitTime = now, LastHitPosition = enemyHumanoid.Torso.Position}
				Burninate(enemyHumanoid.Torso, Color3.new(0, 0, 0), Color3.new(1, 1, 1), GRAVE_EXPAND_TIME)
				if playerHumanoid then
					--print("GRAVE healing for:", damage)
					playerHumanoid:TakeDamage(-damage)
					Burninate(playerHumanoid.Torso, Color3.new(1, 1, 1), Color3.new(0, 0, 0), GRAVE_EXPAND_TIME)
				end
			end
		end
	end)

	-- Keep player in place
	local torso = character:FindFirstChild('Torso')
	if torso then
		torso.Anchored = true
		Delay(GRAVE_EXPAND_TIME + 0.1, function()
			torso.Anchored = false
		end)
	end

	-- Expand the blast sphere
	local startTime = tick()
	repeat
		wait()
		blast.Size = blast.Size + Vector3.new(1.7, 1.7, 1.7)
		blast.CFrame = startCFrame
	until tick() - startTime >= GRAVE_EXPAND_TIME

	-- Bury the dead
	Delay(0.5, function()
		for enemy, hitData in pairs(hitList) do
			local humanoid = enemy:FindFirstChild('Humanoid')
			if humanoid and humanoid.Health <= 0 then
				local grave = Grave:Clone()
				grave:TranslateBy(hitData.LastHitPosition + Vector3.new(0, 1, 0) - grave:GetModelCFrame().p)
				if grave.PrimaryPart then
					local bodyGyro = grave.PrimaryPart:FindFirstChild('BodyGyro')
					if bodyGyro then
						local position = grave.PrimaryPart.Position
						local lookAtPoint = Vector3.new(startCFrame.p.X, position.Y, startCFrame.p.Z)
						bodyGyro.cframe = CFrame.new(position, lookAtPoint)
					end
				end
				DebrisService:AddItem(grave, 30)
				grave.Parent = enemy.Parent
				enemy:Destroy()
				Spawn(function()
					local gong = GongSound:Clone()
					gong.Pitch = 0.9
					gong.Parent = grave.PrimaryPart
					wait(0.5 + math.random())
					gong:Play()
				end)
			end
		end
	end)
end

local function OnEquipped()
	MyModel = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
	LastGraveAttack = tick()
end

local function OnActivated()
	if Tool.Enabled and MyModel:FindFirstChild('Humanoid') and MyModel.Humanoid.Health > 0 then
		Tool.Enabled = false --NOTE: Starts the animation

		local connection = ToolHandle.Touched:connect(OnTouched)
		Delay(0.4, function() --NOTE: Hardcoded length of animation :[
			if connection then
				connection:disconnect()
			end
		end)

		local slashSound = ToolHandle:FindFirstChild('SwordSlash')
		if slashSound then
			slashSound:Play()
		end

		if tick() - LastGraveAttack > GRAVE_DEBOUNCE_MIN + FudgeFactor then -- (Every 4-7 seconds)
			GraveAttack(MyModel, ToolHandle.CFrame)
			LastGraveAttack = tick()
			FudgeFactor = math.random() * 4
		end

		wait(SLASH_COOLDOWN)

		Tool.Enabled = true
	end
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
