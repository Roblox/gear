--Made by Luckymaxer

Tree = script.Parent
Mesh = Tree:WaitForChild("Mesh")

Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Particles = script:FindFirstChild("Particles")

BaseSize = {
	Size = Vector3.new(0.2, 0.2, 1.3),
	Scale = Vector3.new(0.35, 0.35, 0.5),
}

Rate = (1 / 60)

Tree.Size = BaseSize.Size
Mesh.Scale = BaseSize.Scale

GrowAttemptBegin = tick()
while Tree.Velocity.Magnitude > 1 do
	local Now = tick()
	if (Now - GrowAttemptBegin) >= 5 then
		Debris:AddItem(Tree, 0.5)
	end
	wait(Rate)
end

function InsertAsset(AssetId)
	local AssetModel = InsertService:LoadAsset(AssetId)
	local Asset = AssetModel:GetChildren()[1]:Clone()
	Debris:AddItem(AssetModel, 1)
	return Asset
end

function TweenVector(Object, Property, Goal, Time)
	Time = (Time * 30)
	local Increment = (Vector3.new((Goal.X - Object[Property].X), (Goal.Y - Object[Property].Y), (Goal.Z - Object[Property].Z)) / Time)
	for i = 1, Time do
		local OriginalCFrame
		if Object:IsA("BasePart") and Property == "Size" then
			OriginalCFrame = Object.CFrame
		end
		Object[Property] = (Object[Property] + Increment)
		if OriginalCFrame then
			Object.CFrame = (OriginalCFrame + Vector3.new(0, (Increment / 2), 0))
		end
		wait()
	end
	return true
end

function InsertPresents(Origin, Radius)
	local Presents = {67316216, 18824203, 99850607, 137384831, 138054739, 326060747}
	for i, v in pairs(Presents) do
		local Present = InsertAsset(v)
		local Handle = Present:FindFirstChild("Handle")
		if Handle then
			local HandleCopy = Handle:Clone()
			HandleCopy.Name = "Present"
			HandleCopy.Material = Enum.Material.Plastic
			HandleCopy.FormFactor = Enum.FormFactor.Custom
			HandleCopy.Friction = 2
			HandleCopy.Elasticity = 0
			HandleCopy.CanCollide = true
			HandleCopy.Parent = Tree
			local GiftSpot = (((CFrame.new(Origin.p) * CFrame.new(0, ((HandleCopy.Size.Y / 2) + (math.random(0, 150) * 0.01)), 0)) + CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0).lookVector * (Radius.Start + (math.random(0, (Radius.End * 100)) * 0.01))) * CFrame.Angles(0, (math.random(-360, 360) * 0.01), 0))
			HandleCopy.CFrame = GiftSpot
			local BodyGyro = Instance.new("BodyGyro")
			BodyGyro.Name = "BodyGyro"
			BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			BodyGyro.cframe = GiftSpot
			BodyGyro.Parent = HandleCopy
			--[[local Weld = Instance.new("Weld")
			Weld.Name = "Weld"
			Weld.Part0 = Tree
			Weld.Part1 = HandleCopy
			Weld.C0 = Tree.CFrame:inverse()
			Weld.C1 = GiftSpot:inverse()
			Weld.Parent = HandleCopy]]
		end
	end
end

function AddTopper()
	local TreeTopper = InsertAsset(136783572)
	local TopperHandle = TreeTopper:FindFirstChild("Handle")
	if TopperHandle then
		local Topper = TopperHandle:Clone()
		local TopperMesh = Topper:FindFirstChild("Mesh")
		if TopperMesh then
			Topper.Name = "TreeTopper"
			Topper.Material = Enum.Material.Plastic
			Topper.FormFactor = Enum.FormFactor.Custom
			Topper.Size = Vector3.new(0.2, 0.2, 0.2)
			Topper.CanCollide = false
			TopperMesh.Scale = Vector3.new(8, 8, 8)
			local Light = Instance.new("PointLight")
			Light.Name = "Light"
			Light.Color = Color3.new((255 / 255), (255 / 255), (255 / 255))
			Light.Brightness = 100
			Light.Range = 14
			Light.Shadows = true
			Light.Enabled = true
			Light.Parent = Topper
			local TopperWeld = Instance.new("Motor6D")
			TopperWeld.Name = "Motor"
			TopperWeld.Part0 = Tree
			TopperWeld.Part1 = Topper
			TopperWeld.C0 = (CFrame.new(-0.125, -0.2, -6.5) * CFrame.Angles(-math.pi, 0, 0))
			TopperWeld.C1 = (CFrame.new(0, 0, 0) * CFrame.Angles((math.pi / 2), math.pi, 0))
			TopperWeld.MaxVelocity = 0.01
			TopperWeld.DesiredAngle = 9999999
			TopperWeld.CurrentAngle = 0
			TopperWeld.Parent = Topper
			Topper.Parent = Tree
			if Particles then
				for i, v in pairs(Particles:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						local Particle = v:Clone()
						Particle.Enabled = true
						Particle.Parent = Topper
					end
				end
			end
		end
	end
end


ResizeDone = Instance.new("BoolValue")
ResizeDone.Value = false
RescaleDone = Instance.new("BoolValue")
RescaleDone.Value = false

Spawn(function()
	TweenVector(Tree, "Size", (BaseSize.Size * 10), 2, 1)
	ResizeDone.Value = true
end)
Spawn(function()
	TweenVector(Mesh, "Scale", (BaseSize.Scale * 10), 2, 1)
	RescaleDone.Value = true
end)

while not ResizeDone.Value or not RescaleDone.Value do
	wait()
end

wait(0.1)

AddTopper()
InsertPresents((Tree.CFrame * CFrame.new(0, 0, (Tree.Size.Z / 2))), {Start = 2, End = 4})