--Made by Luckymaxer

Model = script.Parent

Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

SpreadRate = 0.25

Sparkles = {}

function RemoveIfEmpty()
	local Children = (#Model:GetChildren() - 1)
	if Children == 0 then
		Model.Name = ""
		Debris:AddItem(Model, 0.5)
		Model:Destroy()
	end
end

Spawn(function()
	RunService.Heartbeat:connect(function()
		for i, v in pairs(Sparkles) do
			if v.Sparkle and v.Sparkle.Parent then
				if v.Acceleration.Magnitude >= 1.5 then --Increase velocity
					local AbsorptionRate = 0.75
					local VelocityGiven = (v.Acceleration * AbsorptionRate)
					local VelocityTaken = (v.Acceleration * (1 - AbsorptionRate))
					v.Velocity = (v.Velocity + (VelocityGiven * 0.01))
					v.Acceleration = (v.Acceleration - VelocityTaken)
				elseif v.Deceleration.Magnitude >= 1.5 then --Decrease velocity
					local AbsorptionRate = 0.5
					local VelocityGiven = (v.Deceleration * AbsorptionRate)
					local VelocityTaken = (v.Deceleration * (1 - AbsorptionRate))
					v.Velocity = (v.Velocity - (VelocityGiven * 0.01))
					v.Acceleration = (v.Deceleration + VelocityTaken)
				else --Maintain velocity
				end
				v.Sparkle.CFrame = (v.Sparkle.CFrame + v.Direction * Vector3.new(v.Velocity.Z, v.Velocity.Y, v.Velocity.Z))
			else
				table.remove(Sparkles, i)
				if #Sparkles == 0 then
					RemoveIfEmpty()
				end
			end
		end
	end)
end)

function HandleSparkles(Object)
	if Object:IsA("BasePart") and Object.Name == "Effect" then
		local Direction = Object:FindFirstChild("Direction")
		local Velocity = Object:FindFirstChild("Velocity")
		local Acceleration = Object:FindFirstChild("AccelerationVelocity")
		local Deceleration = Object:FindFirstChild("DecelerationVelocity")
		if not Direction or not Velocity or not Acceleration or not Deceleration then
			return
		end
		table.insert(Sparkles, {
			Sparkle = Object,
			Direction = Direction.Value,
			Velocity = Velocity.Value,
			Acceleration = Acceleration.Value,
			Deceleration = Deceleration.Value,
		})
	end
end

Model.ChildAdded:connect(function(Child)
	Spawn(function()
		HandleSparkles(Child)
	end)
end)

for i, v in pairs(Model:GetChildren()) do
	Spawn(function()
		HandleSparkles(v)
	end)
end

RemoveIfEmpty()