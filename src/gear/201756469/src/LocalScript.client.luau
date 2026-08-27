--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
UserInputService = game:GetService("UserInputService")

Folders = Tool:WaitForChild("Folders")
RemotesFolder = Folders:WaitForChild("Remotes")
ServerControl = RemotesFolder:WaitForChild("ServerControl")
ClientControl = RemotesFolder:WaitForChild("ClientControl")

Animations = {}

ToolEquipped = false

function SetAnimation(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(Animations, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
	elseif mode == "StopAnimation" and value then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
	end
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Player and Player.Parent) and true) or false)
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
	Mouse.Button1Up:connect(function()
		InvokeServer("MouseClick", {Down = false})
	end)
	for i, v in pairs({KeyDown, KeyUp}) do
		if v then
			v:disconnect()
		end
	end
	KeyDown = UserInputService.InputBegan:connect(function(InputObject)
		local InputType = InputObject.UserInputType
		local KeyCode = InputObject.KeyCode
		if InputType == Enum.UserInputType.Keyboard then
			InvokeServer("KeyPressed", {Key = KeyCode.Name, Down = true})
		end
	end)
	KeyUp = UserInputService.InputEnded:connect(function(InputObject)
		local InputType = InputObject.UserInputType
		local KeyCode = InputObject.KeyCode
		if InputType == Enum.UserInputType.Keyboard then
			InvokeServer("KeyPressed", {Key = KeyCode.Name, Down = false})
		end
	end)
end

function Unequipped()
	for i, v in pairs({KeyDown, KeyUp}) do
		if v then
			v:disconnect()
		end
	end
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	Animations = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	local ServerReturn
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
end

function OnClientInvoke(mode, value)
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "PlaySound" and value then
		value:Play()
	elseif mode == "StopSound" and value then
		value:Stop()
	elseif mode == "MousePosition" then
		return ((PlayerMouse and {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}) or nil)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)