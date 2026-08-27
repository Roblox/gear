--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ResizeScript = script:WaitForChild("ResizeScript")

ShrinkFactor = 0.5
Duration = 30

Animations = {
	DrinkR6 = {Animation = Tool:WaitForChild("DrinkR6"), FadeTime = nil, Weight = nil, Speed = nil},
	DrinkR15 = {Animation = Tool:WaitForChild("DrinkR15"), FadeTime = nil, Weight = nil, Speed = nil}
}

Sounds = {
	Drink = Handle:WaitForChild("DrinkSound")
}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function Transform()
	local ResizeScriptClone = Character:FindFirstChild(ResizeScript.Name)
	if ResizeScriptClone or not CheckIfAlive() then
		return
	end
	InvokeClient("PlayAnimation", Animations["Drink"..Humanoid.RigType.Name])
	wait(0.35)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	Sounds.Drink:Play()
	wait(1)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	ResizeScriptClone = ResizeScript:Clone()
	local DurationValue = Instance.new("NumberValue")
	DurationValue.Name = "Duration"
	DurationValue.Value = Duration
	DurationValue.Parent = ResizeScriptClone
	ResizeScriptClone.Disabled = false
	ResizeScriptClone.Parent = Character
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	Transform()
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
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
Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)