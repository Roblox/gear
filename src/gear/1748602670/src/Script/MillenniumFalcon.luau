-- // Created by StarWars
local Falcon = {}
Falcon.__index = Falcon 

local basePart = Instance.new("Part")
basePart.Size = Vector3.new(1, 1, 1)
basePart.Anchored = false
basePart.CanCollide = false

local baseFalcon = basePart:Clone()
local baseMesh = Instance.new("SpecialMesh")
baseMesh.TextureId = "rbxassetid://1743837502"
baseMesh.MeshId = "rbxassetid://1777617033"
baseMesh.Parent = baseFalcon

local OFFSET_POSITION = Vector3.new(4, 4, 8)

-- // Helper functions
local function constructShip(player)
	local newPart = baseFalcon:Clone()
	newPart.Name = player.Name .. "'s Falcon"
	
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.MaxForce = Vector3.new(newPart:GetMass() * workspace.Gravity, math.huge, newPart:GetMass() * workspace.Gravity)
	bodyPosition.Parent = newPart
	
	local bodyGyro = Instance.new("BodyGyro") 
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.Parent = newPart
	
	local attachment0 = Instance.new("Attachment")
	attachment0.Position = Vector3.new(-2.25, -0.125, 3.75)
	attachment0.Parent = newPart
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(2.25, -0.125, 3.75)
	attachment1.Parent = newPart
	
	local newTrail = Instance.new("Trail")
	newTrail.Color = ColorSequence.new(Color3.fromRGB(126, 255, 255))
	newTrail.LightEmission = 1
	newTrail.LightInfluence = 0
	newTrail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
	newTrail.Attachment0 = attachment0
	newTrail.Attachment1 = attachment1
	newTrail.Parent = newPart
	
	newPart.Parent = player.Character
	return newPart
end

-- // API
function Falcon:Update()
	if self.Owner and self.Owner.Character and self.Owner.Character.PrimaryPart and self.Model then
		local newCFrame = self.Owner.Character.PrimaryPart.CFrame * CFrame.new(OFFSET_POSITION)
		
		if not self.BodyPosition then
			self.BodyPosition = self.Model:FindFirstChild("BodyPosition")
		end
		if not self.BodyGyro then
			self.BodyGyro = self.Model:FindFirstChild("BodyGyro")
		end
		
		if self.BodyPosition then
			self.BodyPosition.Position = newCFrame.p
		end
		if self.BodyGyro then
			self.BodyGyro.CFrame = newCFrame
		end
	end
end

function Falcon:Destroy()
	if self.Model then
		self.Model:Destroy()
	end
	
	self.Model = nil
	self.Owner = nil
end

-- // Constructor
function Falcon.new(player)
	local newFalcon = setmetatable({}, Falcon)
	
	local newPart = constructShip(player)
	
	newFalcon.Owner = player
	newFalcon.Model = newPart	
	
	return newFalcon
end

return Falcon