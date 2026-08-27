local Blob = script.Parent
local PoisonScript = script.Poisoned
local Creator = script.Creator.Value

-- OnTouched: Do damage, move PoisonScript, and destroy Blob
Blob.Touched:connect(function(otherPart)
	if otherPart and otherPart.Parent and otherPart.Parent:IsA("Model") then
		local otherModel = otherPart.Parent
		if otherModel ~= Creator and not otherModel:IsAncestorOf(Creator) then
			local humanoid = otherModel:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(5)
				PoisonScript.Parent = humanoid
				PoisonScript.Disabled = false
				Blob:Destroy()
			end
		end
	end
end)
