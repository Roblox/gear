--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Animations = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlayAnimation" then
		for i, v in pairs(Animations) do
			if v.Animation == Value then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(Value.Animation)
		table.insert(Animations, {Animation = Value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(nil, nil, Value.Speed)
	end
end)

function InvokeServer(Mode, Value)
	pcall(function()
		ServerControl:InvokeServer(Mode, Value)
	end)
end

function CheckIfAlive()
	return (Player and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true})
	end)
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true, Position = Mouse.Hit.p})
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