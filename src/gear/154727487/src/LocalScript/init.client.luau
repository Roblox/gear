--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

TouchScript = script:WaitForChild("TouchScript")

StandardC1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(0, (math.pi / 2), 0)

Debris = game:GetService("Debris")
Players = game:GetService("Players")

ReloadTime = 10

function Activated()
	if Tool.Enabled and Humanoid and Humanoid.Health > 0 and RightShoulder then
		Tool.Enabled = false
		for i = 1, 15 do
			RightShoulder.C1 = StandardC1 * CFrame.Angles(0, 0, (-i * (math.pi / 30)))
			wait()
		end
		wait(0.1)
		TargetPoint = Humanoid.TargetPoint
		TargetDir = Torso.CFrame:pointToObjectSpace(TargetPoint) - Vector3.new(1, 0.5, 0)
		TargetVertAngle = math.atan(TargetDir.Y / TargetDir.Z)
		if TargetDir.Z > 0 then
			if TargetDir.X > 0 then 
				TargetHorAngle = (math.pi / 2)
			else
				TargetHorAngle = (-math.pi / 2)
			end
		else
			TargetHorAngle = math.atan(TargetDir.X / TargetDir.magnitude)
		end
		local HandleClone = Handle:Clone()
		Handle.Friction = 2
		Handle.Elasticity = 0
		Handle.Transparency = 1
		HandleClone.CanCollide = true
		HandleClone.Locked = true
		local Creator = Instance.new("ObjectValue")
		Creator.Name = "Creator"
		Creator.Value = Player
		Creator.Parent = HandleClone
		local TouchScriptClone = TouchScript:Clone()
		TouchScriptClone.Disabled = false
		TouchScriptClone.Parent = HandleClone
		Debris:AddItem(HandleClone, 5)
		HandleClone.Velocity = CFrame.new(Handle.Position, TargetPoint).lookVector * 100
		HandleClone.Parent = game:GetService("Workspace")
		HandleClone.CFrame = Handle.CFrame
		for i = 1, 5 do
			wait()
			RightShoulder.C1 = StandardC1 * CFrame.Angles((i * (TargetHorAngle / 5)), 0, (((i - 5) * (math.pi / 10)) + (i * (TargetVertAngle / 5))))
		end
		wait(0.2)
		for i = 10, 0, -1 do
			wait()
			RightShoulder.C1 = StandardC1 * CFrame.Angles((i * (TargetHorAngle / 10)), 0, 0)
		end
		wait(ReloadTime)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	RightShoulder = Torso:FindFirstChild("Right Shoulder")
	if not Player or not Humanoid or not Humanoid.Health == 0 or not Torso or not RightShoulder then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end


function Unequipped()
	Handle.Transparency = 0
	if RightShoulder then
		RightShoulder.C1 = StandardC1
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)