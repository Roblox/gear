--Made by Luckymaxer

-----------------
--| Constants |--
-----------------

CHANCE_TO_SUMMON = 0.1
SUMMON_DEBRIS_TIME = 120
SUMMON_ID = 149633637
SUMMON_SPAWN_OFFSET = Vector3.new(15, 0, 15)
AI_SCRIPT_NAME = "LeprechaunAi"

COOLDOWN = 1

-----------------
--| Variables |--
-----------------

InsertService = Game:GetService("InsertService")
Players = Game:GetService("Players")
Debris = Game:GetService("Debris")

Tool = script.Parent
ToolHandle = Tool:WaitForChild("Handle")
AiScript = script:WaitForChild(AI_SCRIPT_NAME)
CreatorTag = AiScript:WaitForChild("creator")

MyPlayer = nil
MyCharacter = nil
MyHumanoid = nil
Summon = nil
--BaseLaser = nil

PlayerConnections = {}

-----------------
--| Functions |--
-----------------


-- Returns the closest living Humanoid to position who isn"t in excludeList
function FindClosestHumanoid(position, excludeList) -- (Vector3, table)
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
function ApplyTags(target)
	while target:FindFirstChild("creator") do
		target.creator:Destroy()
	end
	local creatorTag = CreatorTag:Clone()
	Debris:AddItem(creatorTag, 4)
	creatorTag.Parent = target
end

function OnThrowableReachedTarget(throwable, targetHumanoid)
	local smackSound = throwable:FindFirstChild("Smack")
	if smackSound then
		smackSound:Play()
	end
	if targetHumanoid.Health > 0 then
		ApplyTags(targetHumanoid)
		targetHumanoid:TakeDamage(THROWABLE_DAMAGE)
	end
	throwable:Destroy()
end

function PickNewTarget(throwable)
	local homing = throwable:FindFirstChild("Homing")
	if homing then
		local targetHumanoid = FindClosestHumanoid(throwable.Position, {MyHumanoid, PetHumanoid})
		if targetHumanoid and targetHumanoid.Torso then
			local targetHead = targetHumanoid.Parent:FindFirstChild("Head")
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
function OnTargetModelChanged(targetModel, property, throwable)
	if property == "Parent" and targetModel.Parent == nil then
		PickNewTarget(throwable)
	end
end

function OnEquipped()
	MyCharacter = Tool.Parent
	MyHumanoid = MyCharacter:WaitForChild("Humanoid")
	MyPlayer = Players:GetPlayerFromCharacter(MyCharacter)
	CreatorTag.Value = MyPlayer
	
	table.insert(PlayerConnections,MyHumanoid.Died:connect(function()
		MyHumanoid = nil
	end))
	
	table.insert(PlayerConnections,Players.PlayerRemoving:connect(function(player)
		if player == MyPlayer then
			MyHumanoid = nil
		end
	end))
end

function OnActivated()
	if Tool.Enabled and MyHumanoid.Health > 0 then
		Tool.Enabled = false

		-- Chance to summon
		if (not Summon or Summon.Parent == nil) then
			---[[
			Summon = InsertService:LoadAsset(SUMMON_ID):GetChildren()[1] --NOTE: Cloning causes health problems
			if Summon then
				local aiScriptClone = AiScript:Clone()
				aiScriptClone.Parent = Summon
				aiScriptClone.Disabled = false
				Debris:AddItem(Summon, SUMMON_DEBRIS_TIME)
				Summon.Parent = Workspace
				Summon:MoveTo(ToolHandle.Position + SUMMON_SPAWN_OFFSET)
			end
			--]]
		end

		-- Pew pew
		local targetPoint = MyHumanoid.TargetPoint
		
		wait(COOLDOWN)
		Tool.Enabled = true
	end
end

function OnUnequipped()
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