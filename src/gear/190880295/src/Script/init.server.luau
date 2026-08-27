--Made by Luckymaxer
--Updated for R15 avatars by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ExplosionScript = script:WaitForChild("ExplosionScript")

Animations = {
	Light = {Animation = Tool:WaitForChild("Light"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15Light = {Animation = Tool:WaitForChild("R15Light"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

Sounds = {
	Explode = Handle:WaitForChild("Explode"),
	Fly = Handle:WaitForChild("Fly")
}

ToolEquipped = false

FlightDuration = 3
ReloadTime = 20

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local ByteKey = string.byte(Key)
			local Down = Value.Down
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

function FireFirework()
	Handle.Transparency = 1
	local Firework = Handle:Clone()
	Firework.Transparency = 0
	Firework.CFrame = Handle.CFrame
	Firework.Name = "Firework"
	Firework.Locked = true
	Firework.CanCollide = true
	Debris:AddItem(Firework, 10)
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.velocity = Vector3.new(0, 1, 0) * (Firework:GetMass() * 50)
	BodyVelocity.Parent = Firework
	Firework.Parent = game:GetService("Workspace")
	return Firework
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	local CurrentlyEquipped = true
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Tool.Enabled = false
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		InvokeClient("PlayAnimation", Animations.R15Light)
	else
		InvokeClient("PlayAnimation", Animations.Light)
	end
	wait(2)
	if CurrentlyEquipped then
		local Firework = FireFirework()
		local ExplosionScriptClone = ExplosionScript:Clone()
		ExplosionScriptClone.Disabled = false
		local Duration = Instance.new("NumberValue")
		Duration.Name = "Duration"
		Duration.Value = FlightDuration
		Duration.Parent = ExplosionScriptClone
		ExplosionScriptClone.Parent = Firework
		wait(ReloadTime)
		if CurrentlyEquipped then
			Handle.Transparency = 0
		end
	end
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	ToolEquipped = true
end

function Unequipped()
	Handle.Transparency = 0
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)