local PlayersService = Game:GetService('Players')

local Food = script.Parent

while not script:FindFirstChild("Creator") or not script.Creator.Value do wait() end
local creator = script.Creator.Value

while not script:FindFirstChild("Eating") do wait() end
local eatingScript = script.Eating

-- When someone steps on the food, drop what they're holding and attach the food to them along with an eatingScript
-- (They must: Not be the creator, be alive, have a right arm, not be eating, and not be poisoned)
Food.Touched:connect(function(otherPart)
	if otherPart and otherPart.Parent and otherPart.Parent:IsA("Model") then
		local otherModel = otherPart.Parent
		local otherPlayer = PlayersService:GetPlayerFromCharacter(otherModel)
		if otherPlayer and otherPlayer == creator then
			return
		end
		if otherModel:FindFirstChild("Humanoid") and otherModel.Humanoid.Health > 0 then
			local otherHumanoid = otherModel.Humanoid
			if not otherHumanoid:FindFirstChild(eatingScript.Name) and not otherHumanoid:FindFirstChild("Frogged") then
				if Food:FindFirstChild("SelfDestruct") then Food.SelfDestruct:Destroy() end -- lol
				if Food:FindFirstChild("BodyGyro") then Food.BodyGyro:Destroy() end
				local children = otherModel:GetChildren()
				Food.Parent = otherModel
				Food.Anchored = true
				Food.CanCollide = false
				Food.Transparency = 1
				Game:GetService("Debris"):AddItem(Food,10)
				local eatingScriptClone = eatingScript:Clone()
				Game:GetService("Debris"):AddItem(eatingScriptClone, 30) -- In case non-player humanoids pick it up
				eatingScriptClone.Parent = otherHumanoid
				eatingScriptClone.Disabled = false
				script:Destroy()
			end
		end
	end
end)
