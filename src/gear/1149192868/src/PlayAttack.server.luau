-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local Tool = script.Parent
local MyHumanoid = Tool.Parent:FindFirstChild('Humanoid')
local AttackAnim
local AttackTrack = nil

if Tool and MyHumanoid then
	AttackAnim = WaitForChild(Tool, 'Lunge')
	if AttackAnim then
		AttackTrack = MyHumanoid:LoadAnimation(AttackAnim)
	end
	AttackTrack:Play()
	wait(0.4)
	if AttackTrack then
		AttackTrack:Stop()
	end
end
script.Disabled = true
