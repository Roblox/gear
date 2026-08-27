--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Debris = game:GetService("Debris")

Animations = {}

Remotes = Tool:WaitForChild("Remotes")
ServerControl = Remotes:WaitForChild("ServerControl")
ClientControl = Remotes:WaitForChild("ClientControl")

Sounds = {
	Hop = Handle:WaitForChild("Hop"),
}

Rate = (1 / 60)

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
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function HandleJump(Enabled)
	if CheckIfAlive() then
		Humanoid.HipHeight = 0
		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50
	end
	for i, v in pairs({JumpMonitor, StateChanged}) do
		if v then
			v:disconnect()
		end
	end
	if not Enabled or not CheckIfAlive() or not ToolEquipped then
		return
	end
	Humanoid.HipHeight = 0.72
	Humanoid.WalkSpeed = 0
	Humanoid.JumpPower = 100
	local Hopping = false
	local LastHop = 0
	local function CanJump()
		return ((tick() - LastHop) >= 1.5 and not Hopping)
	end
	JumpMonitor = Humanoid.Changed:connect(function(Property)
		if Property == "Jump" then
			local State = Humanoid:GetState().Name
			local Velocity = (Torso.Velocity * Vector3.new(0, 1, 0))
			if Humanoid.Jump and CanJump() and not Hopping then
				LastHop = tick()
				Hopping = true
				Humanoid.WalkSpeed = 16
				local Sound = Sounds.Hop:Clone()
				Sound.Pitch = (math.random(1250, 1750) * 0.001)
				Debris:AddItem(Sound, 2)
				Sound.Parent = Handle
				Sound:Play()
			else
				Humanoid.Jump = false
			end
		end
	end)
	StateChanged = Humanoid.StateChanged:connect(function(OldState, NewState)
		local State = NewState.Name
		local Velocity = (Torso.Velocity * Vector3.new(0, 1, 0))
		if State ~= "Jumping" and State ~= "Freefall" and Hopping then
			Humanoid.WalkSpeed = 0
			Hopping = false
		end
	end)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
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
	Spawn(function()
		HandleJump(true)
	end)
end

function Unequipped()
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
	Spawn(function()
		HandleJump(false)
	end)
	Animations = {}
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

Delay(0, (function()
	if ToolEquipped then
		return
	end
	HandleJump(false)
end))

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)