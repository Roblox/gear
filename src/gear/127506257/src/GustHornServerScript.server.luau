

local TornadoScript = script.Parent:WaitForChild('TornadoScript')

local TIME_BEFORE_SOUND = 0.5
local TIME_AFTER_SOUND = 4.5
local TIME_BETWEEN_USES = 20
local TORNADO_RADIUS = 15
local TORNADO_HEIGHT = 200
local TORNADO_SPEED = 10
local TORNADO_TIME = 10
local SPACE_BETWEEN_TORNADOES = 5
local NUM_TORNADOES = 6
local GRAVITY = 196.2

local TORSO_HEIGHT = 3

local Tornado = Instance.new('Part')
Tornado.Name = "Tornado"
Tornado.FormFactor = Enum.FormFactor.Symmetric
Tornado.CanCollide = false
Tornado.Size = Vector3.new(TORNADO_RADIUS, TORNADO_HEIGHT, TORNADO_RADIUS)
Tornado.BrickColor = BrickColor.new('Pastel Blue')
Tornado.Transparency = 0.4
local CylinderMesh = Instance.new('CylinderMesh')
CylinderMesh.Parent = Tornado
local BodyVelocity = Instance.new('BodyVelocity')
BodyVelocity.Parent = Tornado
BodyVelocity.maxForce = Vector3.new(1E6,0,1E6)
BodyVelocity.P = 1E6
local BodyForce = Instance.new('BodyForce')
BodyForce.force = Vector3.new(0, GRAVITY * Tornado:GetMass(), 0)
BodyForce.Parent = Tornado
local Ignore = Instance.new('ObjectValue')
Ignore.Name = 'Ignore'
Ignore.Parent = Tornado
local TornadoScriptClone = TornadoScript:Clone()
TornadoScriptClone.Disabled = false
TornadoScriptClone.Parent = Tornado



script.Parent:WaitForChild('RemoteEvent').OnServerEvent:connect(function()
	if script.Parent and script.Parent.Parent then
		local character = script.Parent.Parent
		local humanoid = character:FindFirstChild('Humanoid')
		local hrp = character:FindFirstChild('HumanoidRootPart')
		if humanoid and hrp and humanoid.Health > 0 then
			local rightVector = hrp.CFrame.lookVector:Cross(Vector3.new(0,1,0))
			for i = 1, NUM_TORNADOES do
				local tornadoClone = Tornado:Clone()
				tornadoClone:WaitForChild('Ignore').Value = character
				tornadoClone.Parent = workspace
				local position = hrp.Position + Vector3.new(0, TORNADO_HEIGHT/2 - TORSO_HEIGHT, 0) + (i - (NUM_TORNADOES + 1) / 2) * (TORNADO_RADIUS + SPACE_BETWEEN_TORNADOES) * rightVector
				tornadoClone.CFrame = CFrame.new(position)
				tornadoClone:WaitForChild('BodyVelocity').velocity = TORNADO_SPEED * hrp.CFrame.lookVector
			end
		end
	end
end)