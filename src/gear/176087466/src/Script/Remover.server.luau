--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")

function GetLasers()
	local Lasers = {}
	for i, v in pairs(Model:GetChildren()) do
		if v and v.Parent and v:IsA("BasePart") and (v.Name == "Laser" or v.Name == "InkBlotch") then
			table.insert(Lasers, v)
		end
	end
	return Lasers
end

function DestroyModel()
	Model.Name = ("Removing" .. Model.Name)
	if Model and Model.Parent then
		Model:Destroy()
	end
	Debris:AddItem(Model, 2)
end

if #GetLasers() == 0 then
	DestroyModel()
else
	Model.ChildRemoved:connect(function()
		if #GetLasers() == 0 then
			DestroyModel()
		end
	end)
end