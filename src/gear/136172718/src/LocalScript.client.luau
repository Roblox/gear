---------------------------------
	-- scripted by jmargh --
---------------------------------

---------------------------------
		-- Tool Variables --
---------------------------------

local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local DebrisService = game:GetService('Debris')
local IsOnCoolDown = Tool:WaitForChild('IsOnCoolDown')

---------------------------------
		-- Constants --
---------------------------------

local GRIP_POS = Vector3.new(0, -0.2, 0.5)

---------------------------------
		-- Helper Functions --
---------------------------------

local function setHandleGripPos(position)
	Tool.GripPos = position
end

local function spawnMiniPresents(amount)
	for t = 1, amount do
		local miniPresent = Handle:Clone()
		miniPresent.CanCollide = false
		local mesh = miniPresent:FindFirstChild('Mesh')
		if mesh then
			mesh.Scale = Vector3.new(0.2, 0.2, 0.2)
		end
		miniPresent.CFrame = CFrame.new(Handle.CFrame.p)
		local bodyVelocity = Instance.new('BodyVelocity')
		bodyVelocity.velocity = Vector3.new(
			math.random(0, 2),
			math.random(5, 10),
			math.random(0, 2)
		)
		bodyVelocity.Parent = miniPresent
		DebrisService:AddItem(bodyVelocity, 1)
		miniPresent.Parent = game.Workspace
		DebrisService:AddItem(miniPresent, 2)
		wait()
	end
end

---------------------------------
		-- Events --
---------------------------------

local function onActivated()
	if IsOnCoolDown.Value then
		return
	end
	spawnMiniPresents(20)
end

Tool.Activated:connect(onActivated)

if Handle then
	setHandleGripPos(GRIP_POS)
end
