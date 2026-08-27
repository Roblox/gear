--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

Movement = script:WaitForChild("Movement")
Remover = script:WaitForChild("Remover")

DeployableSnowPlowModel = InsertService:LoadAsset(189802551)
DeployableSnowPlow = DeployableSnowPlowModel:GetChildren()[1]:Clone()
if DeployableSnowPlowModel and DeployableSnowPlowModel.Parent then
	DeployableSnowPlowModel:Destroy()
end

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(Player, Mode, Value)
	if Mode == "MouseClick" and CheckIfAlive() then
		local Down = Value.Down
		local Target = Value.Target
		if TargetValue and TargetValue.Parent then
			if Down and Target and Target.Parent then
				local character = Target.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
				if humanoid and humanoid.Health > 0 and torso then
					local DistanceApart = (Torso.Position - torso.Position).magnitude
					if DistanceApart <= 30 then
						TargetValue.Value = character
					end
				else
					TargetValue.Value = nil
				end
			else
				TargetValue.Value = nil
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function MakeDeployableSnowPlow()
	if PlayerDeployableSnowPlow and PlayerDeployableSnowPlow.Parent then
		PlayerDeployableSnowPlow:Destroy()
	end
	PlayerDeployableSnowPlow = DeployableSnowPlow:Clone()
	DeployableSnowPlowHumanoid = PlayerDeployableSnowPlow:FindFirstChild("Humanoid")
	DeployableSnowPlowTorso = PlayerDeployableSnowPlow:FindFirstChild("Torso")
	if not DeployableSnowPlowHumanoid or not DeployableSnowPlowTorso then
		return
	end
	local humanoid = PlayerDeployableSnowPlow:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Died:connect(function()
			for i, v in pairs(PlayerDeployableSnowPlow:GetChildren()) do
				if v:IsA("BasePart") then
					v.Name = "Part"
					v.CanCollide = false
				end
			end
			Debris:AddItem(PlayerDeployableSnowPlow, 3)
		end)
	end
	local SnowModel = Instance.new("Model")
	SnowModel.Name = "SnowModel"
	SnowModel.Parent = PlayerDeployableSnowPlow
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(math.huge, 0, math.huge)
	BodyGyro.Parent = DeployableSnowPlowTorso
	local CreatorValue = Instance.new("ObjectValue")
	CreatorValue.Name = "Creator"
	CreatorValue.Value = Player
	CreatorValue.Parent = PlayerDeployableSnowPlow
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = Tool
	ToolValue.Parent = PlayerDeployableSnowPlow
	TargetValue = Instance.new("ObjectValue")
	TargetValue.Name = "Target"
	TargetValue.Parent = PlayerDeployableSnowPlow
	local MovementClone = Movement:Clone()
	MovementClone.Disabled = false
	MovementClone.Parent = PlayerDeployableSnowPlow
	local RemoverClone = Remover:Clone()
	RemoverClone.Disabled = false
	RemoverClone.Parent = PlayerDeployableSnowPlow
	PlayerDeployableSnowPlow.Parent = game:GetService("Workspace")
	local TorsoCFrame = Torso.CFrame
	local TorsoPosition = (TorsoCFrame + TorsoCFrame.lookVector * (Torso.Size.Z * -0.25))
	TorsoPosition = (TorsoPosition + (TorsoPosition * CFrame.Angles(0, (math.pi / 2), 0)).lookVector * (Torso.Size.X * 1.5))
	TorsoPosition = TorsoPosition - Vector3.new(0, ((PlayerDeployableSnowPlow:GetModelSize().Y / 2) - (Torso.Size.Y / 2)), 0)
	DeployableSnowPlowTorso.CFrame = TorsoPosition
	local DeployableSnowPlowAnimation = PlayerDeployableSnowPlow:FindFirstChild("Animation")
	if DeployableSnowPlowAnimation then
		DeployableSnowPlowAnimation.Disabled = true
		Delay(0.25, function()
			if DeployableSnowPlowAnimation and DeployableSnowPlowAnimation.Parent then
				DeployableSnowPlowAnimation.Disabled = false
			end
		end)
	end
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Handle.Transparency = 0
	if not CheckIfAlive() then
		return
	end
	Spawn(function()
		Handle.Transparency = 1
		MakeDeployableSnowPlow()
	end)
end

function Unequipped()
	for i, v in pairs({PlayerDeployableSnowPlow}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Handle.Transparency = 0
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)