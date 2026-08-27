local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local ChooseOpponent = Tool:FindFirstChild("ChooseOpponent") or Instance.new("RemoteEvent")
ChooseOpponent.Name = "ChooseOpponent"
ChooseOpponent.Parent = Tool

local Players = (game:FindService("Players") or game:GetService("Players"))

ChooseOpponent.OnServerEvent:Connect(function(client,TargetPlayer)
	local Player = Players:GetPlayerFromCharacter(Tool.Parent)
	if client ~= Player or not TargetPlayer or not TargetPlayer:IsA("Player") or not TargetPlayer.Character then return end
	
	if Tool:FindFirstChild("Opponent") then
		local Torso = (TargetPlayer.Character:FindFirstChild("Torso") or TargetPlayer.Character:FindFirstChild("UpperTorso"))
		if Torso and (Handle.Position-Torso.Position).Magnitude < 16 then
			Tool.Opponent.Value = TargetPlayer
		end
	end
	
end)