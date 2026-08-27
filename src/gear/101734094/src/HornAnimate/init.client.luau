function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local Tool = script.Parent
local Blow = WaitForChild(Tool, "BlowAnimation")
local Hold = WaitForChild(Tool, "HoldAnimation")
local Character

local BlowAnimation
local HoldAnimation

local Handle = WaitForChild(Tool, "Handle")
local BigHorn = WaitForChild(Handle, "BigHorn")
local SmallHorn = WaitForChild(Handle, "SmallHorn")

function onEquipped()
	Character = Tool.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		BlowAnimation = Humanoid:LoadAnimation(Blow)
		HoldAnimation = Humanoid:LoadAnimation(Hold)
		HoldAnimation:Play()
	end
end

function onUnequipped()
	if HoldAnimation then HoldAnimation:Stop() end
end

local debounce = false
function onActivated()
	if debounce then return end
	while Tool.Enabled do wait() end
	debounce = true
	BlowAnimation:Play(0)
	wait(.5)
	BigHorn:Play()
	SmallHorn:Play()
	
	while not Tool.Enabled do wait() end

	debounce = false
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)
