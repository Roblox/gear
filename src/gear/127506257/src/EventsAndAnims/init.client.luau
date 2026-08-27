local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local TornadoScript = Tool:WaitForChild('TornadoScript')

local Anims = {}
local BlowSound

local Debris = game:GetService('Debris')

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


local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid:IsA('Humanoid') then
			local unloadedAnim = Tool:FindFirstChild(animationName)
			if unloadedAnim then
				Anims[animationName] = humanoid:LoadAnimation(unloadedAnim)
			end
		end
	end
	if Anims[animationName] then
		Anims[animationName]:Play()
	end
end

local function Stop(animationName)
	if Anims[animationName] then 
		Anims[animationName]:Stop()
	end
end
	
function OnActivated()
	if Tool.Enabled then
		Tool.Enabled = false
		delay(20,function()
			Tool.Enabled = true
		end)
		
		local character = Tool.Parent
		local torso = character:FindFirstChild('HumanoidRootPart')
		if character and character:FindFirstChild('Humanoid') then
			Play('BlowAnim')
			wait(TIME_BEFORE_SOUND)
			BlowSound = Handle:FindFirstChild('BlowSound')
			if BlowSound then BlowSound:Play() end
			script.Parent:WaitForChild('RemoteEvent'):FireServer("DO THE THING!!!")
		end
	end
end

function OnEquipped()
end

function OnUnequipped()
	Stop('BlowAnim')
	if BlowSound then BlowSound:Stop() end
end


Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)

