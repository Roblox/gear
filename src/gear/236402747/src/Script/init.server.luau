--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

EffectScript = script:WaitForChild("EffectScript")

BaseUrl = "http://www.roblox.com/asset/?id="

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

Animations = {}

Sounds = {
	Music = Handle:WaitForChild("Music"),
}

Grips = {
	Display = CFrame.new(1.5, 1.5, 2.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0, -0.5, 0.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Gravity = 196.20
Rate = (1 / 60)

Duration = (60 * 2)
ReloadTime = 60

ToolEquipped = false

DisplayPart = Tool:FindFirstChild("DisplayModel")
if DisplayPart then
	DisplayPart:Destroy()
end

Mesh.Scale = Vector3.new(0.25, 0.25, 0.25)
Tool.Grip = Grips.Equipped
Handle.Transparency = 0
Tool.Enabled = true

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	local IgnoreList = ((type(IgnoreList) == "table" and IgnoreList) or {IgnoreList})
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	local SpawnPosition = (Torso.CFrame * CFrame.new(0, 0, -(Torso.Size.Z * 4))).p
	local RayHit, SpawnPosition, RayNormal = RayCast(SpawnPosition, Vector3.new(0, -1, 0), (Torso.Size.Y * 2.5), {Character})
	if not RayHit then
		return
	end
	Tool.Enabled = false
	Handle.Transparency = 1
	local PianoModel = Instance.new("Model")
	PianoModel.Name = "PianoModel"
	local EffectScriptClone = EffectScript:Clone()
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = Player
	Creator.Parent = PianoModel
	local PlayBack = Instance.new("IntValue")
	PlayBack.Name = "PlayBack"
	PlayBack.Value = 2
	PlayBack.Parent = PianoModel
	local SpawnDuration = Instance.new("NumberValue")
	SpawnDuration.Name = "Duration"
	SpawnDuration.Value = Duration
	SpawnDuration.Parent = PianoModel
	local Position = Instance.new("CFrameValue")
	Position.Name = "Position"
	Position.Value = (CFrame.new(SpawnPosition, Vector3.new(Torso.Position.X, SpawnPosition.Y, Torso.Position.Z)) * CFrame.Angles(0, math.pi, 0))
	Position.Parent = PianoModel
	local Count = Instance.new("IntValue")
	Count.Name = "Count"
	Count.Value = 50
	Count.Parent = PianoModel
	local Sound = Sounds.Music:Clone()
	Sound.Name = "Music"
	Sound.Parent = EffectScriptClone
	EffectScriptClone.Disabled = false
	EffectScriptClone.Parent = PianoModel
	Debris:AddItem(PianoModel, Duration)
	PianoModel.Parent = game:GetService("Workspace")
	wait(ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		Handle.Transparency = ((Players:GetPlayerFromCharacter(Tool.Parent) and ((Tool.Enabled and 0) or 1)) or 0)
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)