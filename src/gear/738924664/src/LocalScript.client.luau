--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")

Animations = {}

Remotes = Tool:WaitForChild("Remotes")
ServerControl = Remotes:WaitForChild("ServerControl")
ClientControl = Remotes:WaitForChild("ClientControl")

ToolEquipped = false

function SetAnimation(mode, value)
	if not ToolEquipped or not CheckIfAlive() or not mode or not value then
		return
	end
	if mode == "PlayAnimation" then
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
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Mouse
	ToolEquipped = true
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

function InvokeServer(mode, value)
	local ServerReturn
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
end

function OnClientInvoke(mode, value)
	if not mode or not ToolEquipped or not CheckIfAlive() then
		return
	end
	if mode == "PlayAnimation" then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "MouseData" then
		if UserInputService.GamepadEnabled then --Gamepad usability
			local Distance = {Min = 15, Max = 25}
			local Height = {Min = 5, Max = 8}
			return {Position = ((Torso.CFrame + Torso.CFrame.lookVector * (math.random((Distance.Min * 1000), (Distance.Max * 1000)) * 0.001)).p + Vector3.new(0, (math.random((Height.Min * 1000), (Height.Max * 1000)) * 0.001), 0)), Target = nil}
		else
			return ((PlayerMouse and {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}) or nil)
		end
	end
end

ClientControl.OnClientInvoke = OnClientInvoke

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)