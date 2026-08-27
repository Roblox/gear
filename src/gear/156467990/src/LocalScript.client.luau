--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Animations = {}
Sounds = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

local UIS, CAS = game:GetService'UserInputService', game:GetService'ContextActionService'

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
		local AnimationTrack = Humanoid:LoadAnimation(Value.Animation)
		table.insert(Animations, {Animation = Value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(nil, nil, Value.Speed)
	elseif Mode == "StopAnimations" then
		for i, v in pairs(Animations) do
			if v and v.AnimationTrack then
				v.AnimationTrack:Stop()
			end
		end
		Animations = {}
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

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Tool.Enabled then
		wait(0.5)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		InvokeServer("Click", true)
	end)
	Mouse.KeyDown:connect(function(Key)
		local Key = Key:lower()
		if Key == "q" then
			InvokeServer("KeyPress", {Key = Key, Down = true})
		end
	end)
	if UIS.TouchEnabled then
		CAS:BindActionToInputTypes(
			'OverseerShortSword_SpawnMinions',
			function(name, state, input)
				if state == Enum.UserInputState.Begin then
					InvokeServer('KeyPress', {Key = 'q', Down = true})
				end
			end,
			true,
			''
		)
		CAS:SetTitle('OverseerShortSword_SpawnMinions', 'Spawn Minions')
	end
end

function Unequipped()
	if UIS.TouchEnabled then
		CAS:UnbindAction('OverseerShortSword_SpawnMinions')
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)