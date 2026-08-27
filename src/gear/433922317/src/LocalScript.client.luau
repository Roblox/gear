--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Debris = game:GetService("Debris")

Animations = {}

AnimationObjs = {
	Pose = {Animation = Tool:WaitForChild("Pose"), FadeTime = 0.25, Weight = nil, Speed = 0.25, Duration = nil},
}

Remotes = Tool:WaitForChild("Remotes")
ServerControl = Remotes:WaitForChild("ServerControl")
ClientControl = Remotes:WaitForChild("ClientControl")

Rate = (1 / 60)

Swimming = false
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

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and RootPart and RootPart.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	RootPart = Character:FindFirstChild("HumanoidRootPart")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Mouse
	PlayerMouse.KeyDown:connect(function(Key)
		KeyPressed(Key, true)
	end)
	PlayerMouse.KeyUp:connect(function(Key)
		KeyPressed(Key, false)
	end)
	if SwimCheck then
		SwimCheck:disconnect()
	end
	local SwimAnim = AnimationObjs.Pose
	SwimCheck = RunService.Stepped:connect(function(Time, Step)
		for i, v in pairs(Humanoid:GetPlayingAnimationTracks()) do --Disable default tool hold pose
			if string.find(string.lower(v.Name), string.lower("Tool")) then
				v:Stop()
			end
		end
		local State = Humanoid:GetState().Name
		local Velocity = (RootPart.Velocity * Vector3.new(1, 0, 1))
		if State == "Swimming" and Velocity.Magnitude <= 1 then
			if not Swimming then
				Swimming = true
				SetAnimation("PlayAnimation", SwimAnim)
			end
		else
			if Swimming then
				Swimming = false
				SetAnimation("StopAnimation", SwimAnim)
			end
		end
	end)
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	if SwimCheck then
		SwimCheck:disconnect()
	end
	Animations = {}
	Swimming = false
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
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)