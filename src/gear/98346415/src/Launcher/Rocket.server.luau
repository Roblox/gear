-----------------
--| Constants |--
-----------------

local BLAST_RADIUS = 10
local BLAST_PRESSURE = 350000

-- Rocket will fly through things named these
local ROCKET_IGNORE_LIST = {rocket = 1, handle = 1, effect = 1, water = 1} --NOTE: Keys must be lowercase, values must evaluate to true

-----------------
--| Variables |--
-----------------

local DebrisService = game:GetService('Debris')

local Rocket = script.Parent
local CreatorTag = Rocket:WaitForChild("creator")

local Connection = nil

-----------------
--| Functions |--
-----------------


function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

-- Returns the ancestor that contains a Humanoid, if it exists
local function FindCharacterAncestor(subject)
	if subject and subject ~= workspace then
		local humanoid = subject:FindFirstChildOfClass('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

local hitHuman=false

local function OnExplosionHit(hitPart)
	if hitPart then
		local _, humanoid = FindCharacterAncestor(hitPart.Parent)
		if humanoid and not humanoid.Parent:FindFirstChildOfClass("ForceField") and game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent) ~= CreatorTag.Value and humanoid.Health ~= 0 and not IsTeamMate(CreatorTag.Value,game.Players:GetPlayerFromCharacter(humanoid.Parent)) then
			if CreatorTag.Value.Character:FindFirstChild('Carnagecopia') then
				local tkills= CreatorTag.Value.Character:FindFirstChild('Carnagecopia'):FindFirstChild('Kills')
				if tkills and not hitHuman then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid,CreatorTag.Value)
					tkills.Value=tkills.Value+1
					humanoid.Parent:BreakJoints()
					hitHuman=true
				end
			end
		end
	end
end

local function OnTouched(otherPart)
	if Rocket and otherPart then
		-- Fly through anything in the ignore list
		if ROCKET_IGNORE_LIST[string.lower(otherPart.Name)] then
			return
		end

		-- Fly through the creator
		local myPlayer = CreatorTag.Value
		if myPlayer and myPlayer.Character and myPlayer.Character:IsAncestorOf(otherPart) then
			return
		end

		-- Create the explosion
		local explosion = Instance.new('Explosion')
		explosion.BlastPressure = BLAST_PRESSURE
		explosion.DestroyJointRadiusPercent = 0
		explosion.BlastRadius = BLAST_RADIUS
		explosion.Position = Rocket.Position
		explosion.Hit:Connect(OnExplosionHit)
		explosion.Parent = workspace

		-- Start playing the boom sound
		local boomSound = Rocket:FindFirstChild('Boom')
		if boomSound then
			boomSound:Play()
		end

		-- NOTE:
		-- If we just destroyed the rocket at this point, the boom sound would be destroyed too,
		-- so instead we will hide the rocket, keep it in the same spot, and schedule it for deletion

		-- Stop playing the swoosh sound
		local swooshSound = Rocket:FindFirstChild('Swoosh')
		if swooshSound then
			swooshSound:Stop()
		end

		-- Put out the fire
		local fire = Rocket:FindFirstChild('Fire')
		if fire then
			fire:Destroy()
		end

		Rocket.Transparency = 1
		Rocket.CanCollide = false
		Rocket.Anchored = true
		DebrisService:AddItem(Rocket, 3)

		-- Destroy the connection so this method won't be called again
		Connection:Disconnect()
	end
end

--------------------
--| Script Logic |--
--------------------

-- Arm the rocket and save the touch connection so we can disconnect it later
Connection = Rocket.Touched:Connect(OnTouched)
