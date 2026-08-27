function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		wait()
	end
	return parent[childName]
end

local myCharacter = script.Parent
local myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
local newSpeed = waitForChild(script, "NewSpeed").Value
local ScreenGui
local Frame
local TextLabel


local myHumanoid = myCharacter:FindFirstChild("Humanoid")
if myHumanoid then
	myHumanoid.WalkSpeed = newSpeed
	if myPlayer then
		local OldGui = myPlayer.PlayerGui:FindFirstChild("IceCreamConeSpeedGui")
		if OldGui then OldGui:Remove() end
		ScreenGui = waitForChild(script, "IceCreamConeSpeedGui"):Clone()
		ScreenGui.Parent = myPlayer.PlayerGui
		Frame = waitForChild(ScreenGui, "Frame")
		waitForChild(Frame, "ConeImage1")
		waitForChild(Frame, "ConeImage2")
		TextLabel = waitForChild(Frame, "TextLabel")
		if newSpeed < 16 then	-- It's a crash...
			TextLabel.Text = "Sugar crash..."
		else	-- It's a rush!
			TextLabel.Text = "Sugar rush!"
		end
	end
	wait(10)
	myHumanoid.WalkSpeed = 16
end
ScreenGui:Remove()
script:Remove()
