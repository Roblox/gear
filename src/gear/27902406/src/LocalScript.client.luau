--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

RemoteControl = Tool:WaitForChild("RemoteControl")

ServerControl = RemoteControl:WaitForChild("ServerControl")
ClientControl = RemoteControl:WaitForChild("ClientControl")

ToolEquipped = false
MouseControls = {}

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "MousePosition" then
		return PlayerMouse.Hit.p
	end
end)

function InvokeServer(Mode, Value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(Mode, Value)
	end)
	return ServerReturn
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Mouse
	for i, v in pairs(MouseControls) do
		if v then
			v:disconnect()
		end
	end
	MouseControls = {}
	MouseDown = PlayerMouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true})
	end)
	MouseUp = PlayerMouse.Button1Up:connect(function()
		InvokeServer("MouseClick", {Down = false})
	end)
end

function Unequipped()
	ToolEquipped = false
	for i, v in pairs(MouseControls) do
		if v then
			v:disconnect()
		end
	end
	MouseControls = {}
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)