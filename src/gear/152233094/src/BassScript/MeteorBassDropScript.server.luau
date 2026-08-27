--Made by Luckymaxer
--[[
	Fixed by ArceusInator
	1/23/2015 - It actually does damage now
--]]

BassDrop = script.Parent
Creator = BassDrop:WaitForChild("creator")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BassDrop.Touched:connect(function(hitPart)
	local explosion = Instance.new('Explosion')
	explosion.BlastPressure = 0
	explosion.BlastRadius = 10
	explosion.Parent = BassDrop
	explosion.Position = BassDrop.CFrame.p
	BassDrop.Transparency = 1
	if BassDrop:FindFirstChild('Fire') then
		BassDrop.Fire.Enabled = false
	end
	local hitHumanoids = {}
	explosion.Hit:connect(function(hitPart)
		local hitParent = hitPart.Parent
		if hitParent and hitParent.Parent then
			local humanoid = hitParent:FindFirstChild("Humanoid")
			local player = Players:GetPlayerFromCharacter(hitParent)
			if humanoid and humanoid.Health > 0 and not hitHumanoids[humanoid] and (player and player ~= Creator.Value and (player.TeamColor~=Creator.Value.TeamColor or player.Neutral or Creator.Value.Neutral) or not player) then
				hitHumanoids[humanoid]=true
				for i, v in pairs(humanoid:GetChildren()) do
					if v.Name == "creator" then
						v:Destroy()
					end
				end
				local creator = Creator:Clone()
				creator.Value = Creator.Value
				Debris:AddItem(creator, 2)
				creator.Parent = humanoid
				humanoid:TakeDamage(35)
			end
		end
	end)
	wait(1)
	BassDrop:Destroy()
end)