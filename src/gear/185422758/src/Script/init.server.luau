--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")

Movement = script:WaitForChild("Movement")
Remover = script:WaitForChild("Remover")

GrimlockModel = InsertService:LoadAsset(184869613)
Grimlock = GrimlockModel:GetChildren()[1]:Clone()
if GrimlockModel and GrimlockModel.Parent then
	GrimlockModel:Destroy()
end

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ClientControl.OnServerInvoke = (function(player, Mode, Value)
end)

function MakeGrimlock()
	if PlayerGrimlock and PlayerGrimlock.Parent then
		PlayerGrimlock:Destroy()
	end
	PlayerGrimlock = Grimlock:Clone()
	GrimlockHumanoid = PlayerGrimlock:FindFirstChild("Humanoid")
	GrimlockTorso = PlayerGrimlock:FindFirstChild("Torso")
	if not GrimlockHumanoid or not GrimlockTorso then
		return
	end
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, 0, math.huge)
	BodyGyro.Parent = GrimlockTorso
	local CreatorValue = Instance.new("ObjectValue")
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = PlayerGrimlock
	ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = PlayerGrimlock
	local MovementClone = Movement:Clone()
	MovementClone.Disabled = false
	MovementClone.Parent = PlayerGrimlock
	local RemoverClone = Remover:Clone()
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerGrimlock
	PlayerGrimlock.Parent = game:GetService("Workspace")
	local TorsoCFrame = Torso.CFrame
	local TorsoPosition = (TorsoCFrame + TorsoCFrame.lookVector * (Torso.Size.Z * -0.25))
	TorsoPosition = (TorsoPosition + (TorsoPosition * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (Torso.Size.X * 1.5))
	TorsoPosition = TorsoPosition - Vector3.new(0, ((PlayerGrimlock:GetModelSize().Y / 2) - (Torso.Size.Y / 2)), 0)
	GrimlockTorso.CFrame = TorsoPosition
	local GrimlockAnimation = PlayerGrimlock:FindFirstChild("Animation")
	if GrimlockAnimation then
		GrimlockAnimation.Disabled = true
		Delay(0.25, function()
			if GrimlockAnimation and GrimlockAnimation.Parent then
				GrimlockAnimation.Disabled = false
			end
		end)
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Handle.Transparency = 0
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Spawn(function()
		Handle.Transparency = 1
		MakeGrimlock()
	end)
end

function Unequipped()
	for i, v in pairs({PlayerGrimlock}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)