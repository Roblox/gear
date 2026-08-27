function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local Tank = script.Parent
local GeneratingPlayer = waitForChild(Tank, "GeneratingPlayer")
local OtherPlayer = waitForChild(Tank, "OtherPlayer")
local myPlayer
local otherPlayer
local myHumanoid
local otherHumanoid

function destroyTank()
	Tank:Remove()
end

function destroyTankPlayerVersion(somePlayer)
	if (somePlayer == myPlayer or somePlayer == otherPlayer) then
		destroyTank()
	end
end

-- Main operation:
myPlayer = GeneratingPlayer.Value
otherPlayer = OtherPlayer.Value
game.Players.PlayerRemoving:connect(destroyTankPlayerVersion)
myHumanoid = myPlayer.Character:FindFirstChild("Humanoid")
otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
if myHumanoid then
	myHumanoid.Died:connect(destroyTank)
end
if otherHumanoid then
	otherHumanoid.Died:connect(destroyTank)
end
