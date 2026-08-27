ball = script.Parent
damage = 25

debris = game:GetService("Debris")
debris:AddItem(ball, 10)

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=25918935"
HitSound.Pitch = .5
HitSound.Parent = ball


function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function getPlayerHats(player)
	
	local hatTable = {}
	local stuff = player:GetChildren()
	for i = 1, #stuff do
		if stuff[i]:IsA("Accessory") then
			table.insert(hatTable,stuff[i])
		end
	end
	return hatTable

end

function onTouched(hit)
	local humanoid,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
	connection:Disconnect()
	local bf = ball:FindFirstChild("BulletFloat")
	if bf then bf:Destroy() end

	if hit:FindFirstChild("GravityScript") or FF then ball:Destroy() return end
	local Script = ball.GravityScript:Clone()
	if humanoid then
		if not humanoid or humanoid.health <= 0 or IsTeamMate(ball:WaitForChild("creator",math.huge).Value,game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent)) or ball:WaitForChild("creator",math.huge).Value == game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent) then Script:Destroy() return end
		Script.Parent = humanoid.Parent:FindFirstChild("Torso") or humanoid.Parent:FindFirstChild("UpperTorso")
	elseif not hit.Anchored then
		hit:BreakJoints()
		Script.Parent = hit
	end
	if Script then
		Script.Disabled = false
	end
	
	ball:Destroy()
end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = ball:FindFirstChild("creator")
	if tag then
		local new_tag = tag:Clone()
		new_tag.Parent = humanoid
		debris:AddItem(new_tag, 1)
	end
end



connection = ball.Touched:Connect(onTouched)


