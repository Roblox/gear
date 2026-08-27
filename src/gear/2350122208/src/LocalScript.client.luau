--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
RunService = game:GetService("RunService")
ContentProvider = game:GetService("ContentProvider")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Animations = {}

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

Rate = (1 / 60)

ToolEquipped = false

function SetAnimation(mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
	local function StopAnimation(Animation)
		for i, v in pairs(Animations) do
			if v.Animation == Animation then
				v.AnimationTrack:Stop(value.EndFadeTime)
				if v.TrackStopped then
					v.TrackStopped:disconnect()
				end
				table.remove(Animations, i)
			end
		end
	end
	if mode == "PlayAnimation" then
		for i, v in pairs(Animations) do
			if v.Animation == value.Animation then
				if value.Speed then
					v.AnimationTrack:AdjustSpeed(value.Speed)
					return
				elseif value.Weight or value.FadeTime then
					v.AnimationTrack:AdjustWeight(value.Weight, value.FadeTime)
					return
				else
					StopAnimation(value.Animation, false)
				end
			end
		end
		local AnimationMonitor = Create("Model"){}
		local TrackEnded = Create("StringValue"){Name = "Ended"}
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		local TrackStopped
		if not value.Manual then
			TrackStopped = AnimationTrack.Stopped:connect(function()
				if TrackStopped then
					TrackStopped:disconnect()
				end
				StopAnimation(value.Animation, true)
				TrackEnded.Parent = AnimationMonitor
			end)
		end
		table.insert(Animations, {Animation = value.Animation, AnimationTrack = AnimationTrack, TrackStopped = TrackStopped})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
		if TrackStopped then
			AnimationMonitor:WaitForChild(TrackEnded.Name)
		end
		return TrackEnded.Name
	elseif mode == "StopAnimation" and value then
		StopAnimation(value.Animation)
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
	Spawn(function()
		PlayerMouse = Player:GetMouse()
		Mouse.Button1Down:connect(function()
			InvokeServer("Button1Click", {Down = true})
		end)
		Mouse.Button1Up:connect(function()
			InvokeServer("Button1Click", {Down = false})
		end)
		Mouse.KeyDown:connect(function(Key)
			InvokeServer("KeyPress", {Key = Key, Down = true})
		end)
		Mouse.KeyUp:connect(function(Key)
			InvokeServer("KeyPress", {Key = Key, Down = false})
		end)
		for i, v in pairs(Tool:GetChildren()) do
			if v:IsA("Animation") then
				ContentProvider:Preload(v.AnimationId)
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
	Animations = {}
	ToolEquipped = false
end

function InvokeServer(mode, value)
	local ServerReturn = nil
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
	elseif mode == "MousePosition" then
		return {Position = PlayerMouse.Hit.p, Target = PlayerMouse.Target}
	end
end

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)