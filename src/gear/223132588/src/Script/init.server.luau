--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Logo = script:WaitForChild("Logo")
SpeedBoost = script:WaitForChild("SpeedBoost")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Material = Enum.Material.Plastic
BasePart.Shape = Enum.PartType.Block
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

Track = BasePart:Clone()
Track.Name = "HotWheelsTrack"
Track.Size = Vector3.new(3, 2, 3)
TrackMesh = Instance.new("SpecialMesh")
TrackMesh.MeshType = Enum.MeshType.FileMesh
TrackMesh.MeshId = (BaseUrl .. "220585435")
TrackMesh.TextureId = (BaseUrl .. "220585387")
TrackMesh.Scale = Vector3.new(1, 1, 1)
TrackMesh.Parent = Track

Grips = {
	Equipped = CFrame.new(0, -1.05, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Unequipped = CFrame.new(4, 2.85, -1, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

Duration = 30
ReloadTime = 3

ToolEquipped = false

Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled and ToolEquipped then
		return
	end
	local TrackName = (Player.Name .. Track.Name)
	local PlayerTrack = game:GetService("Workspace"):FindFirstChild(TrackName)
	if PlayerTrack then
		return
	end
	Tool.Enabled = false
	Handle.Transparency = 1
	local TrackClone = Track:Clone()
	local SpeedBoostScript = SpeedBoost:Clone()
	SpeedBoostScript.Disabled = false
	SpeedBoostScript.Parent = TrackClone
	local LogoClone = Logo:Clone()
	LogoClone.Parent = TrackClone
	LogoClone.Adornee = TrackClone
	TrackClone.Name = TrackName
	TrackClone.CFrame = Handle.CFrame * CFrame.new(0, -((Handle.Size.Y / 2) + (Track.Size.Y / 2)), -((Handle.Size.Z / 2) + (Track.Size.Z / 2)))
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
	BodyGyro.cframe = TrackClone.CFrame
	BodyGyro.Parent = TrackClone
	Debris:AddItem(TrackClone, Duration)
	TrackClone.Parent = game:GetService("Workspace")
	wait(Duration + ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	ToolEquipped = true
end

function Unequipped()
	Tool.Grip = Grips.Unequipped
	Handle.Transparency = 0
	ToolEquipped = false
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)