--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")

FadeRate = 0.025
Rate = (1 / 15)

Removing = false

function RemoveModel()
	if Removing then
		return
	end
	local Parts = {}
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("Model") then
			table.insert(Parts, v)
		end
	end
	if #Parts == 0 then
		Removing = true
		Model.Name = ""
		Debris:AddItem(Model, 0.5)
	end
end

Model.ChildRemoved:connect(function(Child)
	RemoveModel()
end)

wait(1.5)

RemoveModel()