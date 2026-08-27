-----------------
--| Constants |--
-----------------

local BLAST_RADIUS = 6
local BLAST_PRESSURE = 750000

local IGNORE_LIST = {rocket = 1, handle = 1, effect = 1, water = 1} -- Rocket will fly through things named these
--NOTE: Keys must be lowercase, values must evaluate to true

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local DebrisService = game:GetService('Debris')

local Rocket = script.Parent

local CreatorTag = WaitForChild(Rocket, 'creator')

local SwooshSound = WaitForChild(Rocket, 'Swoosh')

-----------------
--| Functions |--
-----------------

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

local function OnExplosionHit(hitPart)
	if hitPart then
		local _, humanoid = FindCharacterAncestor(hitPart.Parent)
		if humanoid and humanoid.Health > 0 and not IsTeamMate(CreatorTag.Value,game.Players:GetPlayerFromCharacter(humanoid.Parent)) then
			CreatorTag:Clone().Parent=humanoid
			humanoid:TakeDamage(math.huge)
		end
	end
end

local function OnTouched(otherPart)
	if Rocket and otherPart then
		-- Fly through anything in the ignore list
		if IGNORE_LIST[string.lower(otherPart.Name)] then
			return
		end

		-- Fly through the creator
		local myPlayer = CreatorTag.Value
		if myPlayer and myPlayer.Character and myPlayer.Character:IsAncestorOf(otherPart) then
			return
		end
		
		OnExplosionHit(otherPart)
		
		-- Boom
		local explosion = Instance.new('Explosion')
		explosion.BlastPressure = BLAST_PRESSURE
		explosion.BlastRadius = BLAST_RADIUS
		explosion.DestroyJointRadiusPercent = 0
		explosion.Position = Rocket.Position
		explosion.Hit:Connect(OnExplosionHit)
		explosion.Parent = workspace

		-- Move this script and the creator tag (so our custom logic can execute), then destroy the rocket
		script.Parent = explosion
		CreatorTag.Parent = script
		Rocket:Destroy()
	end
end

--------------------
--| Script Logic |--
--------------------

SwooshSound:Play()

Rocket.Touched:Connect(OnTouched)

-- Manually call OnTouched for parts the rocket might have spawned inside of
--TODO: Remove when Touched correctly fires for parts spawned within other parts
local partClone = Rocket:Clone()
partClone:ClearAllChildren()
partClone.Transparency = 1
--partClone.Anchored = true --NOTE: DOES NOT WORK if part is anchored!
DebrisService:AddItem(partClone, 0.1)
partClone.Parent = workspace
partClone.Touched:Connect(OnTouched)
