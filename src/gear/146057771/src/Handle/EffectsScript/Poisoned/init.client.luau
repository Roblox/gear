Debris = game:GetService("Debris")

Humanoid = script.Parent
Character = Humanoid.Parent
Head = Character:WaitForChild("Head")

HumanoidWalkSpeed = nil

EatAnimation = script:WaitForChild("EatAnimation")
ScreamAnimation = script:WaitForChild("ScreamAnimation")

Parts = {}

if Humanoid and Humanoid:IsA("Humanoid") and Head and Character then
	local Cake = Character:FindFirstChild("Cake")
	local AnimTrack = Humanoid:LoadAnimation(EatAnimation)
	if AnimTrack then
		AnimTrack:Play()
	end
	wait(2.2)
	if Cake then
		Cake:Destroy()
	end
	HumanoidWalkSpeed = Humanoid.WalkSpeed
	Humanoid.WalkSpeed = 0
	local HumanoidJump = Humanoid.Changed:connect(function(Property)
		if Property == "Jump" then
			Humanoid.Jump = false
		end
	end)
	for i = 1, math.random(5, 10) do
		for ii = 1, math.random(10, 15) do
			local Part = Instance.new("Part")
			Part.FormFactor = Enum.FormFactor.Custom
			Part.Size = Vector3.new(0.2, 0.2, 0.2)
			Part.TopSurface = Enum.SurfaceType.Smooth
			Part.BottomSurface = Enum.SurfaceType.Smooth
			Part.BrickColor = BrickColor.new("Hot pink")
			Part.Name = "Barf"
			Part.CanCollide = false
			Part.Velocity = Head.CFrame.lookVector + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)) * 5
			Debris:AddItem(Part, 5)
			Part.Parent = game:GetService("Workspace")
			Part.CFrame = Head.CFrame + Head.CFrame.lookVector * ((Head.Size.z / 2) + 0.5)
		end
		wait(0.1)
	end
	local FaceClone = nil
	if Character.Head:FindFirstChild("face") then
		local Face = Character.Head.face
		FaceClone = Face:Clone()
		Face:Destroy()
	end
	local NewFace = Instance.new("Decal", Character.Head)
	NewFace.Name = "face"
	NewFace.Texture = "http://www.roblox.com/asset/?id=22070531"
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("BasePart") then
			table.insert(Parts, {Part = v, Color = v.BrickColor})
		end
	end
	for i, v in pairs(Parts) do
		v.Part.BrickColor = BrickColor.new("Hot pink")
	end
	local AnimTrack = Humanoid:LoadAnimation(ScreamAnimation)
	if AnimTrack then
		AnimTrack:Play(nil, nil, 5)
	end
	wait(15)
	AnimTrack:Stop()
	for i, v in pairs(Parts) do
		v.Part.BrickColor = BrickColor.new(v.Color.Name)
	end
	NewFace:Destroy()
	if FaceClone then
		FaceClone.Parent = Character.Head
	end
	Humanoid.WalkSpeed = HumanoidWalkSpeed
	HumanoidJump:disconnect()
	script:Destroy()
end

wait(20)
script:Destroy()
