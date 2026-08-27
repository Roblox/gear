--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
ContentProvider = game:GetService("ContentProvider")
RunService = game:GetService("RunService")

Camera = game:GetService("Workspace").CurrentCamera

Animations = {}
LocalObjects = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ToolEquipped = false

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", Value)
	elseif Mode == "StopAnimation" and Value then
		SetAnimation("StopAnimation", Value)
	elseif Mode == "Preload" and Value then
		ContentProvider:Preload(Value)
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
	elseif Mode == "MousePosition" then
		return PlayerMouse.Hit.p
	elseif Mode == "DisableJump" then
		DisableJump(Value)
	elseif Mode == "SetLocalTransparencyModifier" and Value and ToolEquipped then
		pcall(function()
			local ObjectFound = false
			for i, v in pairs(LocalObjects) do
				if v == Value then
					ObjectFound = true
				end
			end
			if not ObjectFound then
				table.insert(LocalObjects, Value)
				if ObjectLocalTransparencyModifier then
					ObjectLocalTransparencyModifier:disconnect()
				end
				ObjectLocalTransparencyModifier = RunService.RenderStepped:connect(function()
					for i, v in pairs(LocalObjects) do
						if v.Object and v.Object.Parent and ((not v.AutoUpdate and (v.Object.LocalTransparencyModifier == 1 or  v.Object.LocalTransparencyModifier == 0)) or v.AutoUpdate) then
							v.Object.LocalTransparencyModifier = v.Transparency
						end
					end
				end)
			end
		end)
	end
end)

function InvokeServer(Mode, Value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(Mode, Value)
	end)
	return ServerReturn
end

function SetAnimation(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
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
			if v.Animation == Value.Animation then
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
	end
end

function DisableJump(Boolean)
	if PreventJump then
		PreventJump:disconnect()
	end
	if Boolean then
		PreventJump = Humanoid.Changed:connect(function(Property)
			if Property ==  "Jump" then
				Humanoid.Jump = false
			end
		end)
	end
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	ToolEquipped = true
	if not CheckIfAlive() then
		return
	end
	PlayerMouse = Player:GetMouse()
	Mouse.Button1Down:connect(function()
		InvokeServer("MouseClick", {Down = true})
	end)
	Mouse.Button1Up:connect(function()
		InvokeServer("MouseClick", {Down = false})
	end)
	Mouse.KeyDown:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		InvokeServer("KeyPress", {Key = Key, Down = false})
	end)
	Mouse.WheelForward:connect(function()
		InvokeServer("WheelMoved", {Forward = true})
	end)
	Mouse.WheelBackward:connect(function()
		InvokeServer("WheelMoved", {Forward = false})
	end)
end

function Unequipped()
	ToolEquipped = false
	LocalObjects = {}
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	for i, v in pairs({PreventJump, ObjectLocalTransparencyModifier}) do
		if v then
			v:disconnect()
		end
	end
	Animations = {}
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)