local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

wait()

local DebrisService = Game:GetService('Debris')
local Torso = script.Parent


if Torso and not Torso:FindFirstChild('Heartbeat') then
	local HeartBeat = WaitForChild(script, 'Heartbeat'):Clone()
	DebrisService:AddItem(HeartBeat, 5)
	HeartBeat.Parent = Torso
	wait()
	HeartBeat:Play()
end
