function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end


local Tool = script.Parent
local Handle = WaitForChild(Tool, "Handle")
local Spike = WaitForChild(Tool, "spike")
local Dance = WaitForChild(Tool, "dance")
local TouchdownSound = WaitForChild(Handle, "TouchdownSound")
local Humanoid, Torso

local SpikeAnimation
local DanceAnimation

function onEquipped()
	local Character = Tool.Parent
	if not Character then return end

	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Humanoid or not Torso then return end

	SpikeAnimation = Humanoid:LoadAnimation(Spike)
	DanceAnimation = Humanoid:LoadAnimation(Dance)
end

function ThrowBall()
	local newBall = Handle:Clone()
	newBall.CanCollide = true
	newBall.Name = "Football"
	newBall.Transparency = 0
	newBall.CFrame = Handle.CFrame + Torso.CFrame.lookVector * 3
	newBall.Velocity = Handle.Velocity + Vector3.new(0, -100, 0) + Torso.CFrame.lookVector * 20
	newBall.Parent = workspace

	game:GetService("Debris"):AddItem(newBall, 5)

	Handle.Transparency = 1
end

function ReturnBall()
	Handle.Transparency = 0
end

function onUnequipped()
	if DanceAnimation then DanceAnimation:Stop() end
	ReturnBall()
end


Tool.Enabled = true
function onActivated()
	if (not Tool.Enabled) or (not SpikeAnimation) or not Humanoid then return end
	Tool.Enabled = false

	TouchdownSound:Play()
	SpikeAnimation:Play() 
	wait(.4) 
	Humanoid.Jump = true
	wait(.1)
	ThrowBall()

	wait(.7)
	-- do dance here
	if DanceAnimation then DanceAnimation:Play() end
	wait(1.25)

	ReturnBall()

	wait(1)

	Tool.Enabled = true
end


Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)
