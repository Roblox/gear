--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = Part:WaitForChild("Creator")

BaseUrl = "http://www.roblox.com/asset/?id="

SplatTouchScript = script:WaitForChild("SplatTouchScript")

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

Part.Touched:connect(function(Hit)
	if not Hit or not Hit.Parent or Hit.Name == Part.Name then
		return
	end
	local Player = Creator.Value
	if not Player or not Player:IsA("Player") then
		return
	end
	local Character = Player.Character
	local character = Hit.Parent
	if character:IsA("Hat") or character:IsA("Tool") then
		character = character.Parent
	end
	if character == Character then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player == Player then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not IsTeamMate(Player, player) and humanoid and humanoid.Health > 0 then
		local SplatTouchScriptClone = character:FindFirstChild(SplatTouchScript.Name)
		if not SplatTouchScriptClone then
			SplatTouchScriptClone = SplatTouchScript:Clone()
			local Duration = Create("NumberValue"){
				Name = "Duration",
				Value = math.huge,
				Parent = SplatTouchScriptClone,
			}
			SplatTouchScriptClone.Disabled = false
			SplatTouchScriptClone.Parent = character
		end
		SplatTouchScriptClone:FindFirstChild("Duration").Value = 5
	end
end)