----------------------
--| Tool Variables |--
----------------------
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local Ragdoller = script:WaitForChild('Ragdoller')
local IsCheckValue = Tool:WaitForChild('IsCheck')
local CanSwing = true
local HitList = {}

----------------------
--|    Services    |--
----------------------
local DebrisService = game:GetService('Debris')

----------------------
--|   Constants    |--
----------------------
local PUCK_DAMAGE = 50
local CHECK_DAMAGE = 50
local SWING_TIME = 0.85
local PUCK_SPEED = 75
local PUCK_THETA = math.rad(5)

----------------------
--|   Animations   |--
----------------------
local IdleAnim = Tool:WaitForChild('Idle')
local IdleTrack = nil
local SwingAnim = Tool:WaitForChild('Swing')
local SwingTrack = nil

----------------------
--|Helper Functions|--
----------------------
local function getVectorRight(cf)
	local _,_,_,x,_,_,y,_,_,z = cf:components()
	return Vector3.new(x, y, z)
end

local function rodriguesRotation(v, theta, k)
	return v * math.cos(theta) + (k:Cross(v) * math.sin(theta)) + (k * (k:Dot(v)) * (1 - math.cos(theta)))
end

local function createPuck(cframe)
	local newPuck = Instance.new('Part')
	newPuck.BrickColor = BrickColor.new('Really black')
	newPuck.FormFactor = Enum.FormFactor.Custom
	newPuck.Size = Vector3.new(1, 0.3, 1)
	newPuck.Anchored = true
	newPuck.CanCollide = false
	
	local mesh = Instance.new('CylinderMesh')
	mesh.Parent = newPuck
	newPuck.CFrame = cframe * CFrame.new(3.2, -2.85, -1)
	
	newPuck.Touched:connect(function(other)
		if other.Parent then
			local hitCharacter = other.Parent
			local hitHumanoid = hitCharacter:FindFirstChild('Humanoid')
			local thisCharacter = Tool.Parent
			if thisCharacter == hitCharacter then
				return
			end
			if hitHumanoid and hitHumanoid.Health > 0 then
				local newRagdoller = Ragdoller:Clone()
				newRagdoller.Parent = hitCharacter
				newRagdoller.Disabled = false
				hitHumanoid:TakeDamage(PUCK_DAMAGE)
				newPuck:Destroy()
			end
		end
	end)
	
	newPuck.Parent = Workspace
	DebrisService:AddItem(newPuck, 2)
	
	Delay(0.5, function()
		newPuck.Anchored = false
		newPuck.CanCollide = true
		
		local bodyVelocity = Instance.new('BodyVelocity')
		local velocity = rodriguesRotation(newPuck.CFrame.lookVector, PUCK_THETA, getVectorRight(newPuck.CFrame))
		bodyVelocity.velocity = velocity * PUCK_SPEED
		bodyVelocity.Parent = newPuck
	end)
end

----------------------
--|     Events     |--
----------------------
local function onHandleTouch(other)
	if IsCheckValue.Value then
		if other.Parent then
			local hitCharacter = other.Parent
			local hitHumanoid = hitCharacter:FindFirstChild('Humanoid')
			local thisCharacter = Tool.Parent
			if thisCharacter == hitCharacter then
				return
			end
			for key,val in pairs(HitList) do
				if key == hitCharacter then
					return
				end
			end
			if hitHumanoid and hitHumanoid.Health > 0 then
				HitList[hitCharacter] = true
				Delay(0.5, function()
					if HitList[hitCharacter] then
						HitList[hitCharacter] = nil
					end
				end)
				local newRagdoller = Ragdoller:Clone()
				newRagdoller.Parent = hitCharacter
				newRagdoller.Disabled = false
				hitHumanoid:TakeDamage(CHECK_DAMAGE)
			end
		end
	end
end

local function onActivated()
	if not CanSwing or IsCheckValue.Value then return end

	CanSwing = not CanSwing
	
	local character = Tool.Parent
	local humanoid = character:FindFirstChild('Humanoid')
	local torso = character:FindFirstChild('Torso')
	if humanoid and humanoid.Health > 0 and torso then
		createPuck(torso.CFrame)
		wait(SWING_TIME)
	end
	
	CanSwing = not CanSwing
end

Tool.Activated:connect(onActivated)
Handle.Touched:connect(onHandleTouch)
