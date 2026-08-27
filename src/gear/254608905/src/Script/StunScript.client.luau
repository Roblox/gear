--Made by Luckymaxer

Debris = game:GetService("Debris")

Duration = script:WaitForChild("Duration")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

function DestroyScript()
	Debris:AddItem(script, 0.5)
	script:Destroy()
	Humanoid.PlatformStand = false
	Humanoid.AutoRotate = true
end

function Stun()
	Humanoid.PlatformStand = true
	Humanoid.AutoRotate = false
	Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

if not Duration or Duration.Value <= 0 or not Humanoid or Humanoid.Health == 0 then
	DestroyScript()
	return
end

Stun()

Humanoid.Changed:connect(function()
	Stun()
end)

wait(Duration.Value)

DestroyScript()