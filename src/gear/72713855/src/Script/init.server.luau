--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ResizeScript = script:WaitForChild("ResizeScript")

ShrinkFactor = 2
Duration = 30

local Pcall,Wait,Pairs,Instant = pcall,wait,pairs,Instance.new

Animations = {
	Drink = {Animation = Tool:WaitForChild("DrinkR6"), FadeTime = nil, Weight = nil, Speed = nil},
	DrinkR15 = {Animation = Tool:WaitForChild("DrinkR15"), FadeTime = nil, Weight = nil, Speed = nil},
	RageR6 = {Animation = Tool:WaitForChild("RageR6"),FadeTime = nil, Weight = nil, Speed = nil},
	RageR15 = {Animation = Tool:WaitForChild("RageR15"),FadeTime = nil, Weight = nil, Speed = nil},
}

Sounds = {
	Drink = Handle:WaitForChild("DrinkSound"),
	Rage = Handle:WaitForChild("RageSound")
}

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instant("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instant("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

function Transform()
	local ResizeScriptClone = Character:FindFirstChild(ResizeScript.Name)
	if ResizeScriptClone or not CheckIfAlive() then
		return
	end
	InvokeClient("PlayAnimation", Animations["Drink"..Humanoid.RigType.Name])
	Wait(0.35)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	Sounds.Drink:Play()
	Wait(1.25)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	InvokeClient("PlayAnimation", Animations["Rage"..Humanoid.RigType.Name])
	Wait(0.6)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	InvokeClient("PlaySound", Sounds.Rage)
	Wait(0.5)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	InvokeClient("PlayAnimation", Animations["Rage"..Humanoid.RigType.Name])
	ResizeScriptClone = ResizeScript:Clone()
	local DurationValue = Instant("NumberValue")
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
	for i, v in Pairs(Sounds) do
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
	Pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Activated:Connect(Activated)
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)