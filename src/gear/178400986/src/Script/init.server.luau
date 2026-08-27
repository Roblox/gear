--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
InsertService = game:GetService("InsertService")

Remover = script:WaitForChild("Remover")

FakeHandle = Tool:FindFirstChild("FakeHandle")
if FakeHandle then
	FakeHandle:Destroy()
	Handle.Transparency = 0
end

ChopperModel = InsertService:LoadAsset(178339458)
Chopper = ChopperModel:GetChildren()[1]:Clone()
if ChopperModel and ChopperModel.Parent then
	ChopperModel:Destroy()
end

MaxDistance = 10

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

Handle.Transparency = 0
Tool.Enabled = true

ClientControl.OnServerInvoke = (function(player, Mode, Value)
	if Mode == "Click" and Player == player then
		if Value and (not PlayerChopper or not PlayerChopper.Parent) then
			Handle.Transparency = 1
			MakeChopper()
		end
	end
end)

function MakeChopper()
	if PlayerChopper and PlayerChopper.Parent then
		PlayerChopper:Destroy()
	end
	PlayerChopper = Chopper:Clone()
	ChopperTorso = PlayerChopper:FindFirstChild("Torso")
	PlayerChopper:FindFirstChild("Creator").Value = Player
	local RemoverClone = Remover:Clone()
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerChopper
	PlayerChopper.Parent = game:GetService("Workspace")
	ChopperTorso.CFrame = Torso.CFrame - Torso.CFrame.lookVector * ((ChopperTorso.Size.Z / 2) + (Torso.Size.Z / 2) + 5)
	ChopperTorso.CFrame = ChopperTorso.CFrame - Vector3.new(0, (Torso.Size.Y / 2), 0)
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
end

function Unequipped()
	for i, v in pairs({PlayerChopper}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)