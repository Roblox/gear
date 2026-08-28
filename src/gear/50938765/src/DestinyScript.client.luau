--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

local UIS, CAS = game:GetService'UserInputService', game:GetService'ContextActionService'

Animations = {}
Sounds = {}

ClientControl.OnClientInvoke = (function(Mode, Value)
	if not Humanoid then
		return
	end
	if Mode == "PlayAnimation" then
		for i, v in pairs(Animations) do
			if v.Animation == Value then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(Value)
		table.insert(Animations, {Animation = Value, AnimationTrack = AnimationTrack})
		AnimationTrack:Play()
	elseif Mode == "PlaySound" then
		for i, v in pairs(Sounds) do
			if v == Value then
				table.remove(Sounds, i)
			end
		end
		table.insert(Sounds, Value)
		Value:Play()
	end
end)

function InvokeServer(Mode, Value)
	pcall(function()
		ServerControl:InvokeServer(Mode, Value)
	end)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
	Mouse.Button1Down:connect(function()
		InvokeServer("Click", true)
	end)
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	
	if UIS.TouchEnabled then
		CAS:BindActionToInputTypes(
			'ScytheOfSingularity_SpinnyPully',
			function(name, state, input)
				if state == Enum.UserInputState.Begin then
					InvokeServer('KeyPress', {Key = 'w', Down = true})
					InvokeServer('KeyPress', {Key = 'w', Down = true})
					InvokeServer("Click", true)
				end
			end,
			true,
			''
		)
		CAS:SetTitle('ScytheOfSingularity_SpinnyPully', 'Singularity')
	end
end

function Unequipped()	
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	Animations = {}
	Sounds = {}	
	
	if UIS.TouchEnabled then
		CAS:UnbindAction('ScytheOfSingularity_SpinnyPully')
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)