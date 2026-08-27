Cake = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Debounce = false

while not script:FindFirstChild("creator") or not script.creator.Value do
	wait()
end

Creator = script.creator.Value

EatingScript = script:WaitForChild("Poisoned")

Cake.Touched:connect(function(Hit)
	if Hit and Hit.Parent and Hit.Parent:IsA("Model") and not Hit.Parent:FindFirstChild("ForceField") and not Debounce then
		local ModelHit = Hit.Parent
		local PlayerHit = Players:GetPlayerFromCharacter(ModelHit)
		if PlayerHit and PlayerHit == Creator then
			return
		end
		if ModelHit:FindFirstChild("Humanoid") and ModelHit.Humanoid.Health > 0 and ModelHit:FindFirstChild("Right Arm") then
			local HumanoidHit = ModelHit.Humanoid
			if not HumanoidHit:FindFirstChild(EatingScript.Name) and not HumanoidHit:FindFirstChild("Poisoned") then
				Debounce = true
				if Cake:FindFirstChild("SelfDestruct") then
					Cake.SelfDestruct:Destroy()
				end
				if Cake:FindFirstChild("BodyGyro") then
					Cake.BodyGyro:Destroy()
				end
				for i, v in pairs(ModelHit:GetChildren()) do
					if v and v:IsA("Tool") then
						v.Parent = game:GetService("Workspace")
					end
				end
				Cake.Parent = ModelHit
				local Weld = Instance.new("Weld", game.JointsService)
				Weld.Part0 = ModelHit:FindFirstChild("Right Arm")
				Weld.Part1 = Cake
				Weld.C1 = CFrame.Angles((math.pi / 2), 0, 0) + Vector3.new(0, 0, 1.4)
				local EatingScriptClone = EatingScript:Clone()
				Debris:AddItem(EatingScriptClone, 30) -- In case non-player humanoids pick it up
				EatingScriptClone.Parent = HumanoidHit
				EatingScriptClone.Disabled = false
			end
		end
	end
end)
