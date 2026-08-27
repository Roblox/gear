--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
CAS = game:GetService'ContextActionService'
UIS = game:GetService'UserInputService'

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
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
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
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
	
	if UIS.TouchEnabled then
		CAS:BindActionToInputTypes('AllHallowsSword_Snare', function()
			spawn(function() InvokeServer('KeyPress', {Key = 'q', Down = true}) end)
		end, true, '')
		CAS:SetTitle('AllHallowsSword_Snare', 'Vine Snare')
		CAS:BindActionToInputTypes('AllHallowsSword_Wall', function()
			spawn(function() InvokeServer('KeyPress', {Key = 'e', Down = true}) end)
		end, true, '')
		CAS:SetTitle('AllHallowsSword_Wall', 'Vine Wall')
		CAS:BindActionToInputTypes('AllHallowsSword_Shield', function()
			spawn(function() InvokeServer('KeyPress', {Key = 'x', Down = true}) end)
		end, true, '')
		CAS:SetTitle('AllHallowsSword_Shield', 'Vine Shield')
	end
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	Animations = {}
	
	if UIS.TouchEnabled then
		CAS:UnbindAction'AllHallowsSword_Snare'
		CAS:UnbindAction'AllHallowsSword_Wall'
		CAS:UnbindAction'AllHallowsSword_Shield'
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)