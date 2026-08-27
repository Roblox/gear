--Rescripted by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

ReloadTime = 25

Sounds = {
	Reload = Handle:WaitForChild("Reload"),
	NoobFail = Handle:WaitForChild("NoobFail"),
	NoobShoot = Handle:WaitForChild("NoobShoot")
}

Animate = script:WaitForChild("Animate")
MessageScript = script:WaitForChild("MessageScript")

AssetId = 27410797
FigureModel = InsertService:LoadAsset(AssetId)
Figure = FigureModel:GetChildren()[1]:Clone()
if FigureModel and FigureModel.Parent then
	FigureModel:Destroy()
end
for i, v in pairs({Animate, MessageScript}) do
	local ScriptClone = v:Clone()
	ScriptClone.Disabled = false
	ScriptClone.Parent = Figure
end

AmountInFront = 15

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function Fire(character)
	if not CheckIfAlive() then
		return
	end
	local FigureClone = Figure:Clone()
	local spawnPoint = Torso.Position
	local torsoNormal = Torso.CFrame.lookVector
	local denom = math.abs(torsoNormal.x) + math.abs(torsoNormal.z)
	local posX = AmountInFront * (torsoNormal.x/denom)
	local posZ = AmountInFront * (torsoNormal.z/denom)
	local pos = Vector3.new(spawnPoint.x + posX, spawnPoint.y, spawnPoint.z + posZ)
	
	Debris:AddItem(FigureClone, 30)
	FigureClone.PersonToPester.Value = character
	FigureClone.Parent = game:GetService("Workspace")
	FigureClone:MakeJoints()
	FigureClone.Torso.CFrame = CFrame.new(pos, Torso.Position) * CFrame.Angles(0, math.pi, 0)
end

function Activated(Target)
	if not Tool.Enabled or not CheckIfAlive()then
		return
	end
	Tool.Enabled = false
	wait(0.3)
	Sounds.NoobShoot:Play()
	wait(1.5)
	Tool.GripPos = Vector3.new(0, -0.5, -0.5)
	Fire(Target)
	wait(0.1)
	Tool.GripPos = Vector3.new(0, -0.7, -0.7)
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Player = Players:GetPlayerFromCharacter(Character)
end

function Unequipped()
	for i, v in pairs(Sounds) do
		v:Stop()
	end
end

function OnServerInvoke(player, mode, value)
	if player == Player and value and CheckIfAlive() then
		if mode == "MouseClick" then
			local Down = value.Down
			local Target = value.Target
			Activated(Target.Parent)
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)