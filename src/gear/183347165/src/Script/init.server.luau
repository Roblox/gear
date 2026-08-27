--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

FireworksModule = require(182191976)
Credit = FireworksModule.Credit

FireworkLauncher = script:WaitForChild("FireworkLauncher")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false
BaseMesh = Instance.new("SpecialMesh")
BaseMesh.MeshType = Enum.MeshType.FileMesh
BaseMesh.Scale = Vector3.new(1, 1, 1)
BaseMesh.Parent = BasePart

Gravity = 196.20

BaseUrl = "http://www.roblox.com/asset?id="
TextureId = 179511447

Scale = Vector3.new(0.5, 0.5, 0.5)

Parts = {
	{Name = "Pumpkin", Size = Vector3.new(2, 1, 2), MeshId = 180406439, Offset = Vector3.new(0.0100212097, -3.49999428, 0.250000954)},
	{Name = "Firework1", Size = Vector3.new(0.75, 2, 1), MeshId = 180406459, Offset = Vector3.new(-1.82001495, 0.290010452, 0.0824995041)},
	{Name = "Firework2", Size = Vector3.new(0.75, 0.75, 0.75), MeshId = 180406466, Offset = Vector3.new(-2.12002182, -1.22999001, 2.05747032)},
	{Name = "Firework3", Size = Vector3.new(0.5, 0.9, 0.5), MeshId = 180406480, Offset = Vector3.new(-0.899990082, -0.679998398, 2.8650074)},
	{Name = "Firework4", Size = Vector3.new(0.75, 1.25, 0.75), MeshId = 180406491, Offset = Vector3.new(-0.907478333, -0.375003815, 1.75499344)},
	{Name = "Firework5", Size = Vector3.new(0.75, 1.25, 0.75), MeshId = 180406506, Offset = Vector3.new(-1.5149765, -1.08001328, -1.51750851)},
	{Name = "Firework6", Size = Vector3.new(0.75, 1.05, 0.5), MeshId = 180406522, Offset = Vector3.new(-0.328235626, -0.602506638, -2.04000187)},
	{Name = "Firework7", Size = Vector3.new(0.75, 1.05, 0.5), MeshId = 180406538, Offset = Vector3.new(0.0824928284, -0.237514496, -0.569996834)},
	{Name = "Firework8", Size = Vector3.new(1, 1.7, 1), MeshId = 180406552, Offset = Vector3.new(1.02749634, -0.360002518, -2.27999592)},
	{Name = "Firework9", Size = Vector3.new(0.4, 0.9, 0.75), MeshId = 180406564, Offset = Vector3.new(1.30225372, -1.24999809, -0.279998779)},
	{Name = "Firework10", Size = Vector3.new(0.4, 1, 0.75), MeshId = 180406575, Offset = Vector3.new(1.94226837, -0.979995728, 0.930001259)},
	{Name = "Firework11", Size = Vector3.new(1.125, 2.6, 0.75), MeshId = 180406588, Offset = Vector3.new(0.912254333, 0.309988022, 0.659999847)},
	{Name = "Firework12", Size = Vector3.new(0.25, 0.75, 0.25), MeshId = 180406600, Offset = Vector3.new(0.192249298, -1.48001862, 2.12999725)},
	{Name = "Firework13", Size = Vector3.new(1, 1.5, 0.75), MeshId = 180406614, Offset = Vector3.new(1.51227188, -0.900022507, 2.29000664)},
	{Name = "Firework14", Size = Vector3.new(0.75, 1.05, 0.5), MeshId = 181451348, Offset = Vector3.new(1.79777908, -2.15000916, -0.82000351)},
}

ReloadTime = 25
Duration = 20

Tool.Enabled = true

function CheckForCredit(Player)
	if not Player or not Player.Parent then
		return
	end
	for i, v in pairs(Credit) do
		if ((v.UserId and tonumber(v.UserId) == tonumber(Player.userId)) or (v.UserName and tostring(v.UserName) == tostring(Player.Name))) then
			return true
		end
	end
	return false
end

function WeldTo(PrimaryPart, SecondaryPart)
	if not PrimaryPart or not SecondaryPart then
		return
	end
	local Weld = Instance.new("Weld")
	Weld.Name = "Weld"
	Weld.Part0 = PrimaryPart
	Weld.Part1 = SecondaryPart
	Weld.C0 = PrimaryPart.CFrame:inverse()
	Weld.C1 = SecondaryPart.CFrame:inverse()
	Weld.Parent = PrimaryPart
	return Weld
end

function Activated()
	if not Tool.Enabled or not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 then
		return
	end
	Tool.Enabled = false
	Handle.Transparency = 1
	local HandleClone = Handle:Clone()
	HandleClone.Name = "Center"
	HandleClone.Transparency = 1
	HandleClone.CanCollide = true
	HandleClone.CFrame = CFrame.new(HandleClone.Position) * CFrame.Angles(0, -(math.pi / 2), 0)
	local FireworksModel = Instance.new("Model")
	FireworksModel.Name = "HalloweenFireworks"
	for i, v in pairs(Parts) do
		local Part = BasePart:Clone()
		local Mesh = Part.Mesh
		Part.Name = v.Name
		Part.Size = v.Size
		Mesh.MeshId = tostring(BaseUrl .. v.MeshId)
		Mesh.TextureId = tostring(BaseUrl .. TextureId)
		Mesh.Scale = Scale
		Part.Parent = FireworksModel
		Part.CFrame = HandleClone.CFrame + (v.Offset / 4)
		WeldTo(HandleClone, Part)
	end
	local Pumpkin = FireworksModel:FindFirstChild("Pumpkin")
	if Pumpkin then
		Pumpkin.Friction = 2
		local Mass = ((HandleClone:GetMass() * Gravity) / 4)
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(Mass, Mass, Mass)
		BodyGyro.D = 25
		BodyGyro.P = 0
		BodyGyro.cframe = Pumpkin.CFrame
		BodyGyro.Parent = Pumpkin
		local Light = Instance.new("PointLight")
		Light.Color = BrickColor.new("New Yeller").Color
		Light.Brightness = 50
		Light.Range = 8
		Light.Shadows = false
		Light.Enabled = true
		Light.Parent = Pumpkin
		HandleClone.Parent = FireworksModel
		Debris:AddItem(FireworksModel, Duration)
		local FireworkLauncherClone = FireworkLauncher:Clone()
		FireworkLauncherClone.Disabled = false
		FireworkLauncherClone.Parent = FireworksModel
		FireworksModel.Parent = game:GetService("Workspace")
		HandleClone.CFrame = Handle.CFrame
		wait(((CheckForCredit(Player) and 2) or ReloadTime))
	end
	Handle.Transparency = 0
	Tool.Enabled = true
end

function Equipped(Mouse)
	Handle.Transparency = ((Tool.Enabled and 0) or 1)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
end

function Unequipped()
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" and Tool.Parent and not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent) then
		Handle.Transparency = 0
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)