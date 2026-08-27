--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
ContentProvider = game:GetService("ContentProvider")

BaseUrl = "http://www.roblox.com/asset/?id="

Animations = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

Content = require(Tool:WaitForChild("Content"))

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

function DisableJump(Boolean)
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs({JumpDisabled, MobilityLoop}) do
		if v then
			v:disconnect()
		end
	end
	if Boolean then
		JumpDisabled = Humanoid.Changed:connect(function(Property)
			if Property == "Jump" then
				Humanoid.Jump = false
			end
		end)
		MobilityLoop = RunService.Stepped:connect(function()
			Humanoid.WalkSpeed = 0
			Humanoid.AutoRotate = false
		end)
	else
		Humanoid.WalkSpeed = 16
		Humanoid.AutoRotate = true
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
	Spawn(function()
		PlayerMouse = Mouse
		Mouse.Button1Down:connect(function()
			InvokeServer("Button1Click", {Down = true})
		end)
		Mouse.Button1Up:connect(function()
			InvokeServer("Button1Click", {Down = false})
		end)
		Mouse.KeyDown:connect(function(Key)
			InvokeServer("KeyPress", {Key = Key, Down = true})
		end)
		Mouse.KeyUp:connect(function(Key)
			InvokeServer("KeyPress", {Key = Key, Down = false})
		end)
		Spawn(function()
			for i, v in pairs(Content.Images) do
				ContentProvider:Preload(BaseUrl .. v)
			end
		end)
	end)
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	DisableJump(false)
	Animations = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(mode, value)
		return ServerReturn
	end)
end

function OnClientInvoke(mode, value)
	if not mode or not value or not CheckIfAlive() then
		return
	end
	if mode == "PlayAnimation" and value and ToolEquipped then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "MouseData" then
		return ((PlayerMouse and {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target, TargetSurface = PlayerMouse.TargetSurface}) or nil)
	elseif mode == "DisableMobility" then
		DisableJump(value.Disabled)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)