-----------------
--| Constants |--
-----------------

local SPAWN_RADIUS = 8 -- Studs

local SUMMON_COOLDOWN = 8

local SKELETON_ASSET_ID = 53604463

local SKELETON_DURATION = 30

-----------------
--| Variables |--
-----------------

local InsertService = Game:GetService('InsertService')
local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local MyPlayer = PlayersService.LocalPlayer

local SkeletonScript = script:WaitForChild('SkeletonScript')
local Fire = script:WaitForChild('Fire')
local SummonAnimation = script:WaitForChild('Summon')

local GongSound = ToolHandle:WaitForChild('Gong')

local MyModel = nil
local Skeleton = nil
local LastSummonTime = 0
local SummonTrack = nil

local BodyBits = {
	LeftArm = 131354829,
	LeftLeg = 131354865,
	RightArm = 131354937,
	RightLeg = 131355002,
	Torso = 131355033,
	Hat = 131355308,
}

-----------------
--| Functions |--
-----------------

local function MakeSkeleton()
	Skeleton = InsertService:LoadAsset(SKELETON_ASSET_ID):GetChildren()[1]
	if Skeleton then
		--[[
		for _, child in pairs(Skeleton:GetChildren()) do
			local mesh = child:FindFirstChild('Mesh')
			if mesh then
				DebrisService:AddItem(mesh, 0)
				child.Transparency = 0.5
			end
		end
		--]]
		for _, child in pairs(Skeleton:GetChildren()) do
			if child:IsA('CharacterMesh') or child:IsA('Hat') then
				DebrisService:AddItem(child, 0)
			elseif child:IsA('BasePart') then
				child.Transparency = 0.5
			end
		end
		
		for name, id in pairs(BodyBits) do
			local thing = InsertService:LoadAsset(id):GetChildren()[1]
			thing.Name = name
			thing.Parent = Skeleton
		end
		Skeleton.Name = 'Lost Soul'
		
		local head = Skeleton:FindFirstChild('Head')
		if head then
			head.Transparency = 0.99
		end

		local skeletonScriptClone = SkeletonScript:Clone()
		skeletonScriptClone.Parent = Skeleton
		skeletonScriptClone.Disabled = false

		local creatorTag = Instance.new('ObjectValue')
		creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
		creatorTag.Value = MyPlayer
		local iconTag = Instance.new('StringValue', creatorTag)
		iconTag.Name = 'icon'
		iconTag.Value = Tool.TextureId
		creatorTag.Parent = Skeleton
	end
end

local function SpawnSkeleton(spawnPosition)
	if Skeleton then
		-- Hellfire
		local firePart = Instance.new('Part')
		firePart.Name = 'Effect'
		firePart.Transparency = 1
		firePart.FormFactor = Enum.FormFactor.Custom
		firePart.Size = Vector3.new()
		firePart.Anchored = true
		firePart.CanCollide = false
		firePart.CFrame = CFrame.new(spawnPosition - Vector3.new(0, 4, 0))
		local fireClone = Fire:Clone()
		fireClone.Parent = firePart
		Delay(0.5, function()
			if fireClone then
				fireClone.Enabled = false
			end
		end)
		DebrisService:AddItem(firePart, 3)
		firePart.Parent = Workspace

		-- Spawn
		local skeletonClone = Skeleton:Clone()
		DebrisService:AddItem(skeletonClone, SKELETON_DURATION)
		skeletonClone.Parent = Workspace
		skeletonClone:MoveTo(spawnPosition) --NOTE: Model must be in Workspace

		-- Rise!
		local torso = skeletonClone:FindFirstChild('Torso')
		if torso then
			torso.CFrame = torso.CFrame - Vector3.new(0, 4.5, 0)
			for i = 0, 4.5, 0.45 do
				torso.CFrame = torso.CFrame + Vector3.new(0, i, 0)
				wait(1/30)
			end
		end
	end
end

local function RaiseSkeletons()
	if not Skeleton then -- Try again
		MakeSkeleton()
	end
	for theta = -135, -45, 45 do
		SpawnSkeleton(MyModel.Torso.CFrame:pointToWorldSpace(Vector3.new(math.cos(theta), 0, math.sin(theta)) * SPAWN_RADIUS))
	end
end

--NOTE: Ugly!
local function OnKeyDown(key)
	key = string.lower(key)
	if key == 'e' then
		local now = time()
		if now > LastSummonTime + SUMMON_COOLDOWN then
			LastSummonTime = now
			local humanoid = MyModel:FindFirstChild('Humanoid')
			if humanoid then
				humanoid.WalkSpeed = 0
			end
			Spawn(function()
				for i = 1, 3 do
					if GongSound then GongSound:Play() end
					wait(1.5)
				end
			end)
			if SummonTrack then
				SummonTrack:Play()
				wait(3.125)
			end
			RaiseSkeletons()
			wait(1)
			if humanoid then
				humanoid.WalkSpeed = 16
			end
		end
	end
end

local function OnEquipped(mouse)
	MyModel = Tool.Parent
	mouse.KeyDown:connect(OnKeyDown)

	local humanoid = MyModel:FindFirstChild('Humanoid')
	if humanoid then -- Preload animations
		SummonTrack = humanoid:LoadAnimation(SummonAnimation)
	end
end

local function OnUnequipped()
	if SummonTrack then SummonTrack:Stop() end
end

--------------------
--| Script Logic |--
--------------------

MakeSkeleton()
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
