--Made by Luckymaxer

wait()

Train = script.Parent

Players = game:GetService("Players")

Creator = Train:FindFirstChild("Creator")

if Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Character then
	
	Character = Creator.Value.Character
	
	Character.Changed:connect(function()
		if not Character or not Character.Parent then
			Train:Destroy()
		end
	end)
	
	Creator.Changed:connect(function()
		if not Creator.Value then
			Train:Destroy()
		end
	end)

else	
	Train:Destroy()
end