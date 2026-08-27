--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

ShiverScript = Character:FindFirstChild("ShiverScript")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
ContentProvider = game:GetService("ContentProvider")

Player = Players:GetPlayerFromCharacter(Character)

Animations = {
	Freeze = {Animation = script:WaitForChild("Freeze"), FadeTime = nil, Weight = nil, Speed = nil},
	Shiver = {Animation = script:WaitForChild("Shiver"), FadeTime = nil, Weight = nil, Speed = 1.5},
}

function DestroyScript()
	Debris:AddItem(script, 0.5)
	Spawn(function()
		script:Destroy()
	end)
end

if not ShiverScript or not Humanoid or Humanoid.Health == 0 then
	return
end

for i, v in pairs(Animations) do
	Spawn(function()
		ContentProvider:Preload(v.Animation.AnimationId)
	end)
end

Animation = Animations.Freeze
CurrentAnimation = Humanoid:LoadAnimation(Animation.Animation)
if CurrentAnimation then
	CurrentAnimation:Play(Animation.FadeTime, Animation.Weight, Animation.Speed)
end

Delay(0.25, (function()
	wait(0.25)
	Animation = Animations.Shiver
	CurrentAnimation = Humanoid:LoadAnimation(Animation.Animation)
	if CurrentAnimation then
		CurrentAnimation:Play(Animation.FadeTime, Animation.Weight, Animation.Speed)
	end
end))

DisableJump = Humanoid.Changed:connect(function(Property)
	if Property == "Jump" then
		Humanoid.Jump = false
	end
end)

ShiverScript.Changed:connect(function(Property)
	if Property == "Parent" and not ShiverScript.Parent then
		if CurrentAnimation then
			CurrentAnimation:Stop()
		end
		DestroyScript()
	end
end)