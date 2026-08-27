-- Gradually deals damage to the player
wait()
Debris = game:GetService("Debris")
Fire = script.Parent
Humanoid = Fire.Parent.Parent:FindFirstChild("Humanoid")
Character = Humanoid.Parent
if Humanoid and Humanoid.Parent then
	Damage = script:WaitForChild("Damage")
	Rate = 100
	for i = 1, Rate do
		if (Humanoid.Health - Damage.Value) <= 0 then
			for i, v in pairs(Humanoid:GetChildren()) do
				if v.Name == "creator" then
					v:Destroy()
				end
			end
			local creator = script.creator:Clone()
			creator.Value = script.creator.Value
			Debris:AddItem(creator, 2)
			creator.Parent = Humanoid
		end
		if not Character:FindFirstChild("ForceField") then
			Humanoid.Health = Humanoid.Health - (Damage.Value / Rate)
		end
		wait(0.1)
	end
end
Fire:Destroy()