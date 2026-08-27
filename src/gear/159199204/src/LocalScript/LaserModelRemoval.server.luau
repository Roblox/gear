--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")

function CountLasers(Parent)
	local Lasers = {}
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BasePart") and string.lower(v.Name) == "laser" then
			table.insert(Lasers, v)
		end
	end
	return Lasers
end

function DestroyModel()
	if #CountLasers(Model) == 0 then
		Debris:AddItem(Model)
	end
end

Model.ChildRemoved:connect(function(Child)
	DestroyModel()
end)

DestroyModel()