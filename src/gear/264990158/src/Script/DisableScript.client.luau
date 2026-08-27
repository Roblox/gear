--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

if Humanoid then
	
	for i, v in pairs(Humanoid:GetChildren()) do
		if v:IsA("Animator") then
			v:Destroy()
		end
	end
	
	function SetHumanoid()
		Humanoid.AutoRotate = false
		Humanoid.PlatformStand = false
		Humanoid.WalkSpeed = 0
		Humanoid.Jump = false
		Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
	
	function UnequipTools()
		Humanoid:UnequipTools()
	end	
	
	HumanoidChanged = Humanoid.Changed:connect(SetHumanoid)
	ToolEquipped = Character.ChildAdded:connect(UnequipTools)
	
	SetHumanoid()
	UnequipTools()
	
end

wait(10)

for i, v in pairs({HumanoidChanged, ToolEquipped}) do
	if v then
		v:disconnect()
	end
end

Humanoid.AutoRotate = true
Humanoid.PlatformStand = false
Humanoid.WalkSpeed = 16

script:Destroy()