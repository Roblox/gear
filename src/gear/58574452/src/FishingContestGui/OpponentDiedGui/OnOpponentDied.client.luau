function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local OpponentDiedGui = script.Parent
local FishingContestGui
local PlayerGui
local myPlayer
local Opponent
local otherPlayer
local otherHumanoid
local MessageFrame
local OKButton

function winByDefault()
	if PlayerGui then
		OpponentDiedGui.Parent = PlayerGui
		FishingContestGui:Remove()
		MessageFrame = waitForChild(OpponentDiedGui, "MessageFrame")
		MessageFrame.Visible = true
		OKButton = waitForChild(MessageFrame, "OKButton")
		OKButton.MouseButton1Click:connect(function() OpponentDiedGui:Remove() end)
	end
end

function winByDefaultPlayerVersion(somePlayer)
	if somePlayer == otherPlayer then
		winByDefault()
	end
end

if OpponentDiedGui then
	FishingContestGui = OpponentDiedGui.Parent
	if FishingContestGui then
		PlayerGui = FishingContestGui.Parent
		if PlayerGui then
			myPlayer = PlayerGui.Parent
		end
	end
	Opponent = OpponentDiedGui:FindFirstChild("Opponent")
	if Opponent then
		Opponent.Changed:connect(function() script:Remove() end)
		otherPlayer = Opponent.Value
		if otherPlayer then
			game.Players.ChildRemoved:connect(winByDefaultPlayerVersion)
			otherHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")
			if otherHumanoid then otherHumanoid.Died:connect(winByDefault) end
		end
	end
end
