-- // Made by StarWars

local Car = {}
Car.__index = Car

local function WeldModel(model, primaryPart)
	for i, v in ipairs(model:GetChildren()) do
		if v:IsA("BasePart") then
			if v ~= primaryPart then
				local NewWeld = Instance.new("Weld")
				NewWeld.Name = v.Name
				NewWeld.Part0 = primaryPart
				NewWeld.Part1 = v 
				NewWeld.C0 = primaryPart.CFrame:toObjectSpace(v.CFrame)
				NewWeld.Parent = primaryPart
				v.Anchored = false	
			end
		end
	end
	
	primaryPart.Anchored = false
end

function Car.new(owner, model)
	local self = {}
	
	self.Owner = owner
	self.Model = model
	self.Speed = 0	
	self.WheelRotation = Vector3.new()
	
	WeldModel(self.Model, self.Model.PrimaryPart)	
	
	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyPosition.Position = self.Model.PrimaryPart.Position
	BodyPosition.Parent = self.Model.PrimaryPart	
	
	local Torso = self.Owner:FindFirstChild("HumanoidRootPart")
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.D = 500
	BodyGyro.P = 1500
	BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	if Torso then
		BodyGyro.CFrame = Torso.CFrame
	end
	BodyGyro.Parent = self.Model.PrimaryPart	
	
	setmetatable(self, Car)
	return self
end

function Car:Update(delta)
	local FrontLeftWeld = self.Model.Body:FindFirstChild("Front_LeftWheel")
	local FrontRightWeld = self.Model.Body:FindFirstChild("Front_RightWheel")
	local BackLeftWeld = self.Model.Body:FindFirstChild("Back_LeftWheel")
	local BackRightWeld = self.Model.Body:FindFirstChild("Back_RightWheel")	
	if not FrontLeftWeld or not FrontRightWeld or not BackLeftWeld or not BackRightWeld then return end

	local BodyPosition = self.Model.Body:FindFirstChild("BodyPosition")
	if not BodyPosition then return end
	
	local BodyGyro = self.Model.Body:FindFirstChild("BodyGyro")
	if not BodyGyro then return end
	
	local Torso = self.Owner.Character:FindFirstChild("HumanoidRootPart")
	local Humanoid = self.Owner.Character:FindFirstChildOfClass("Humanoid")
	if not Torso then return end
	if not Humanoid then return end
	
	local DownVector = CFrame.new(Torso.Position, Torso.Position - Vector3.new(0, 1, 0)).lookVector
	local NewRay = Ray.new(Torso.Position, DownVector.Unit * 999)
	
	local Hit, EndPoint = workspace:FindPartOnRayWithIgnoreList(NewRay, {self.Model, self.Owner.Character})
	local SizeY = self.Model.PrimaryPart.Size.Y
	
	local OffsetY = Hit and EndPoint.Y + (SizeY * 0.5) or 0

	BodyPosition.Position = Torso.CFrame:pointToWorldSpace(Vector3.new(0, 0, 10)) + Vector3.new(0, OffsetY, 0) - Vector3.new(0, Torso.Position.Y, 0)
	BodyGyro.CFrame = Torso.CFrame
	
	local Velocity = self.Model.PrimaryPart.Velocity * Vector3.new(1, 0, 1)
	
	FrontLeftWeld.C0 = FrontLeftWeld.C0 * CFrame.Angles(math.rad(-50) * Velocity.Magnitude * delta, 0, 0)
	FrontRightWeld.C0 = FrontRightWeld.C0 * CFrame.Angles(math.rad(-50) * Velocity.Magnitude * delta, 0, 0)
	BackLeftWeld.C0 = BackLeftWeld.C0 * CFrame.Angles(math.rad(-50) * Velocity.Magnitude * delta, 0, 0)
	BackRightWeld.C0 = BackRightWeld.C0 * CFrame.Angles(math.rad(-50) * Velocity.Magnitude * delta, 0, 0)		
end

return Car