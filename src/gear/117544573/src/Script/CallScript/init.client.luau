--Rescripted by Luckymaxer

Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

LaughTime = script:WaitForChild("LaughTime")

LaughAnimation = script:WaitForChild("LaughAnimation")
CheerSound = script:WaitForChild("CheerSound")

CheerSound:Play()
LaughTrack = Humanoid:LoadAnimation(LaughAnimation)
LaughTrack:Play(nil, nil, 3)

function DestroyScript()
	Debris:AddItem(script, 0.5)
	script:Destroy()
end

if not Humanoid or Humanoid.Health == 0 then
	DestroyScript()
	return
end

Delay(LaughTime.Value, (function()
	LaughTrack:Stop()
	CheerSound:Stop()
	DestroyScript()
end))