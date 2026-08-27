--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")

Camera = game:GetService("Workspace").CurrentCamera

Modules = Tool:WaitForChild("Modules")
Configuration = require(Modules:WaitForChild("Configuration"))
Objects = require(Modules:WaitForChild("Templates"))
Content = require(Modules:WaitForChild("Content"))
Functions = require(Modules:WaitForChild("Functions"))

Animations = {}
LocalObjects = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

ReloadCounter = 0

ToolEquipped = false

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

function SetMouseIcon(Mouse)
	if not ToolEquipped then
		return
	end
	local MouseData = OnClientInvoke("MousePosition")
	if not MouseData then
		return
	end
	local Position = MouseData.Position
	local Target = MouseData.Target
	local Cursors = Content.Cursors
	if not Tool.Enabled then
		ReloadCounter = (ReloadCounter + 1)
		if (ReloadCounter % 20) < 10 then
			Mouse.Icon = Cursors.ReloadStatic1
		else
			Mouse.Icon = Cursors.ReloadStatic2
		end
	elseif Target and Functions.FindCharacterAncestor(Target) then
		Mouse.Icon = Cursors.Target
	else
		Mouse.Icon = Cursors.Normal
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
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
	Mouse.Move:connect(function()
		InvokeServer("MouseMove", {Position = Mouse.Hit.p, Target = Mouse.Target})
	end)
	Spawn(function()
		while ToolEquipped and Mouse do
			SetMouseIcon(Mouse)
			wait()
		end
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
	for i, v in pairs({ObjectLocalTransparencyModifier}) do
		if v then
			v:disconnect()
		end
	end
	PlayerMouse.Icon = ""
	Animations = {}
end

function InvokeServer(Mode, Value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(Mode, Value)
		return ServerReturn
	end)
end

function OnClientInvoke(Mode, Value)
	if Mode == "PlayAnimation" and Value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", Value)
	elseif Mode == "StopAnimation" and Value then
		SetAnimation("StopAnimation", Value)
	elseif Mode == "PlaySound" and Value then
		Value:Play()
	elseif Mode == "StopSound" and Value then
		Value:Stop()
	elseif Mode == "MousePosition" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	elseif Mode == "SetMouseIcon" and Value and ToolEquipped then
		PlayerMouse.Icon = Value
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
						if v.Object and v.Object.Parent then
							if ((not v.AutoUpdate and (v.Object.LocalTransparencyModifier == 1 or  v.Object.LocalTransparencyModifier == 0)) or v.AutoUpdate) then
								v.Object.LocalTransparencyModifier = v.Transparency
							end
						else
							table.remove(LocalObjects, i)
						end
					end
				end)
			end
		end)
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
ClientControl.OnClientInvoke = OnClientInvoke