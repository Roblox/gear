--Rescripted by Luckymaxer

Figure = script.Parent
Humanoid = Figure:FindFirstChild("Humanoid")
Head = Figure:FindFirstChild("Head")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Gravity = 196.20

Sounds = {
	Applause = script:WaitForChild("Applause"),
}

function RemoveScript()
	Debris:AddItem(script, 0.5)
	script:Destroy()
end

if not Humanoid or Humanoid.Health <= 0 or not Head then
	RemoveScript()
	return
end

Humanoid.WalkSpeed = 0
		
local FakeHead = Head:Clone()
FakeHead.Name = "Effect"
FakeHead.Transparency = 1
FakeHead.CanCollide = false
FakeHead.FormFactor = Enum.FormFactor.Custom
for i, v in pairs({"Front", "Back", "Left", "Right", "Top", "Bottom"}) do
	FakeHead[(v .. "Surface")] = Enum.SurfaceType.SmoothNoOutlines
end

for i, v in pairs(FakeHead:GetChildren()) do
	if v:IsA("Decal") then
		local Decal = v:Clone()
		Decal.Face = (
			(v.Face == Enum.NormalId.Front and Enum.NormalId.Back) or
			(v.Face == Enum.NormalId.Back and Enum.NormalId.Front) or
			(v.Face == Enum.NormalId.Left and Enum.NormalId.Right) or
			(v.Face == Enum.NormalId.Right and Enum.NormalId.Left) or
			(v.Face == Enum.NormalId.Top and Enum.NormalId.Bottom) or
			(v.Face == Enum.NormalId.Bottom and Enum.NormalId.Top)
		)
		Decal.Parent = FakeHead
	elseif not v:IsA("DataModelMesh") then
		v:Destroy()
	end
end

for i, v in pairs(Head:GetChildren()) do
	if v:IsA("Decal") then
		v:Destroy()
	end
end

Mass = ((FakeHead:GetMass() * Gravity) * 25)
		
BodyVelocity = Create("BodyVelocity"){
	Name = "BodyVelocity",
	maxForce = Vector3.new(Mass, Mass, Mass),
	velocity = Vector3.new(0, -1, 0),
	Parent = FakeHead,
}
		
FakeHead.CFrame = (Head.CFrame + Head.CFrame.lookVector * ((Head.Size.Y / 2) - (FakeHead.Size.Z / 2) + 0.05))
Debris:AddItem(FakeHead, 5)
FakeHead.Parent = game:GetService("Workspace")
		
ApplauseSound = Sounds.Applause:Clone()
Debris:AddItem(ApplauseSound, 5)
ApplauseSound.Parent = Head
ApplauseSound:Play()

wait(3)
	
Humanoid.WalkSpeed = 16

RemoveScript()