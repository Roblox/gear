--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")

InputCheck = Instance.new("ScreenGui")
InputCheck.Name = "InputCheck"
InputButton = Instance.new("Frame")
InputButton.Name = "InputMonitor"
InputButton.BackgroundTransparency = 1
InputButton.Size = UDim2.new(1, 0, 1, 0)
InputButton.Parent = InputCheck

Animations = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

Rate = (1 / 60)

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
				v.AnimationTrack:Stop(value.FadeTime)
				table.remove(Animations, i)
			end
		end
	end
end

function KeyPressed(Key, Down)
	InvokeServer("KeyPressed", {Key = Key, Down = Down})
end

function MouseClick(Down)
	InvokeServer("MouseClick", {Down = Down})
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
	PlayerMouse.Button1Down:connect(function()
		MouseClick(true)
	end)
	PlayerMouse.Button1Up:connect(function()
		MouseClick(false)
	end)
	PlayerMouse.KeyDown:connect(function(Key)
		KeyPressed(Key, true)
	end)
	PlayerMouse.KeyUp:connect(function(Key)
		KeyPressed(Key, false)
	end)
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		if UserInputService.TouchEnabled then
			InputCheckClone = InputCheck:Clone()
			InputCheckClone.InputMonitor.InputBegan:connect(function()
				MouseClick(true)
			end)
			InputCheckClone.InputMonitor.InputEnded:connect(function()
				MouseClick(false)
			end)
			InputCheckClone.Parent = PlayerGui
		end
	end
end

function Unequipped()
	if InputCheckClone and InputCheckClone.Parent then
		InputCheckClone:Destroy()
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
	elseif mode == "MouseData" then
		return ((PlayerMouse and {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}) or nil)
	elseif mode == "SetCamera" then
		local Properties = value.Properties
		local Camera = game:GetService("Workspace").CurrentCamera
		for i, v in pairs(Properties) do
			pcall(function()
				Camera[i] = v
			end)
		end
	elseif mode == "SetTargetFilter" then
		local Object = value.Object
		PlayerMouse.TargetFilter = Object
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)