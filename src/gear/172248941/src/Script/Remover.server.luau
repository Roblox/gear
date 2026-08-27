--Made by Luckymaxer

Figure = script.Parent
Creator = Figure:WaitForChild("Creator").Value

Debris = game:GetService("Debris")

function DestroyModel()
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