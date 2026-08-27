--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Debris = game:GetService("Debris")

CurrentColor = Tool:WaitForChild("CurrentColor")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Anchored = false
BasePart.CanCollide = true
BasePart.Locked = true

BaseTrailPart = BasePart:Clone()
BaseTrailPart.Name = "LaserTrail"
BaseTrailPart.Transparency = 0.2
BaseTrailPart.Size = Vector3.new(0.5, 5, 3)
BaseTrailPart.Material = Enum.Material.SmoothPlastic
BaseTrailPart.TopSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.RightSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.BackSurface = Enum.SurfaceType.SmoothNoOutlines
BaseTrailPart.Anchored = true
BaseTrailPart.CanCollide = false
TrailLight = Instance.new("PointLight")
TrailLight.Name = "Light"
TrailLight.Brightness = 10
TrailLight.Range = 8
TrailLight.Shadows = false
TrailLight.Enabled = true
TrailLight.Parent = BaseTrailPart

Rate = (1 / 60)

function StartTrail(Source, Parent)
	
	local TrailParts = {}
	
	local SourceAlive = true

	local NumberOfParts = 60
	local LastPoint = (Source.CFrame * CFrame.new(0, 0, 4)).p
	
	Source.Changed:connect(function(Property)
		if Property == "Parent" and not Source.Parent then
			SourceAlive = false
		end
	end)
	
	while SourceAlive do
		local CurrentPoint = (Source.CFrame * CFrame.new(-1.125, 0, 4)).p
		if Source.Velocity.magnitude > 20 then
			local TrailPart = BaseTrailPart:Clone()
			TrailPart.BrickColor = BrickColor.new(CurrentColor.Value)
			TrailPart.Light.Color = CurrentColor.Value
			TrailPart.Size = Vector3.new(TrailPart.Size.X, TrailPart.Size.Y, (CurrentPoint - LastPoint).magnitude)
			table.insert(TrailParts, TrailPart)
			TrailPart.Parent = Parent
			TrailPart.CFrame = CFrame.new(((CurrentPoint + LastPoint) * 0.5), LastPoint)
			if #TrailParts > NumberOfParts then
				local TrailPart = TrailParts[1]
				if TrailPart and TrailPart.Parent then
					TrailPart:Destroy()
				end
				table.remove(TrailParts, 1)
			end
		else
			local TrailPart = TrailParts[1]
			if TrailPart and TrailPart.Parent then
				TrailPart:Destroy()
			end
			table.remove(TrailParts, 1)
		end
		LastPoint = CurrentPoint
		wait(Rate)
	end
	
	for i, v in pairs(TrailParts) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	
end

Tool.ChildAdded:connect(function(Child)
	if Child.Name == "Body" then
		Spawn(function()
			StartTrail(Child, Tool)
		end)
	end
end)