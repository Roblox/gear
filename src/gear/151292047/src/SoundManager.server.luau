--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

for i, v in pairs(Handle:GetChildren()) do
	if v:IsA("Sound") then
		v.ChildAdded:connect(function(Child)
			if Child.Name == "Play" then
				v:Play()
			elseif Child.Name == "Stop" then
				v:Stop()
			end
			Delay(0, function()
				Child:Destroy()
			end)
		end)
	end
end