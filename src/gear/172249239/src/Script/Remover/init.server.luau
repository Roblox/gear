--Made by Luckymaxer

Figure = script.Parent
Creator = Figure:WaitForChild("Creator").Value

Debris = game:GetService("Debris")

FixCamera = script:WaitForChild("FixCamera")

function DestroyModel()
	if Player then
		local Backpack = Player:FindFirstChild("Backpack")
		if Backpack then
			local FixCameraClone = FixCamera:Clone()
			FixCameraClone.Disabled = false
			FixCameraClone.Parent = Backpack
		end
	end
	Debris:AddItem(Figure, 2)
end

if Creator:IsA("Player") then
	Character = Creator.Character
	if Character then
		Character.Changed:connect(function(Property)
			if not Character.Parent then
				DestroyModel()
			end
		end)
	else
		DestroyModel()
	end
else
	DestroyModel()
end