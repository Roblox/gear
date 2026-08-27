--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
PlaySound = Tool:WaitForChild("PlaySound")

PlaySound.Value = ""

PlaySound.Changed:Connect(function()
	if PlaySound.Value ~= "" then
		local Sound = Handle:FindFirstChild(PlaySound.Value)
		if Sound then
			Sound:Play()
		end
		PlaySound.Value = ""
	end
end)