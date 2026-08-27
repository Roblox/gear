--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Anchored = false
BasePart.CanCollide = false
BasePart.Locked = true

Colors = {"Black", "CGA brown", "White", "Dark red", "Alder"}

Equipped = false

ReloadTime = 0.125

Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not Equipped or not Humanoid.Parent or Humanoid.Health == 0 then
		return
	end
	
	Spawn(function()
	
		Tool.Enabled = false	
		
		local Part = BasePart:Clone()
		Part.Transparency = 1
		Part.Size = Vector3.new(0.2, 0.2, 0.2)
		
		local SparkleColor = BrickColor.new(Colors[math.random(1, #Colors)]).Color	
		
		for i = 1, 3 do
			local Sparkles = Instance.new("Sparkles")
			Sparkles.SparkleColor = SparkleColor
			Sparkles.Enabled = true
			Sparkles.Parent = Part
		end
		
		local PointLight = Instance.new("PointLight")
		PointLight.Brightness = 25
		PointLight.Color = SparkleColor
		PointLight.Range = 6
		PointLight.Enabled = true
		PointLight.Parent = Part
		
	
		local BodyPosition = Instance.new("BodyPosition")
		BodyPosition.maxForce = Vector3.new(0, 0, 0)
		BodyPosition.Parent = Part
		
		Debris:AddItem(Part, 10)
		
		Part.CFrame = Handle.CFrame
		Part.Parent = game:GetService("Workspace")
		
		local Radius = 5
		local Offset = 0
		
		local Origin = Handle.Position
		
		for i = 1, math.random(20, 35) do
			Radius = (Radius + 0.25)
			local Angle = ((i * math.pi) / 5)
			BodyPosition.position = (CFrame.new(Origin) + Vector3.new(((math.cos(Angle) * Radius) + Offset), (i / 2), ((math.sin(Angle) * Radius) + Offset))).p
			BodyPosition.maxForce = Vector3.new(math.huge, math.huge, math.huge)
			wait(0.1)
		end
		
		Delay(0.25, function()
			if BodyPosition and BodyPosition.Parent then
				BodyPosition:Destroy()
			end
		end)
	
	end)
	
	wait(ReloadTime)
	
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Character or not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Equipped = true
end

function Unequipped()
	Equipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)