--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
ContentProvider = game:GetService("ContentProvider")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ToolEquipped = false

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "Preload" and Value then
		ContentProvider:Preload(Value)
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
	elseif Mode == "MousePosition" then
		return PlayerMouse.Hit.p
	elseif Mode == "SetMouseIcon" and Value then
		if PlayerMouse then
			PlayerMouse.Icon = Value
		end
	elseif Mode == "GetCamera" and Value then
		local Camera = game:GetService("Workspace").CurrentCamera
		local PropertyValue = nil
		if Value.Property then
			pcall(function()
				PropertyValue = Camera[Value.Property]
			end)
		end
		return PropertyValue
	elseif Mode == "SetCamera" and Value then
		local Camera = game:GetService("Workspace").CurrentCamera
		for i, v in pairs(Value) do
			pcall(function()
				Camera[v.Property] = v.Value
			end)
		end
	end
end)

function InvokeServer(Mode, Value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(Mode, Value)
		return ServerReturn
	end)
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
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
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true})
	end)
	Mouse.Move:connect(function()
		InvokeServer("MouseMove", {Target = Mouse.Target, Position = Mouse.Hit.p})
	end)
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
end

function Unequipped()
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)