-----------------
--| Constants |--
-----------------

local THROWABLE_DAMAGE = 15
local THROWABLE_TIMETOLIVE = 15

local CHANCE_TO_SUMMON = 0.1
local SUMMON_DEBRIS_TIME = 30
local SUMMON_ID = 105428829
local SUMMON_SPAWN_OFFSET = Vector3.new(15, 0, 15)
local AI_SCRIPT_NAME = 'TelamonAi'

local COOLDOWN = 1

-----------------
--| Variables |--
-----------------

local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local InsertService = Game:GetService('InsertService')
local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local ToolHandle = Tool:WaitForChild('Handle')
--local PewPewSound = script:WaitForChild('PewPew')

local AiScript = script:WaitForChild(AI_SCRIPT_NAME)
local CreatorTag = AiScript:WaitForChild('creator')

local MyPlayer = nil
local MyCharacter = nil
local MyHumanoid = nil
local Summon = nil
--local BaseLaser = nil

local PlayerConnections = {}

-----------------
--| Functions |--
-----------------


-- Returns the closest living Humanoid to position who isn't in excludeList
local function FindClosestHumanoid(position, excludeList) -- (Vector3, table)
	if not position then print("Need a Vector3 position") return nil end

	-- Change list values to keys so we can use indexing
	local excludeSet = {}
	if excludeList and type(excludeList) == "table" then
		for _, l in ipairs(excludeList) do
			excludeSet[l] = true
		end
	end

	-- Search through Workspace children
	local closestHumanoid = nil
	for _, child in pairs(Game.Workspace:GetChildren()) do
		if (child and child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and not excludeSet[child.Humanoid])
		and (not closestHumanoid or (child.Humanoid.Torso.Position - position).magnitude < (closestHumanoid.Torso.Position - position).magnitude) then
			closestHumanoid = child.Humanoid
		end
	end
	return closestHumanoid --NOTE: Can be nil
end

