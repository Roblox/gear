-- Yay, fishing by hand! Contest aspect is heavily based on / cribbed from the Hot Dog's.
function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local Tool = script.Parent

local Mouse

local Opponent

local TankPointer
local Tank

local myCharacter
local myPlayer
local PlayerGui
local FishingGui

local TargetedPart
local otherCharacter
local otherPlayer

local FishingContestGui = waitForChild(Tool, "FishingContestGui")
local OpponentDiedGui = waitForChild(FishingContestGui, "OpponentDiedGui")
local Opponent = waitForChild(OpponentDiedGui, "Opponent")

function onActivated()
	if not Mouse then return end
	TargetedPart = Mouse.Target
	if TargetedPart and TargetedPart.Parent:FindFirstChild("Humanoid") then
		otherCharacter = TargetedPart.Parent
		otherPlayer = game.Players:GetPlayerFromCharacter(otherCharacter)
		if otherPlayer then
			Opponent.Value = otherPlayer
		end
	end
end


function onEquipped(mouse)
	if mouse then Mouse = mouse end
end

function onUnequipped()
	if Tank then Tank.Parent = nil end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)