local BadgeService = game:GetService("BadgeService")
local TweenService = game:GetService("TweenService")

local CollectableEgg = {}
local methods = {}
CollectableEgg.__index = methods

function methods:Destroy()
	self.Destroyed = true
	self.Part:Destroy()
	for _, tween in pairs(self.Tweens) do
		tween:Destroy()
	end
end

function methods:Collect(player)
end

function methods:SpawnEgg()
	self.Part = self.Part or self.Template:Clone()
	self.Part.CanCollide = false
	self.Part.Anchored = false
	self.Part.Transparency = 0
end

function methods:Launch()
	
	self.Target = self.Target or self.Origin
	
	local eggVelocity = Vector3.new()
	local t = 0
	
	if self.Target ~= self.Origin then
		local deltaXVector = Vector3.new(self.Target.X, 0, self.Target.Z) - Vector3.new(self.Origin.X, 0, self.Origin.Z)
		local deltaX = deltaXVector.Magnitude
		local deltaY = self.Target.Y - self.Origin.Y
		local theta = (math.pi + 2 * (math.atan2(deltaY, deltaX))) / 4
		local grav = workspace.Gravity
		local axisVelY = math.sqrt((grav * deltaX^2 * math.tan(theta)^2) / (2 * (math.tan(theta) * deltaX - deltaY)))
		local sqrtD = math.sqrt(axisVelY^2 - 2*workspace.Gravity*deltaY)
		t = (axisVelY + sqrtD) / workspace.Gravity
		local axisVelX = deltaX / t
		eggVelocity = deltaXVector.Unit * axisVelX + Vector3.new(0, axisVelY, 0)
	end
	
	local originalSize = self.Part.Size
	self.Part.Size = 0.25 * originalSize
	
	local tween = TweenService:Create(self.Part, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = originalSize
	})
	table.insert(self.Tweens, tween)
	tween:Play()
	
	self.Part.Velocity = eggVelocity
	self.Part.CFrame = CFrame.new(self.Origin)
	self.Part.Parent = workspace
	self.Part:SetNetworkOwner(self.Owner)
	
	delay(t, function()
		if not self.Destroyed then
			self.Part.Velocity = Vector3.new()
			
			local bodyPos = Instance.new("BodyPosition")
			bodyPos.Position = self.Target
			bodyPos.MaxForce = Vector3.new(40000, 40000, 40000)
			bodyPos.Parent = self.Part
			
			local tween = TweenService:Create(bodyPos, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
				Position = bodyPos.Position + Vector3.new(0, 2.5, 0)
			})
			table.insert(self.Tweens, tween)
			tween:Play()
					
			local bodyRot = Instance.new("BodyAngularVelocity")
			bodyRot.AngularVelocity = Vector3.new(0, 0.5, 0)
			bodyRot.Parent = self.Part
			
			self.Part.Touched:Connect(function(hit)
				local collectingPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
				if collectingPlayer then
					
					self.Part:Destroy()
					self:Collect(collectingPlayer)
					self:Destroy()
					
				end
			end)
		end
	end)
end

function CollectableEgg.new(owner, origin, target, eggTemplate, maxDist, despawnTime)
	
	local template = Instance.new("Part")
	template.Size = Vector3.new(2,2,2)
	template.Shape = "Ball"
	local mesh = Instance.new("SpecialMesh")
	mesh.Parent = template
	mesh.MeshId = "rbxassetid://4827033541"
	mesh.TextureId = "rbxassetid://4827034297"
	
	despawnTime = despawnTime or 300
	local self = setmetatable({
		Part = nil,
		Owner = owner,
		Origin = origin,
		Target = target,
		Template = template,
		MaxDist = maxDist,
		Destroyed = false,
		Tweens = {},
	}, CollectableEgg)
	
	self:SpawnEgg()
	self:Launch()
	delay(despawnTime, function()
		self:Destroy()
	end)
	
	return self
end

return CollectableEgg