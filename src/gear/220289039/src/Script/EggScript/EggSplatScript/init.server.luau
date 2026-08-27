--Made by Luckymaxer

Part = script.Parent

Players = game:GetService("Players")

SlowScript = script:WaitForChild("SlowScript")

Creator = script:WaitForChild("Creator")

function Splat(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local Player = Creator.Value
	local Character = (((Player and Player.Parent and Player:IsA("Player") and Player.Character) and Player.Character) or nil)
	local HumanoidHit = false
	local character = Hit.Parent
	if character:IsA("Accessory") then
		character = Hit.Parent
	end
	if character == Character or character.Parent == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local SlowScriptClone = character:FindFirstChild(SlowScript.Name)
	if not SlowScriptClone then
		SlowScriptClone = SlowScript:Clone()
		local Duration = Instance.new("NumberValue")
		Duration.Name = "Duration"
		Duration.Parent = SlowScriptClone
	end
	SlowScriptClone.Duration.Value = 5
	SlowScriptClone.Disabled = false
	SlowScriptClone.Parent = character
end

Part.Touched:connect(Splat)