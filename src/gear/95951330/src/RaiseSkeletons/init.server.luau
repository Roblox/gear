-----------------
--| Constants |--
-----------------

local SPAWN_RADIUS = 8 -- Studs

local SKELETON_ASSET_ID = 53604463

local SKELETON_DURATION = 30

local SUMMON_COOLDOWN = 8

-----------------
--| Variables |--
-----------------

local InsertService = game:GetService('InsertService')
local DebrisService = game:GetService('Debris')
local PlayersService = game:GetService('Players')
local RunService = game:GetService("RunService")

local Tool = script.Parent
local ToolHandle = Tool:WaitForChild("Handle")
local SpawnSkeletonRemote = Tool:WaitForChild("SpawnSkeleton")

local MyPlayer = nil

local SkeletonScript = script:WaitForChild("SkeletonScript")
local Fire = script:WaitForChild("Fire")

local GongSound = ToolHandle:WaitForChild("Gong")

local MyModel = nil
local Skeleton = nil
local LastSummonTime = 0

-----------------
--| Functions |--
-----------------

local function MakeSkeleton()
	Skeleton = InsertService:LoadAsset(SKELETON_ASSET_ID):GetChildren()[1]
	if Skeleton then
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
		fireClone.Enabled = true
		fireClone.Parent = firePart
		delay(0.5, function()
			if fireClone then
				fireClone.Enabled = false
			end
		end)
		DebrisService:AddItem(firePart, 3)
		firePart.Parent = workspace

		-- Spawn
		local skeletonClone = Skeleton:Clone()
		DebrisService:AddItem(skeletonClone, SKELETON_DURATION)
		skeletonClone.Parent = workspace
		skeletonClone:MoveTo(spawnPosition) --NOTE: Model must be in Workspace

		-- Rise!
		local torso = skeletonClone:FindFirstChild('Torso')
		if torso then
			torso.CFrame = torso.CFrame - Vector3.new(0, 4.5, 0)
			for i = 0, 4.5, 0.15 do
				torso.CFrame = torso.CFrame + Vector3.new(0, i, 0)
				RunService.Heartbeat:Wait()
			end
		end
	end
end

local function RaiseSkeletons()
	if not Skeleton then -- Try again
		MakeSkeleton()
	end
	for theta = 72, 360, 72 do
		SpawnSkeleton(MyModel.HumanoidRootPart.CFrame:pointToWorldSpace(Vector3.new(math.cos(theta), 0, math.sin(theta)) * SPAWN_RADIUS))
	end
end

local function OnEquipped(mouse)
	MyModel = Tool.Parent
	
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyModel)
	
	MakeSkeleton()
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:Connect(OnEquipped)

SpawnSkeletonRemote.OnServerEvent:Connect(function(Player)
	local ToolPlayer = PlayersService:GetPlayerFromCharacter(Tool.Parent)
	if ToolPlayer == Player then
		--RaiseSkeletons()
		
		if tick() - LastSummonTime < SUMMON_COOLDOWN then return end
		
		LastSummonTime = tick()
		local humanoid = MyModel:FindFirstChildOfClass('Humanoid')
		if humanoid then
			humanoid.WalkSpeed = 0
		end
		local RaiseAnim = humanoid:LoadAnimation(script:WaitForChild(humanoid.RigType.Name .."Summon"))
		RaiseAnim:Play()
		spawn(function()
			for i = 1, 3 do
				if GongSound then GongSound:Play() end
				wait(1.5)
			end
			RaiseSkeletons()
		end)
		wait(1)
		if humanoid then
			humanoid.WalkSpeed = 16
		end			
	end
end)