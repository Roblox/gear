--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")

Creator = script:FindFirstChild("Creator")
Tool = script:FindFirstChild("Tool")

FadeRate = 0.025
Rate = (1 / 15)

Removing = false

function DestroyModel()
	if Removing then
		return
	end
	Model.Name = ""
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
			v.Anchored = true
			v.CanCollide = false
			for ii, vv in pairs(v:GetChildren()) do
				if vv:IsA("Fire") or vv:IsA("Smoke") or vv:IsA("Sparkles") or vv:IsA("Light") or vv:IsA("ParticleEmitter") then
					vv.Enabled = false
				end
			end
		end
	end
	Removing = true
	Debris:AddItem(Model, 1.5)
end

function ClearModel()
	if Removing then
		return
	end
	local Parts = {}
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") then
			table.insert(Parts, v)
		end
	end
	if #Parts == 0 then
		Removing = true
		Model.Name = ""
		Debris:AddItem(Model, 0.5)
	end
end

if not Creator or not Creator.Value or not Creator.Value:IsA("Player") or not Creator.Value.Parent or not Tool or not Tool.Value or not Tool.Value.Parent then
	DestroyModel()
	return
end

Creator = Creator.Value
Tool = Tool.Value

Character = Creator.Character
if not Character then
	DestroyModel()
	return
end

Creator.Changed:connect(function(Property)
	if Property == "Parent" and not Creator.Parent then
		DestroyModel()
	end
end)

Character.Changed:connect(function(Property)
	if Property == "Parent" and not Character.Parent then
		DestroyModel()
	end
end)

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		DestroyModel()
	end
end)

Model.ChildRemoved:connect(function(Child)
	ClearModel()
end)

wait(1)

ClearModel()