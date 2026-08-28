-- // Created by StarWars
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Tool = script.Parent
local Handle = Tool:FindFirstChild("Handle")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local ToolEquipped = false
local Character = nil
local Humanoid

local Remotes = Tool:WaitForChild("Remotes")
local ClientControls = Remotes:WaitForChild("ClientControls")
local ServerControls = Remotes:WaitForChild("ServerControls")

local Animations = {}

function PlayAnimation(Value)
	for index, anim in next, Animations do 
		if anim.Animation == Value.Animation then
			anim.AnimationTrack:Stop()
			table.remove(Animations, index)
		end
	end
	local AnimationTrack = Humanoid:LoadAnimation(Value.Animation)
	table.insert(Animations, {Animation = Value.Animation, AnimationTrack = AnimationTrack})
	AnimationTrack:Play(Value.FadeTime, Value.Weight, Value.Speed)
end

function ClientControls.OnClientInvoke(mode, value)
	if not mode or not ToolEquipped then return end 

	if mode == "GetMouseData" then
		local Data = {Position = Mouse.Hit.p, Target = Mouse.Target}
		
		return Data
	elseif mode == "PlayAnimation" and ToolEquipped and Humanoid then
		PlayAnimation(value)
	elseif mode == "StopAnimation" and value then
		for index, anim in next, Animations do
			if anim.Animation == value.Animation then
				anim.AnimationTrack:Stop()
				table.remove(Animations, index)
			end
		end
	elseif mode == "PlaySound" and value and typeof(value) == 'Instance' and value:IsA("Sound") then
		value:Play()
	elseif mode == "StopSound" and value and typeof(value) == 'Instance' and value:IsA("Sound") then
		value:Stop()
	end
end

Tool.Equipped:Connect(function()
	ToolEquipped = true
	Character =  Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	local Animation = Tool:WaitForChild("Animations"):WaitForChild("R6"):WaitForChild("Hold")
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Animation = Tool.Animations:WaitForChild("R15"):WaitForChild("Hold")
	end
	
	PlayAnimation({Animation = Animation})
end)

Tool.Unequipped:Connect(function()
	ToolEquipped = false
	for _, anim in next, Animations do
		if anim and anim.AnimationTrack then
			anim.AnimationTrack:Stop()
		end
	end	
	
	Animations = {}
	
	Character = nil
	Humanoid = nil
end)