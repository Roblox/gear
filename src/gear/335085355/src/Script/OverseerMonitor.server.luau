--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")

function MonitorFigure(Figure)
	if Figure:IsA("Model") then
		local Humanoid = Figure:FindFirstChild("Humanoid")
		local Torso = Figure:FindFirstChild("Torso")
		if Humanoid and Torso then
			Torso.Anchored = true
			Delay(1, function()
				Torso.Anchored = false
			end)
			local Part = Instance.new("Part")
			Part.Name = "Effect"
			Part.Transparency = 1
			Part.FormFactor = Enum.FormFactor.Custom
			Part.Size = Vector3.new(0.2, 0.2, 0.2)
			Part.Anchored = true
			Part.CanCollide = false
			local Smoke = Instance.new("Fire")
			Smoke.Color = Color3.new(0, 0, 0)
			Smoke.SecondaryColor = Color3.new(0, 1, 0)
			Smoke.Size = 10
			Smoke.Heat = 100
			Smoke.Parent = Part
			Debris:AddItem(Part, 3)
			Part.Parent = game:GetService("Workspace")
			Part.CFrame = (CFrame.new(Torso.Position) - Vector3.new(0, ((Figure:GetModelSize().y / 2) + (Part.Size.Y / 2)), 0))
			Delay(1, (function()
				Smoke.Enabled = false
			end))
			Humanoid.Died:connect(function()
				wait(1)
				local Parts = {}
				for i, v in pairs(Figure:GetChildren()) do
					if v:IsA("BasePart") then
						table.insert(Parts, v)
						v.Anchored = true
					end
				end
				for i = 1, 100 do
					for i, v in pairs(Parts) do
						if v and v.Parent then
							v.Transparency = v.Transparency + 0.01
						end
					end
					wait(0.05)
				end
				for i, v in pairs(Parts) do
					if v and v.Parent then
						local Part = Instance.new("Part")
						Part.Name = "Effect"
						Part.Transparency = 1
						Part.FormFactor = Enum.FormFactor.Custom
						Part.Size = Vector3.new(0.2, 0.2, 0.2)
						Part.Anchored = true
						Part.CanCollide = false
						local Smoke = Instance.new("Fire")
						Smoke.Color = Color3.new(0, 0, 0)
						Smoke.SecondaryColor = Color3.new(0, 1, 0)
						Smoke.Size = 10
						Smoke.Heat = 100
						Smoke.Parent = Part
						Debris:AddItem(Part, 2)
						Part.Parent = game:GetService("Workspace")
						Part.CFrame = v.CFrame
						v:Destroy()
					end
				end
				Figure:Destroy()
			end)
		end
	end
end

for i, v in pairs(Model:GetChildren()) do
	if v:IsA("Model") then
		MonitorFigure(v)
	end
end

Model.ChildAdded:connect(MonitorFigure)