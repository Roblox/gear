-- //Completely redone for R15 avatars and FE by StarWars
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild('PlayerGui')

local Tool = script.Parent

local Remotes = Tool:WaitForChild("Remotes")
local ServerControl = Remotes:WaitForChild("ServerControl")
local ClientControl = Remotes:WaitForChild("ClientControl")

local AnimationsBin = Tool:WaitForChild('Animations')
local AnimationObjects = {
	FlyJets = {Animation = AnimationsBin:WaitForChild("FlyJets"), FadeTime = nil, Weight = nil, Speed = 1, Duration = nil},
	R15FlyJets = {Animation = AnimationsBin:WaitForChild("R15FlyJets"), FadeTime = nil, Weight = nil, Speed = 1, Duration = nil},
	JumpJets = {Animation = AnimationsBin:WaitForChild("JumpJets"), FadeTime = nil, Weight = nil, Speed = 2, Duration = nil},
	R15JumpJets = {Animation = AnimationsBin:WaitForChild("R15JumpJets"), FadeTime = nil, Weight = nil, Speed = 2, Duration = nil},
	LandingJets = {Animation = AnimationsBin:WaitForChild("LandingJets"), FadeTime = nil, Weight = nil, Speed = 1, Duration = nil},	
	R15LandingJets = {Animation = AnimationsBin:WaitForChild("R15LandingJets"), FadeTime = nil, Weight = nil, Speed = 1, Duration = nil},
}

local Gui = Tool:WaitForChild('JumpJetGui'):Clone()
local Fuel = Tool:WaitForChild('Fuel')

local Animations = {}

local ToolEquipped = false

local CurrentGui = nil
local Character = nil
local Head = nil
local HumanoidRootPart = nil
local Humanoid = nil

function SetAnimation(mode, value)
	if not ToolEquipped or not CheckIfAlive() then
		return
	end
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

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Head and Head.Parent and HumanoidRootPart and HumanoidRootPart.Parent and Player and Player.Parent) and true) or false)
end

function Equipped(mouse)
	if CurrentGui then
		CurrentGui:Destroy()
	end
	CurrentGui = Gui:Clone()
	CurrentGui.Enabled = false
	CurrentGui.Parent = PlayerGui	
	
	ToolEquipped = true
	Character = Player.Character
	Head = Character:FindFirstChild('Head')
	HumanoidRootPart = Character:FindFirstChild('HumanoidRootPart')
	Humanoid = Character:FindFirstChildOfClass('Humanoid')
	mouse.Button1Down:Connect(function()
		InvokeServer("MouseDown", {Down = true})
	end)
	mouse.Button1Up:Connect(function()
		InvokeServer("MouseDown", {Down = false})
	end)
end

function Unequipped()
	ToolEquipped = false
	if CurrentGui then
		CurrentGui:Destroy()
	end
	for i, v in pairs(Animations) do
		if v and v.AnimationTrack then
			v.AnimationTrack:Stop()
		end
	end
end

function OnClientInvoke(mode, value)
	if not ToolEquipped or not CheckIfAlive() or not mode then
		return
	end
	if mode == "PlayAnimation" and value then
		SetAnimation("PlayAnimation", value)
	elseif mode == "StopAnimation" and value then
		SetAnimation("StopAnimation", value)
	elseif mode == "PlaySound" and value then
		value:Play()
	elseif mode == "StopSound" and value then
		value:Stop()
	elseif mode == "Off" then
		if CurrentGui then
			CurrentGui.Enabled = false
		end
	elseif mode == "On" then
		if CurrentGui then
			CurrentGui.Enabled = true
		end
	end
end

function InvokeServer(mode, value)
	local ServerReturn = nil
	pcall(function()
		ServerReturn = ServerControl:InvokeServer(mode, value)
	end)
	return ServerReturn
end

Fuel.Changed:Connect(function(value)	
	if CurrentGui then
		CurrentGui.Bar.Fill.Size = UDim2.new(value, 0, 1, 0)
	end
end)

ClientControl.OnClientInvoke = OnClientInvoke
Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)