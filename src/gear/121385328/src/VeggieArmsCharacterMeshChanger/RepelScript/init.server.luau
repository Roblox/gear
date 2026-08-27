-- Adds a repulsive force to anything this object touches
local Part = script.Parent

local Debris = game:GetService('Debris')

local CharacterToIgnore = script:WaitForChild('CharacterToIgnore').Value

local MAGNITUDE = 3E4
local TIME_OF_FORCE = 0.2

Part.Touched:connect(function(other)
	if other.Parent == CharacterToIgnore or (other.Parent and other.Parent.Parent == CharacterToIgnore) then return end
	if not other.Anchored then
		local punchSound = script:FindFirstChild('PunchSound')
		if punchSound then punchSound:Play() end
		local direction = (other.Position - Part.Position).unit
		local bodyForce = Instance.new('BodyForce')
		bodyForce.force = MAGNITUDE * direction
		bodyForce.Parent = other
		Debris:AddItem(bodyForce, TIME_OF_FORCE)
	end
end)
	
