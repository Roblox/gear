-----------------
--| Constants |--
-----------------

local BLAST_RADIUS = 6
local BLAST_PRESSURE = 750000

-- Rocket will fly through things named these
local ROCKET_IGNORE_LIST = {rocket = 1, handle = 1, effect = 1, water = 1} --NOTE: Keys must be lowercase, values must evaluate to true

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

local DebrisService = Game:GetService('Debris')

local Rocket = script.Parent
local CreatorTag = WaitForChild(Rocket, 'creator')

local Connection = nil

-----------------
--| Functions |--
-----------------

-- Returns the ancestor that contains a Humanoid, if it exists
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

local hitHuman=false


local function weldBetween(a, b)
    local weld = Instance.new("Weld")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = CFrame.new()
    weld.C1 = b.CFrame:inverse() * a.CFrame
    weld.Parent = a
    return weld;
end

local function OnTouched(otherPart)
	if Rocket and otherPart then
		-- Fly through anything in the ignore list
		if ROCKET_IGNORE_LIST[string.lower(otherPart.Name)] or otherPart.Parent.Name=='_$_CATMODEL_$_' then
			return
		end
		
		if otherPart.Parent:FindFirstChild('Humanoid') then
			weldBetween(otherPart,script.Parent)
			local tsmoke = Instance.new('Smoke')
			tsmoke.Size = 10
			tsmoke.Color = Color3.new(.1,.1,.1)
			tsmoke.RiseVelocity = 0
			tsmoke.Parent = script.Parent
			local boomSound = Rocket:FindFirstChild('Boom')
			if boomSound then
				boomSound:Play()
			end
			
			-- Stop playing the swoosh sound
			local swooshSound = Rocket:FindFirstChild('Swoosh')
			if swooshSound then
				swooshSound:Stop()
			end
	
			--Rocket.Transparency = 1
			Rocket.CanCollide = false
			--Rocket.Anchored = true
			Spawn(function()
				for i=1,5,1 do
					if otherPart.Parent:FindFirstChild('Humanoid') then
						otherPart.Parent.Humanoid:TakeDamage(18)
					end
					wait(.9)
				end
			end)
			
			DebrisService:AddItem(Rocket, 5)
			-- Destroy the connection so this method won't be called again
			Connection:disconnect()
		end
	end
end

--------------------
--| Script Logic |--
--------------------

-- Arm the rocket and save the touch connection so we can disconnect it later
Connection = Rocket.Touched:connect(OnTouched)
