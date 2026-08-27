Debris = game:GetService("Debris")

Functions = {
	
	IsTeamMate = (function(Player1, Player2)
		return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
	end),
	
	TagHumanoid = (function(humanoid, player)
		local Creator_Tag = Instance.new("ObjectValue")
		Creator_Tag.Name = "creator"
		Creator_Tag.Value = player
		Debris:AddItem(Creator_Tag, 2)
		Creator_Tag.Parent = humanoid
	end),
	
	UntagHumanoid = (function(humanoid)
		for i, v in pairs(humanoid:GetChildren()) do
			if v:IsA("ObjectValue") and v.Name == "creator" then
				v:Destroy()
			end
		end
	end),
	
	IsFlipped = (function(CFrame)
		local V1 = CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Top))
		local V2 = Vector3.new(0, 1, 0)
		local Angle = math.acos(V1:Dot(V2))
		return (Angle > 2)
	end),
	
}

return Functions