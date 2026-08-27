--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Camera = game:GetService("Workspace").CurrentCamera

Animations = {}

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
			if v.Animation == Value then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
	elseif Mode == "TargetPosition" then
		return PlayerMouse.Hit.p
	elseif Mode == "SetCameraType" and Value then
		pcall(function()
			Camera.CameraType = Value
		end)
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
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Player:GetMouse()
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true, Target = Mouse.Target})
	end)
	Mouse.Button1Up:connect(function()
		InvokeServer("MouseClick", {Down = false, Target = Mouse.Target})
	end)
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	Animations = {}
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)