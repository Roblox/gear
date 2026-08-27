--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

Direction = script:FindFirstChild("Direction")
Force = script:FindFirstChild("Force")

if Humanoid and Humanoid.Health > 0 and HumanoidRootPart then
	--Humanoid.Sit = true
	Humanoid.PlatformStand = true
	Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	if Direction and Force then
		HumanoidRootPart.Velocity = (Direction.Value * Force.Value)
	else
		HumanoidRootPart.Velocity = ((HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(math.random(-360, 360)), 0)).lookVector * math.random(15, 35))
	end
	wait(3)
	Humanoid.PlatformStand = false
	Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

Debris:AddItem(script, 0.5)