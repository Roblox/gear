--Made by Luckymaxer

Character = script.Parent

Debris = game:GetService("Debris")

Duration = script:FindFirstChild("Duration")

BaseUrl = "http://www.roblox.com/asset/?id="

Rate = (1 / 60)

if Duration then
	Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		Humanoid.WalkSpeed = 6
	end
end

while Duration.Value > 0 do
	local Time = wait(Rate)
	Duration.Value = (Duration.Value - Time)
end

if Humanoid then
	Humanoid.WalkSpeed = 16
end

Debris:AddItem(script, 0.25)