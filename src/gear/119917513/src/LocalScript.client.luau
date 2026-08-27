--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
StarterGui = game:GetService("StarterGui")
ContentProvider = game:GetService("ContentProvider")

Camera = game:GetService("Workspace").CurrentCamera

Animations = {}
InteractiveConnections = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlayAnimation" and Humanoid then
		for i, v in pairs(Animations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(Value.Animation)
		table.insert(Animations, {Animation = Value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(Value.FadeTime, Value.Weight, Value.Speed)
	elseif Mode == "StopAnimation" and Value then
		for i, v in pairs(Animations) do
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
	elseif Mode == "Preload" and Value then
		ContentProvider:Preload(Value)
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
	elseif Mode == "MousePosition" then
		return PlayerMouse.Hit.p
	elseif Mode == "DisableJump" then
		DisableJump(Value)
	elseif Mode == "RequestCamera" and Value then
		local PropertyValue = nil
		pcall(function()
			PropertyValue = Camera[Value]
		end)
		return PropertyValue
	elseif Mode == "SetCamera" and Value then
		local Success = false
		pcall(function()
			Camera[Value.Property] = Value.Value
			Success = true
		end)
		return Success
	elseif Mode == "SetCoreGuiEnabled" and Value then
		StarterGui:SetCoreGuiEnabled(Value.Enum, Value.Boolean)
	end
end)

function InvokeServer(Mode, Value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(Mode, Value)
	end)
	return ServerReturn
end

function DisableJump(Boolean)
	if PreventJump then
		PreventJump:disconnect()
	end
	if Boolean then
		PreventJump = Humanoid.Changed:connect(function(Property)
			if Property ==  "Jump" then
				Humanoid.Jump = false
			end
		end)
	end
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(InteractiveConnections) do
		if v then
			v:disconnect()
		end
	end
	InteractiveConnections = {}
	PlayerMouse = Player:GetMouse()
	local Button1Down = Mouse.Button1Down:connect(function()
		InvokeServer("Button1Click", {Down = true})
	end)
	local Button1Up = Mouse.Button1Up:connect(function()
		InvokeServer("Button1Click", {Down = false})
	end)
	local Button2Down = Mouse.Button2Down:connect(function()
		InvokeServer("Button2Click", {Down = true})
	end)
	local Button2Up = Mouse.Button2Up:connect(function()
		InvokeServer("Button2Click", {Down = false})
	end)
	local KeyDown = Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	local KeyUp = Mouse.KeyUp:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
	for i, v in pairs({Button1Down, Button1Up, Button2Down, Button2Up, KeyDown, KeyUp}) do
		table.insert(InteractiveConnections, v)
	end
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	if PreventJump then
		PreventJump:disconnect()
	end
	Animations = {}
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)