-- Removes any old creator tags and applies new ones to the specified target
local function ApplyTags(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end
	local creatorTag = CreatorTag:Clone()
	DebrisService:AddItem(creatorTag, 4)
	creatorTag.Parent = target
end

local function OnThrowableReachedTarget(throwable, targetHumanoid)
	local smackSound = throwable:FindFirstChild('Smack')
	if smackSound then
		smackSound:Play()
	end
	if targetHumanoid.Health > 0 then
		ApplyTags(targetHumanoid)
		targetHumanoid:TakeDamage(THROWABLE_DAMAGE)
	end
	throwable:Destroy()
end

local function PickNewTarget(throwable)
	local homing = throwable:FindFirstChild('Homing')
	if homing then
		local targetHumanoid = FindClosestHumanoid(throwable.Position, {MyHumanoid, PetHumanoid})
		if targetHumanoid and targetHumanoid.Torso then
			local targetHead = targetHumanoid.Parent:FindFirstChild('Head')
			homing.Target = targetHead or targetHumanoid.Torso
			return
		end
		-- Otherwise, fall
		homing:Destroy()
	end
	-- Fall to kill plane
	throwable.CanCollide = false
end

-- Change target when the old target disappears
local function OnTargetModelChanged(targetModel, property, throwable)
	if property == 'Parent' and targetModel.Parent == nil then
		PickNewTarget(throwable)
	end
end

function ThrowLeg(obj)
	local targetHumanoid = FindClosestHumanoid(ToolHandle.CFrame.p, {MyHumanoid})
	if targetHumanoid and targetHumanoid.Torso then
		local targetModel = targetHumanoid.Parent
		local targetHead = targetModel:FindFirstChild('Head')
		Spawn(function()
			
			local throwable = obj
			throwable.CFrame = ToolHandle.CFrame+(ToolHandle.CFrame.lookVector*4)
			throwable.Parent = script.Parent	
			DebrisService:AddItem(throwable, THROWABLE_TIMETOLIVE)
			throwable:WaitForChild('Throw'):Play()
			throwable.Name = 'HomingTurkey'
			local homing = Instance.new('RocketPropulsion')
			homing.Name = 'Homing'
			homing.Target = targetHead or targetHumanoid.Torso
			homing.ReachedTarget:connect(function()
				OnThrowableReachedTarget(throwable, targetHumanoid)
			end)
			targetModel.Changed:connect(function(property)
				OnTargetModelChanged(targetModel, property, throwable)
			end)
			homing.Parent = throwable
			--DebrisService:AddItem(throwable, THROWABLE_TIMETOLIVE)
			throwable.Parent = Workspace
			throwable.Velocity = Vector3.new(0, 50, 0)
			wait(0.5)
			if throwable then
				local projectileSwoosh = throwable:FindFirstChild('Swoosh')
				if projectileSwoosh then
					projectileSwoosh:Play()
				end
				throwable.Size = Vector3.new(0.5, 1, 0.5)
				throwable.CanCollide = true
				homing:Fire()
			end
			
		end)
	end
end

function ThrowTurkey(obj)
	
	local targetHumanoid
	if Summon then	
		targetHumanoid = FindClosestHumanoid(ToolHandle.CFrame.p, {MyHumanoid,Summon:FindFirstChild('Humanoid')})
	else
		targetHumanoid = FindClosestHumanoid(ToolHandle.CFrame.p, {MyHumanoid})
	end
	if targetHumanoid and targetHumanoid.Torso then
		local targetModel = targetHumanoid.Parent
		local targetHead = targetModel:FindFirstChild('Head')
		Spawn(function()
			
			local throwable = obj
			throwable.CFrame = ToolHandle.CFrame+(ToolHandle.CFrame.lookVector*4)
			throwable.Parent = script.Parent	
			
			throwable.Name = 'HomingTurkey'
			local homing = Instance.new('RocketPropulsion')
			homing.Name = 'Homing'
			homing.Target = targetHead or targetHumanoid.Torso
			homing.ReachedTarget:connect(function()
				homing:Destroy()
			end)
			targetModel.Changed:connect(function(property)
				OnTargetModelChanged(targetModel, property, throwable)
			end)
			homing.Parent = throwable
			
			throwable.Parent = Workspace
			throwable.Velocity = Vector3.new(0, 50, 0)
			wait(0.5)
			
			homing:Fire()

			wait(THROWABLE_TIMETOLIVE)
			if throwable.Parent and not throwable.Parent:IsA('Hat') then
				throwable.Parent = nil				
			end
		end)
	end
end




local function OnEquipped()
	MyCharacter = Tool.Parent
	MyHumanoid = MyCharacter:WaitForChild('Humanoid')
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	CreatorTag.Value = MyPlayer
	
	table.insert(PlayerConnections,MyHumanoid.Died:connect(function()
		MyHumanoid = nil
	end))
	
	table.insert(PlayerConnections,PlayersService.PlayerRemoving:connect(function(player)
		if player == MyPlayer then
			MyHumanoid = nil
		end
	end))
end

function MakeTurkey()

	local Turkey = Instance.new("Part")
	Turkey.Anchored = false
	Turkey.CanCollide = false
	Turkey.TopSurface = Enum.SurfaceType.Smooth
	Turkey.Name = "Turkey"
	Turkey.Size = Vector3.new(1.2600009441376, 1.5500005483627, 0.99000000953674)
	Turkey.BottomSurface = Enum.SurfaceType.Smooth
	Turkey.Locked = false

		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshId = "http://www.roblox.com/asset/?id=40311092"
		Mesh.TextureId = "http://www.roblox.com/asset/?id=40311049"
		Mesh.Parent = Turkey
		Mesh.MeshType = Enum.MeshType.FileMesh

		local Fire = Instance.new("Fire")
		Fire.Heat = 25
		Fire.Color = Color3.new(1, 0.8156863451004, 0)
		Fire.Parent = Turkey
		Fire.size = 2
		Fire.Size = 2


	local tscript = script:WaitForChild('TurkeyScript'):Clone()
	tscript.Parent = Turkey
	tscript.Disabled = false
	local ntag = CreatorTag:Clone()
	ntag.Parent = tscript
	
	return Turkey

end

function MakeTurkeyLeg()

	local Throwable = Instance.new("Part")
	Throwable.CanCollide = false
	Throwable.TopSurface = Enum.SurfaceType.Smooth
	Throwable.Color = Color3.new(0.80392163991928, 0.80392163991928, 0.80392163991928)
	Throwable.Name = "Throwable"
	Throwable.Size = Vector3.new(0.2, 0.2, 0.2)
	Throwable.BottomSurface = Enum.SurfaceType.Smooth

		local Mesh = Instance.new("SpecialMesh")
		Mesh.Scale = Vector3.new(0.85, 0.85, 0.85)
		Mesh.MeshId = "http://www.roblox.com/asset/?id=13073626"
		Mesh.TextureId = "http://www.roblox.com/asset/?id=13073598"
		Mesh.Parent = Throwable
		Mesh.MeshType = Enum.MeshType.FileMesh

		local Throw = Instance.new("Sound")
		Throw.Pitch = 2
		Throw.Parent = Throwable
		Throw.Name = "Throw"
		Throw.SoundId = "http://www.roblox.com/asset/?id=105420672"
		Throw.Looped = false

		local Swoosh = Instance.new("Sound")
		Swoosh.Pitch = 2
		Swoosh.Parent = Throwable
		Swoosh.Name = "Swoosh"
		Swoosh.Volume = 0.20000000298023
		Swoosh.SoundId = "rbxasset://sounds/Rocket whoosh 01.wav"
		Swoosh.Looped = true

		local Smack = Instance.new("Sound")
		Smack.Parent = Throwable
		Smack.Name = "Smack"
		Smack.SoundId = "http://www.roblox.com/asset/?id=105424180"
		Smack.Looped = false

	return Throwable

end

local function OnActivated()
	if Tool.Enabled and MyHumanoid.Health > 0 then
		Tool.Enabled = false

		-- Chance to summon
		if (not Summon or Summon.Parent == nil) and math.random() <= CHANCE_TO_SUMMON then
			---[[
			Summon = InsertService:LoadAsset(SUMMON_ID):GetChildren()[1] --NOTE: Cloning causes health problems
			if Summon then
				local aiScriptClone = AiScript:Clone()
				aiScriptClone.Parent = Summon
				aiScriptClone.Disabled = false
				DebrisService:AddItem(Summon, SUMMON_DEBRIS_TIME)
				Summon.Parent = Workspace
				Summon:MoveTo(ToolHandle.Position + SUMMON_SPAWN_OFFSET)
			end
			--]]
		elseif math.random()<=.5 then
			ThrowLeg(MakeTurkeyLeg())
		else
			ThrowTurkey(MakeTurkey())
		end

		-- Pew pew
		local targetPoint = MyHumanoid.TargetPoint
		
		wait(COOLDOWN)
		Tool.Enabled = true
	end
end

local function OnUnequipped()
	if Summon then
		Summon:Destroy()
		Summon = nil
	end
	for _,i in pairs(PlayerConnections) do
		i:disconnect()
	end
	
	PlayerConnections = {}
	
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)






