--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")

Camera = game:GetService("Workspace").CurrentCamera

Animations = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ToolEquipped = false

function SetAnimation(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
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
	end
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
	PlayerMouse = Player:GetMouse()
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true})
	end)
	Mouse.Button1Up:connect(function()
		InvokeServer("MouseClick", {Down = false})
	end)
end

function Unequipped()
	ToolEquipped = false
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	Animations = {}
end

function InvokeServer(Mode, Value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(Mode, Value)
		return ServerReturn
	end)
end

function OnClientInvoke(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", Value)
	elseif Mode == "StopAnimation" and Value then
		SetAnimation("StopAnimation", Value)
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
	elseif Mode == "MousePosition" then
		return PlayerMouse.Hit.p
	elseif Mode == "GetCamera" and Value then
		local PropertyValue = nil
		pcall(function()
			PropertyValue = Camera[Value.Property]
		end)
		return PropertyValue
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
ClientControl.OnClientInvoke = OnClientInvoke