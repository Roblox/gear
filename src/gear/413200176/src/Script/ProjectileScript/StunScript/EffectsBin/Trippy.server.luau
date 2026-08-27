--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

if Humanoid and Humanoid.Health > 0 and HumanoidRootPart then
	local Start = tick()
	while (tick() - Start) < 15 do
		Humanoid.PlatformStand = true
		Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		HumanoidRootPart.Velocity = (HumanoidRootPart.CFrame.lookVector * 15)
		wait(2)
		Humanoid.PlatformStand = false
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

Debris:AddItem(script, 0.5)