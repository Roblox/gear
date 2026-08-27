--Made by Luckymaxer

Model = script.Parent

Creator = Model:FindFirstChild("Creator")

Enabled = false

if Creator and Creator.Value and Creator.Value.Parent and Creator.Value:IsA("Player") and Creator.Value.Character then
	Player = Creator.Value
	Character = Player.Character
	Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid and Humanoid.Health > 0 then
		Player.Changed:connect(function(Property)
			if Property == "Parent" and not Player.Parent then
				Model:Destroy()
			end
		end)
		Character.Changed:connect(function(Property)
			if Property == "Parent" and not Character.Parent then
				Model:Destroy()
			end
		end)
		Humanoid.Died:connect(function()
			Model:Destroy()
		end)
		Enabled = true
	end
end

if not Enabled then
	Model:Destroy()
end