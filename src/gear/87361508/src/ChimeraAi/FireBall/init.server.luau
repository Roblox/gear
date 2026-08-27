local Ball = script.Parent
local BurnScript = script.Burning
local Creator = script.Creator.Value

-- OnTouched: Do damage, move BurnScript, and destroy Ball
Ball.Touched:connect(function(otherPart)
	if otherPart and otherPart.Parent and otherPart.Parent:IsA("Model") then
		local otherModel = otherPart.Parent
		if otherModel ~= Creator and not otherModel:IsAncestorOf(Creator) then
			local humanoid = otherModel:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(10)
				BurnScript.Parent = humanoid
				BurnScript.Disabled = false
				Ball:Destroy()
			end
		end
	end
end)
