--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")

FadeRate = 0.05
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

RemoveModel()

while true do
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("Model") then
			for ii, vv in pairs(v:GetChildren()) do
				if vv:IsA("BasePart") and vv.Transparency < 1 then
					local NewTransparency = (vv.Transparency + FadeRate)
					vv.Transparency = ((NewTransparency <= 1 and NewTransparency) or 1)
					if vv.Transparency >= 1 then
						for iii, vvv in pairs(vv:GetChildren()) do
							if vvv:IsA("Light") or vvv:IsA("Fire") or vvv:IsA("Smoke") or vvv:IsA("ParticleEmitter") then
								vvv.Enabled = false
							end
						end
					end
				end
			end
		end
	end
	wait(Rate)
end

