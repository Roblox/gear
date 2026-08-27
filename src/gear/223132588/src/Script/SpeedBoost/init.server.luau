--Made by Luckymaxer

Part = script.Parent

Logo = Part:WaitForChild("Logo")

SpeedScript = script:WaitForChild("SpeedScript")

Duration = 10

function Touched(Hit)
	if not Hit or not Hit.Parent then
		return
	end
	local character = Hit.Parent
	if character:IsA("Hat") then
		character = character.Parent
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local CurrentSpeedScript = humanoid:FindFirstChild(SpeedScript.Name)
	if CurrentSpeedScript then
		return
	end
	CurrentSpeedScript = SpeedScript:Clone()
	local DurationValue = Instance.new("NumberValue")
	DurationValue.Name = "Duration"
	DurationValue.Value = Duration
	DurationValue.Parent = CurrentSpeedScript
	CurrentSpeedScript.Disabled = false
	CurrentSpeedScript.Parent = humanoid
end

Logo.Enabled = true
Delay(5, function()
	Logo.Enabled = false
end)

Part.Touched:connect(Touched)