--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Standing = Tool:WaitForChild("Standing")
JumpPose1 = Tool:WaitForChild("JumpPose1")
JumpPose2 = Tool:WaitForChild("JumpPose2")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = 15
ReloadTime = 2

LastJump = 0
TotalJumps = 0

Equipped = false
HumanoidFreeFalling = nil
DoubleJumpped = false
Falling = false
Spinning = false
CurrentlySpinning = false

Grips = {
	Equipped = CFrame.new(0, 0, 0, 1, 0, 0, -0, 8.90154915e-005, 1, 0, -1, 8.90154915e-005),
	Unequipped = CFrame.new(-1.5, 1.5, -1.5, -0, -8.10218646e-013, 0.99999994, 3.01405407e-007, 1, 8.10218537e-013, -1, 3.01405407e-007, 2.44204241e-019)
}

Spawn(function()
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end)

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function GetTotalMass(Parent)
	local Mass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v:IsA("BasePart") then
				Mass = (Mass + v:GetMass())
			end
			GetMass(v)
		end
	end
	GetMass(Parent)
	return Mass
end

function DoubleJump()
	if Player and Humanoid.Parent and Humanoid.Health > 0 and not DoubleJumpped then
		DoubleJumpped = true
		Falling = true
		Torso.Velocity = Torso.Velocity + Vector3.new(0, 75, 0)
		if FallDelay and FallDelay.Parent then
			FallDelay:Destroy()
		end
		FallDelay = Instance.new("BodyVelocity")
		FallDelay.Name = "FallDelay"
		FallDelay.maxForce = Vector3.new(0, 0, 0)
		FallDelay.velocity = Vector3.new(0, 0, 0)
		Delay(0.75, function()
			FallDelay.maxForce = Vector3.new(0, (GetTotalMass(Character) * 196.2 ^ 2), 0)
			FallDelay.velocity = Vector3.new(0, -25, 0)
		end)
		Debris:AddItem(FallDelay, 3)
		FallDelay.Parent = Torso
		if StandingAnim then
			StandingAnim:Stop()
		end
		JumpPose1Anim = Humanoid:LoadAnimation(JumpPose1)
		if JumpPose1Anim then
			JumpPose1Anim:Play()
		end
		wait(0.25)
		if Equipped then
			if JumpPose1Anim then
				JumpPose1Anim:Stop()
			end
			JumpPose2Anim = Humanoid:LoadAnimation(JumpPose2)
			if JumpPose2Anim then
				JumpPose2Anim:Play()
			end
		end
		wait(1)
		DoubleJumpped = false
	end	
end

function Activated()
	if not Spinning and Tool.Enabled then
		Tool.Enabled = false
		Spinning = true
		CurrentlySpinning = true
		local OriginalCFrame = Torso.CFrame
		RotateForce = Instance.new("BodyGyro")
		RotateForce.Name = "RotateForce"
		RotateForce.maxTorque = Vector3.new((GetTotalMass(Character) * 196.20 ^ 2), (GetTotalMass(Character) * 196.20 ^ 2), (GetTotalMass(Character) * 196.20 ^ 2))
		RotateForce.cframe = Torso.CFrame
		RotateForce.Parent = Torso
		for i = 1, 20 do
			if not Spinning or not Equipped then
				break
			end
			Torso.CFrame = Torso.CFrame * CFrame.Angles(0, 0.3, 0)
			RotateForce.cframe = Torso.CFrame
			wait(0.05)
		end
		CurrentlySpinning = false
		if Spinning and Equipped then
			RotateForce.cframe = OriginalCFrame
			wait(0.5)
			if RotateForce and RotateForce.Parent then
				RotateForce:Destroy()
			end
		end
		wait(ReloadTime)
		Spinning = false
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	RightArm = Character:FindFirstChild("Right Arm")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Tool.Grip = Grips.Equipped
	if RightArm then
		local RightGrip = RightArm:FindFirstChild("RightGrip")
		if RightGrip then
			RightGrip:Destroy()
		end
		RightGripAdded = RightArm.ChildAdded:connect(function(Child)
			wait()
			if Child and Child.Parent and Child.Name == "RightGrip" and Child:IsA("JointInstance") then
				Child:Destroy()
			end
		end)
	end
	HandleWeld = Instance.new("Weld")
	HandleWeld.Part0 = Torso
	HandleWeld.Part1 = Handle
	HandleWeld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
	HandleWeld.C1 = CFrame.new(0, 0, 0, 1, 0, 0, -0, 8.90154915e-005, 1, 0, -1, 8.90154915e-005)
	HandleWeld.Parent = Torso
	StandingAnim = Humanoid:LoadAnimation(Standing)
	if StandingAnim then
		StandingAnim:Play()
	end
	HumanoidFalling = Humanoid.FreeFalling:connect(function(Value)
		if not Value and Equipped then
			Torso.Velocity = Vector3.new(0, 0, 0)
			if JumpPose2Anim then
				JumpPose2Anim:Stop()
			end
			if Falling then
				if StandingAnim then
					StandingAnim:Play()
				end
				if FallDelay and FallDelay.Parent then
					FallDelay:Destroy()
				end
			end
			Falling = false
		end
	end)
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == " " and not Falling then
			local CurrentJump = tick()
			TotalJumps = TotalJumps + 1
			if (tick() - LastJump) <= 0.3 then
				if TotalJumps <= 2 then
					Spawn(function()
						DoubleJump()
					end)
					TotalJumps = 0
				end
			else
				TotalJumps = 0
			end
			LastJump = CurrentJump
		end
	end)
end

function Unequipped()
	Equipped = false
	DoubleJumpped = false
	Falling = false
	CurrentlySpinning = false
	if HandleWeld and HandleWeld.Parent then
		HandleWeld:Destroy()
	end
	if StandingAnim then
		StandingAnim:Stop()
	end
	if JumpPose1Anim then
		JumpPose1Anim:Stop()
	end
	if JumpPose2Anim then
		JumpPose2Anim:Stop()
	end
	if RightGripAdded then
		RightGripAdded:disconnect()
	end
	if HumanoidFalling then
		HumanoidFalling:disconnect()
	end
	if FallDelay and FallDelay.Parent then
		FallDelay:Destroy()
	end
	if RotateForce and RotateForce.Parent then
		RotateForce:Destroy()
	end
	Tool.Grip = Grips.Unequipped
end

Handle.Touched:connect(function(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit)
		if character and character ~= Character and humanoid and humanoid.Health > 0 then
			if CurrentlySpinning then
				Hit.Velocity = CFrame.new(Handle.Position, Hit.Position).lookVector * 100
			end
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(Damage)
		end
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)