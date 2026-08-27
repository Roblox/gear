-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local DebrisService = Game:GetService('Debris')

local MyModel = script.Parent

local PlayOrStop = WaitForChild(script, 'PlayOrStop').Value
local AnimToReplicate = WaitForChild(script, 'AnimationToReplicate').Value
local PetHumanoid = WaitForChild(script, 'PetHumanoid').Value

local TrackToReplicate = PetHumanoid:LoadAnimation(AnimToReplicate)


TrackToReplicate:Play()
wait(3)
TrackToReplicate:Stop()
DebrisService:AddItem(script, 0)