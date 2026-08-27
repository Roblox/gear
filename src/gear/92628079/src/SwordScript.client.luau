--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

ServerControl = Tool:WaitForChild("ServerControl")
ClientControl = Tool:WaitForChild("ClientControl")

AnimationTracks = {}

function PlayAnimation(Anim, Speed)
	if Humanoid and Anim then
		AnimTrack = Humanoid:LoadAnimation(Anim)
		if not AnimationTracks[Anim.Name] then
			AnimationTracks[Anim.Name] = nil
		end
		if AnimationTracks[Anim.Name] then
			AnimationTracks[Anim.Name]:Stop()
		end
		AnimationTracks[Anim.Name] = AnimTrack
		if Speed then
			AnimTrack:AdjustSpeed(Speed)
		end
		AnimTrack:Play()
		return AnimTrack
	end
	return nil
end

ClientControl.OnClientInvoke = (function(Mode, Value)
	if Mode == "PlayAnimation" then
		PlayAnimation(Value.Animation, Value.Speed)
	elseif Mode == "PlaySound" then
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
		InvokeServer("Button1", true)
	end)
	Mouse.Button2Down:connect(function()
		InvokeServer("Button2", {Down = true, TargetPoint = Mouse.Hit.p})
	end)
	Mouse.Button2Up:connect(function()
		InvokeServer("Button2", {Down = false, TargetPoint = Mouse.Hit.p})
	end)
end

function Unequipped()
	for i, v in pairs(AnimationTracks) do
		if v then
			v:Stop()
		end
	end
	AnimationTracks = {}
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)