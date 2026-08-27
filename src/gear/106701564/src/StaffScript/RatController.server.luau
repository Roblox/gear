-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')
local RAT_LIFESPAN = 20
local RAT_DAMAGE = 8
local MyCreator = WaitForChild(script, 'creator')
local MyTorso = WaitForChild(script.Parent, 'Torso')
local MyHead = WaitForChild(script.Parent, 'Head')
local MyHumanoid = WaitForChild(script.Parent, 'Humanoid')
local Smoke = WaitForChild(MyTorso, 'Smoke')

DebrisService:AddItem(script.Parent, RAT_LIFESPAN)

local HitCharacters = {}
local Characters = {}


function RayIgnoreCheck(hit, pos)
	if hit then
		if hit.Transparency >= 1 or string.lower(hit.Name) == "water" or
				hit.Name == "Effect" or hit.Name == "Rocket" or hit.Name == "Bullet" or
				hit.Name == "Rat" or hit.Name == "Handle" or hit:IsDescendantOf(MyCharacter) then
			return true
		end
	end
	return false
end

-- @preconditions: vec should be a unit vector, and 0 < rayLength <= 1000
function RayCast(startPos, vec, rayLength)
	local hitObject, hitPos = game.Workspace:FindPartOnRay(Ray.new(startPos + (vec * .01), vec * rayLength), Handle)
	if hitObject and hitPos then
		local distance = rayLength - (hitPos - startPos).magnitude
		if RayIgnoreCheck(hitObject, hitPos) and distance > 0 then
			-- there is a chance here for potential infinite recursion
			return RayCast(hitPos, vec, distance)
		end
	end
	return hitObject, hitPos
end


function FindCharacter(part)
	if part.Parent == nil or part == Workspace then return nil end
	if part:FindFirstChild('Humanoid') then return part end
	return FindCharacter(part.Parent)
end

function FindCharactersInWorkspace()
	for _, child in pairs(Game.Workspace:GetChildren()) do 
		if child:IsA('Model') and child.Name ~= 'Rat' then
			if child:FindFirstChild('Humanoid') then
				Characters[child] = true
			end
		end
	end
	-- Remove my creator from the possible target list
	if MyCreator and MyCreator.Value and MyCreator.Value.Character then
		Characters[MyCreator.Value.Character] = nil
	end
end

function CheckForJump()
	local hitObj, hitPos = RayCast(MyTorso.CFrame.p, MyHead.CFrame.lookVector, 10)
	if hitObj then
		MyHumanoid.Jump = true
	end
end

function OnHit(hit)
	if MyHumanoid and MyHumanoid.Health > 0 then
		
		MyHumanoid.Jump = true
		local character = FindCharacter(hit)
		if character and not HitCharacters[character] and PlayersService:GetPlayerFromCharacter(character) ~= MyCreator.Value and character.Name ~= 'Rat' then
			local hitHumanoid = character:FindFirstChild('Humanoid')
			if hitHumanoid then
				MyHumanoid.Jump = true
				HitCharacters[character] = true
				hitHumanoid:TakeDamage(RAT_DAMAGE)
			end
		end
	end
end

MyHead.Touched:connect(OnHit)

Workspace.ChildAdded:connect(function(child)
	if child:IsA('Model') and child.Name ~= 'Rat' and child:FindFirstChild('Humanoid') then
		Characters[child] = true
	end
end)

FindCharactersInWorkspace()


MyTorso.Transparency = 1

Smoke.Enabled = false
wait()
Smoke.Enabled = true
wait(1)
Smoke.Enabled = false
MyTorso.Transparency = 0

Delay(RAT_LIFESPAN - 4, function() if Smoke then Smoke.RiseVelocity = 12 Smoke.Enabled = true end wait(1.4) if Smoke then Smoke.Enabled = false end if MyTorso then MyTorso.Transparency = 1 end end)

Spawn(function()
	while true do
		wait(3)
		HitCharacters = {}
	end
end)

--[[
Spawn(function ()
	while true do
		wait(0.15)
		CheckForJump()
	end
end)
--]]

while true do
	local closestTarget = nil
	local closestDist = 100000000
	for target, _ in pairs(Characters) do
		if (target:FindFirstChild('Torso') and target:FindFirstChild('Humanoid') and target:FindFirstChild('Humanoid').Health > 0 and ((target.Torso.CFrame.p - MyTorso.CFrame.p).magnitude < closestDist)) then
			closestDist = (target.Torso.CFrame.p - MyTorso.CFrame.p).magnitude
			closestTarget = target
		end
	end
	if closestTarget then
		local targetTorso = closestTarget:FindFirstChild('Torso')
		if targetTorso then
			--print("Attacking " , closestTarget.Name)
			MyHumanoid:MoveTo(targetTorso.CFrame.p, targetTorso)
		end
	end
	wait(.5)
end



