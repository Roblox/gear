--Made by Luckymaxer
--[[
	Fixed by ArceusInator
	- Works with FE
--]]

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Sound = Handle:WaitForChild("Sound")

Debris = game:GetService("Debris")

Equipped = false
Debounce = false

ReloadTime = 0.5

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)

function Activated()
	if not Debounce and Tool.Enabled then
		Tool.Enabled = false
		Sound:Play()
		local SparkleTable = {}
		local LightTable = {}
		for i = 1, math.random(5, 10) do
			local Sparkle = BasePart:Clone()
			Sparkle.Transparency = 1
			Sparkle.CanCollide = false
			local Light = Instance.new("PointLight")
			Light.Brightness = 1
			Light.Range = 15
			Light.Shadows = false
			Light.Enabled = true
			table.insert(LightTable, Light)
			Light.Parent = Sparkle
			local Sparkles = Instance.new("Sparkles")
			table.insert(SparkleTable, Sparkles)
			Sparkles.Parent = Sparkle
			local VelocityForce = (workspace.Gravity * Sparkle:GetMass())
			local BodyForce = Instance.new("BodyForce")
			BodyForce.force = Vector3.new(0, VelocityForce, 0)
			Debris:AddItem(BodyForce, 3)
			BodyForce.Parent = Sparkle
			Debris:AddItem(Sparkle, 5)
			Sparkle.Parent = game:GetService("Workspace")
			Sparkle.CFrame = CFrame.new(Handle.Position)
			Sparkle.CFrame = Sparkle.CFrame * CFrame.Angles(math.random(-math.pi, math.pi), math.random(-math.pi, math.pi), math.random(-math.pi, math.pi))
			local StartingPosition = (Sparkle.CFrame + Sparkle.CFrame.lookVector * Sparkle.Size.Z)
			local TargetPoint = (StartingPosition + StartingPosition.lookVector * 2)
			Sparkle.CFrame = StartingPosition
			Sparkle.CFrame = CFrame.new(Sparkle.Position, TargetPoint.p)
			Sparkle.Velocity = CFrame.new(StartingPosition.p, TargetPoint.p).lookVector * 5
			Sparkle.Velocity = Vector3.new(Sparkle.Velocity.x, 5, Sparkle.Velocity.z)
		end
		Spawn(function()
			local ChangeTick = tick()
			while (tick() - ChangeTick) <= 5 do
				local RandomColor = Color3.new(math.random(), math.random(), math.random())
				for i, v in pairs(SparkleTable) do
					if v and v.Parent then
						v.SparkleColor = RandomColor
					end
				end
				for i, v in pairs(LightTable) do
					if v and v.Parent then
						v.Color = RandomColor
					end
				end
				wait(1)
			end
		end)
		Debounce = true
		Debounce = false
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Equipped()
	Equipped = true
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Equipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)