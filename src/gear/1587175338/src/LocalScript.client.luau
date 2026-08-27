Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Animations = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

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
				v.AnimationTrack:Stop()
				table.remove(Animations, i)
			end
		end
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
end

function Unequipped()
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
	if mode == "PlayAnimation" and value and ToolEquipped and Humanoid then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "PlaySound" and value then
		value:Play()
	elseif mode == "StopSound" and value then
		value:Stop()
	elseif mode == "MousePosition" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)