--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

Animations = {
	Scream = {Animation = script:WaitForChild("Scream"), FadeTime = 1, Weight = 1, Speed = 5, Duration = 5},
	Frightened = {Animation = script:WaitForChild("Frightened"), FadeTime = 1, Weight = 1, Speed = 0.5, Duration = 5},
}

RemoteConnection = script:FindFirstChild("RemoteConnection")

function DestroyScript()
	pcall(function()
		RemoteConnection:InvokeServer("Destroy", true)
	end)
	Debris:AddItem(script, 2)
end

if not Humanoid or not RemoteConnection then
	DestroyScript()
	return
end

Humanoid.WalkSpeed = 0
for i, v in pairs(Animations) do
	AnimTrack = Humanoid:LoadAnimation(v.Animation)
	if AnimTrack then
		AnimTrack:Play(v.FadeTime, v.Weight, v.Speed)
	end
	wait(v.Duration)
	if AnimTrack then
		AnimTrack:Stop()
	end
end
Humanoid.WalkSpeed = 16

DestroyScript()