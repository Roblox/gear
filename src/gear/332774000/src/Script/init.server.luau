--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

SpeedScript = script:WaitForChild("SpeedScript")

Grips = {
	Hold = CFrame.new(0, -0.55, 0.3, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Drink = CFrame.new(0, -0.55, 0.3, 0.916752279, 0.295810401, 0.268442839, -0.399456352, 0.678884864, 0.616076291, 0, -0.672020495, 0.740532577),
}

Animations = {
	Drink = {Animation = Tool:WaitForChild("Drink"), FadeTime = nil, Weight = nil, Speed = 0.75, Duration = (1 / 0.75)},
}

Sounds = {
	Drink = Handle:WaitForChild("Drink"),
}

Duration = 15
ReloadTime = 18

ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Grip = Grips.Hold
Tool.Enabled = true

function Activated()
	if not Tool.Enabled or not ToolEquipped or not CheckIfAlive() then
		return
	end
	local SpeedScriptCopy = Character:FindFirstChild(SpeedScript.Name)
	if SpeedScriptCopy then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local Animation = Animations.Drink
	Spawn(function()
		InvokeClient("PlayAnimation", Animation)
	end)
	Tool.Grip = Grips.Drink
	wait(Animation.Duration / 2)
	if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
		Sounds.Drink:Play()
		SpeedScriptCopy = SpeedScript:Clone()
		local Values = {
			{Name = "Duration", Value = Duration, Class = "NumberValue"},
			{Name = "Speed", Value = (16 * 2.5), Class = "NumberValue"},
		}
		for i, v in pairs(Values) do
			local Value = Instance.new(v.Class)
			Value.Name = v.Name
			Value.Value = v.Value
			Value.Parent = SpeedScriptCopy
		end
		SpeedScriptCopy.Disabled = false
		SpeedScriptCopy.Parent = Character
		wait(Animation.Duration / 2)
	end
	Tool.Grip = Grips.Hold
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function OnServerInvoke(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)