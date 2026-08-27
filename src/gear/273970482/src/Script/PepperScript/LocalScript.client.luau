--Made by Luckymaxer

MainScript = script.Parent
Character = MainScript.Parent
Humanoid = Character:WaitForChild("Humanoid")

Players = game:GetService("Players")

Animations = {}

ServerControl = MainScript:WaitForChild("ServerControl")
ClientControl = MainScript:WaitForChild("ClientControl")

Rate = (1 / 60)

function SetAnimation(mode, value)
	if mode == "PlayAnimation" and value then
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

function InvokeServer(mode, value)
	pcall(function()
		local ServerReturn = ServerControl:InvokeServer(mode, value)
		return ServerReturn
	end)
end

function OnClientInvoke(mode, value)
	if mode == "PlayAnimation" and value then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	end
end

ClientControl.OnClientInvoke = OnClientInvoke