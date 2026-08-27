--Made by Luckymaxer

Blimp = script.Parent

BodyPosition = Blimp:WaitForChild("BodyPosition")
BodyGyro = Blimp:WaitForChild("BodyGyro")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Creator = Blimp:WaitForChild("Creator")
Duration = Blimp:WaitForChild("Duration")

Paused = false

function GetCreator()
	return (((Creator and Creator.Value and Creator.Value:IsA("Player") and Creator.Value.Parent) and Creator.Value) or nil)
end

function GetCharacter()
	local creator = GetCreator()
	return (((creator and creator.Character and creator.Character.Parent) and creator.Character) or nil)
end

function CheckAlive()
	local Character = GetCharacter()
	if not Character then
		return
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	return ((Humanoid and Humanoid.Health > 0) or false)
end

RunService.Stepped:connect(function(Time, Step)
	if Paused then
		return
	end
	if not CheckAlive() then
		Paused = true
		Debris:AddItem(Blimp, 2)
	else
		local Character = GetCharacter()
		local Head = Character:FindFirstChild("Head")
		if Head then
			local pos = (CFrame.new(Head.Position) * CFrame.Angles(0, (math.pi * 2 * ((tick() / 9) % 1)), 0) * CFrame.new(8.5, 10, 0))
			BodyPosition.position = pos.p
			BodyGyro.cframe = pos
		end
	end
end)

Debris:AddItem(Blimp, Duration.Value)