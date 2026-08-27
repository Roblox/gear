--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")

Movement = script:WaitForChild("Movement")
Remover = script:WaitForChild("Remover")

Grips = {
	Equip = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Display = CFrame.new(3.5, 1.4, -1, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

GremlinModel = InsertService:LoadAsset(180497645)
Gremlin = GremlinModel:GetChildren()[1]:Clone()
if GremlinModel and GremlinModel.Parent then
	GremlinModel:Destroy()
end

ReloadTime = 10

Tool.Grip = Grips.Equip
Handle.Transparency = 0
Tool.Enabled = true

function DestroyGremlin()
	if GremlinDied then
		GremlinDied:disconnect()
	end
	if PlayerGremlin and PlayerGremlin.Parent then
		PlayerGremlin:Destroy()
	end
	Tool.Enabled = false
	wait(ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function MakeGremlin()
	if PlayerGremlin and PlayerGremlin.Parent then
		PlayerGremlin:Destroy()
	end
	PlayerGremlin = Gremlin:Clone()
	GremlinDied = PlayerGremlin.Changed:connect(function(Property)
		if not PlayerGremlin.Parent then
			DestroyGremlin()
		end
	end)
	GremlinTorso = PlayerGremlin:FindFirstChild("Torso")
	GremlinTorso.CFrame = Torso.CFrame - Torso.CFrame.lookVector * (((GremlinTorso.Size.Z / 2) + (Torso.Size.Z / 2) + 0))
	local MovementClone = Movement:Clone()
	MovementClone.Disabled = false
	MovementClone.Parent = PlayerGremlin
	local RemoverClone = Remover:Clone()
	local CreatorValue = Instance.new("ObjectValue")
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = PlayerGremlin
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = PlayerGremlin
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerGremlin
	PlayerGremlin.Parent = game:GetService("Workspace")
	local TorsoPosition = (Torso.CFrame + Torso.CFrame.lookVector * (((Torso.Size.Z / 2) + (GremlinTorso.Size.Z / 2)) + 0))
	TorsoPosition = (TorsoPosition - (TorsoPosition * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (Torso.Size.X * 1.5))
	TorsoPosition = (TorsoPosition - Vector3.new(0, (Torso.Size.Y / 2), 0))
	GremlinTorso.CFrame = TorsoPosition
end

function Activated()
	if not Tool.Enabled or (PlayerGremlin and PlayerGremlin.Parent) then
		return
	end
	Handle.Transparency = 1
	MakeGremlin()
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
end

function Unequipped()
end

Tool.Changed:connect(function(Property)
	if Property == "Parent" and not Tool.Parent:IsA("Backpack") and not Players:GetPlayerFromCharacter(Tool.Parent) then
		if PlayerGremlin and PlayerGremlin.Parent then
			PlayerGremlin:Destroy()
		end
		Handle.Transparency = 0
		DestroyGremlin()
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)