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
local Humanoid = nil

local Remotes = Tool:WaitForChild("Remotes")
local ClientControls = Remotes:WaitForChild("ClientControls")
local ServerControls = Remotes:WaitForChild("ServerControls")

local Gui = script:WaitForChild("WishGui")

local CurrentGui = nil

local Animations = {}

function SetupGui()
	if not Player then return end
	if CurrentGui then
		CurrentGui:Destroy()
	end

	CurrentGui = Gui:Clone()
	CurrentGui.Parent = Player:WaitForChild("PlayerGui")
	
	local WishFrame = CurrentGui:WaitForChild("WishFrame")
	local W1 = WishFrame:WaitForChild("W1")
	local W2 = WishFrame:WaitForChild("W2")
	local W3 = WishFrame:WaitForChild("W3")
	
	W1.MouseButton1Click:Connect(function()
		-- Make me stronger
		if CurrentGui then
			CurrentGui:Destroy()
		end
		CurrentGui = nil
		ServerControls:InvokeServer("MakeStronger")
	end)
	
	W2.MouseButton1Click:Connect(function()
		-- Make me faster
		if CurrentGui then
			CurrentGui:Destroy()
		end
		CurrentGui = nil		
		ServerControls:InvokeServer("MakeFaster")
	end)

	W3.MouseButton1Click:Connect(function()
		-- Float
		if CurrentGui then
			CurrentGui:Destroy()
		end
		CurrentGui = nil		
		ServerControls:InvokeServer("MakeFloat")
	end)			
end

function ClientControls.OnClientInvoke(mode, value)
	if not mode or not ToolEquipped then return end 

	if mode == "GetMouseData" then
		local Data = {Position = Mouse.Hit.p, Target = Mouse.Target}
		
		return Data
	elseif mode == "PlayAnimation" and ToolEquipped and Humanoid then
		for index, anim in next, Animations do 
			if anim.Animation == value.Animation then
				anim.AnimationTrack:Stop()
				table.remove(Animations, index)
			end
		end
		local AnimationTrack = Humanoid:LoadAnimation(value.Animation)
		table.insert(Animations, {Animation = value.Animation, AnimationTrack = AnimationTrack})
		AnimationTrack:Play(value.FadeTime, value.Weight, value.Speed)
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
	elseif mode == "SpawnGenie" then
		SetupGui()
	end
end

Tool.Equipped:Connect(function()
	ToolEquipped = true
	Character =  Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end)

Tool.Unequipped:Connect(function()
	ToolEquipped = false
	for _, anim in next, Animations do
		if anim and anim.AnimationTrack then
			anim.AnimationTrack:Stop()
		end
	end	
	
	if CurrentGui then
		CurrentGui:Destroy()
	end
	
	CurrentGui = nil
	Animations = {}
	
	Character = nil
	Humanoid = nil
end)