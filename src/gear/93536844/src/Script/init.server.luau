--[[
	Fixed by ArceusInator
	1/22/2015 Zombies no longer randomly die, works with FE
--]]

-----------------
--| Constants |--
-----------------

local NPC_ID = 93601062 -- Asset ID of the NPC to be launched

local COOLDOWN = 6 -- Seconds until tool can be used again
local TIME_TO_LIVE = 60 -- Seconds until NPC is cleaned up

local LAUNCH_SPEED_MIN = 60 -- Minimum speed NPC will be launched
local LAUNCH_SPEED_MAX = 300 -- Maximum speed NPC will be launched

local LAUNCH_TIME_MIN = 0 -- Seconds until launch speed starts increasing beyond min
local LAUNCH_TIME_MAX = 3 -- Seconds to reach max launch speed

local CHANCE_TO_EXPLODE = 10 -- There is a 1 in X chance that the NPC will explode

local Tool = script.Parent
while Tool:FindFirstChild('Handle') == nil do wait() end 
local ToolHandle = Tool.Handle

-----------------
--| Variables |--
-----------------

local InsertService = Game:GetService('InsertService')
local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local MyPlayer

local Npc = InsertService:LoadAsset(NPC_ID):GetChildren()[1]
Npc:MakeJoints()

do	-- Give NPC a creator tag
	local creatorTag = Instance.new('ObjectValue')
	creatorTag.Name = 'creator'
	creatorTag.Value = MyPlayer
	creatorTag.Parent = Npc
end

local NpcClone = Npc:Clone()
NpcClone:MakeJoints()

local Mouse = nil
local ClickTime = 0

local SoundTable = {}
local Holding = false

-----------------
--| Functions |--
-----------------

local function OnButton1Down()
	local myModel = MyPlayer.Character
	if Tool.Enabled and myModel and myModel:FindFirstChild('Humanoid') and myModel.Humanoid.Health > 0 then
		ClickTime = time()
		Holding = true
	end
end

local function OnButton1Up(hitCF)
	if not Holding then return end
	
	Holding = false
	local myModel = MyPlayer.Character
	if Tool.Enabled and myModel and myModel:FindFirstChild('Humanoid') and myModel.Humanoid.Health > 0 then
		Tool.Enabled = false

		-- Determine launch speed (based on how long click is held)
		local launchSpeed = LAUNCH_SPEED_MIN
		do
			local timeHeldDown = time() - ClickTime
			if timeHeldDown > LAUNCH_TIME_MIN then
				local speedRange = LAUNCH_SPEED_MAX - LAUNCH_SPEED_MIN
				local timeRatio = timeHeldDown / (LAUNCH_TIME_MAX - LAUNCH_TIME_MIN)
				launchSpeed = launchSpeed + (speedRange * math.min(timeRatio, 1))
			end
		end

		-- Give all the NPC's BaseParts a velocity, and make any Humanoids sit
		local velocity = (hitCF.p - ToolHandle.CFrame.p).unit * launchSpeed
		for _, child in pairs(NpcClone:GetChildren()) do
			if child:IsA('BasePart') then
				child.Velocity = velocity
			elseif child:IsA('Humanoid') then
				child.Sit = true --NOTE: Turns off the gyro until NPC jumps
			end
		end

		-- Add the explode script if we get lucky
		if math.random(CHANCE_TO_EXPLODE) == 1 then
			local explodeScript = script:FindFirstChild('Explode')
			if explodeScript then
				local explodeScriptClone = explodeScript:Clone()
				explodeScriptClone.Parent = NpcClone
				explodeScriptClone.Disabled = false
			end
		end

		-- Add the NPC to the world
		DebrisService:AddItem(NpcClone, TIME_TO_LIVE)
		NpcClone.Parent = Workspace
		NpcClone.creator.Value = MyPlayer
		NpcClone:MakeJoints()
		NpcClone:MoveTo(ToolHandle.Position) --NOTE: Must already be in Workspace
		NpcClone:MakeJoints()

		-- Clone the next NPC
		NpcClone = Npc:Clone()
		NpcClone:MakeJoints()

		wait(COOLDOWN)

		Tool.Enabled = true
	end
end

local function OnEquipped()
	MyPlayer = PlayersService:GetPlayerFromCharacter(Tool.Parent)
end

-------------------
--|   Remotes   |--
-------------------

Tool.MouseButton1Down.OnServerEvent:connect(function(client)
	if client == MyPlayer then
		OnButton1Down()
	end
end)
Tool.MouseButton1Up.OnServerEvent:connect(function(client, hitCF)
	if client == MyPlayer then
		OnButton1Up(hitCF)
	end
end)

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
