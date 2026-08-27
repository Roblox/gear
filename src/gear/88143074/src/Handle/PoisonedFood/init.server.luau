local Food = script.Parent

while not script:FindFirstChild("Creator") or not script.Creator.Value do wait() end
local creator = script.Creator.Value

while not script:FindFirstChild("Eating") do wait() end
local eatingScript = script.Eating

-- When someone steps on the food, drop what they're holding and attach the food to them along with an eatingScript
-- (They must: Not be the creator, be alive, have a right arm, not be eating, and not be poisoned)
Food.Touched:connect(function(otherPart)
	if otherPart and otherPart.Parent and otherPart.Parent:IsA("Model") and otherPart.Parent ~= creator then
		local otherModel = otherPart.Parent
		if otherModel:FindFirstChild("Humanoid") and otherModel.Humanoid.Health > 0 and otherModel:FindFirstChild("Right Arm") then
			local otherHumanoid = otherModel.Humanoid
			if not otherHumanoid:FindFirstChild(eatingScript.Name) and not otherHumanoid:FindFirstChild("Poisoned") then
				if Food:FindFirstChild("SelfDestruct") then Food.SelfDestruct:Destroy() end -- lol
				if Food:FindFirstChild("BodyGyro") then Food.BodyGyro:Destroy() end
				local children = otherModel:GetChildren()
				for i = 1, #children do -- Remove current Tool
					local child = children[i]
					if child and child:IsA("Tool") then
						child.Parent = Workspace
						break
					end
				end
				Food.Parent = otherModel
				local weld = Instance.new("Weld", Game.JointsService)
				weld.Part0 = otherModel["Right Arm"]
				weld.Part1 = Food
				weld.C1 = CFrame.Angles(math.pi/2, 0, 0) + Vector3.new(0, 0, 1.4)
				local eatingScriptClone = eatingScript:Clone()
				Game:GetService("Debris"):AddItem(eatingScriptClone, 60) -- In case non-player humanoids pick it up
				eatingScriptClone.Parent = otherHumanoid
				eatingScriptClone.Disabled = false
				script:Destroy()
			end
		end
	end
end)
