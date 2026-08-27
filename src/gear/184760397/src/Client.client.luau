local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Power = Tool:WaitForChild("Power")
local Charging = Tool:WaitForChild("Charging")

local CAS = game:GetService("ContextActionService")
local ActionName = "SteampunkBow"

local Gauge
local GaugeEvent

local Animations = {
	Pull = Tool:WaitForChild("Pull"),
	Charge = Tool:WaitForChild("Charge"),
	Fire = Tool:WaitForChild("Fire"),
}
local ChargeTracks = {}
local ChargeEvent

function onAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Remote:FireServer("Start")
	end
	
	if inputState == Enum.UserInputState.End then
		Remote:FireServer("End", Mouse.Hit.p)
	end
end

function playAnimation(name, ...)
	if Animations[name] then
		local char = Player.Character
		if char then
			local human = char.Humanoid
			if human then
				local track = human:LoadAnimation(Animations[name])
				track:Play(...)
				return track
			end
		end
	end
end

function startAnimation()
	ChargeEvent = Charging.Changed:connect(function()
		if Charging.Value then
			playAnimation("Pull")
			wait(0.5)
			if Charging.Value then
				table.insert(ChargeTracks, playAnimation("Charge", 0))
			end
		else
			for _, track in pairs(ChargeTracks) do
				track:Stop(0)
			end
			playAnimation("Fire", 0)
		end
	end)
end

function endAnimation()
	if ChargeEvent then
		ChargeEvent:disconnect()
	end
	for _, track in pairs(ChargeTracks) do
		track:Stop(0)
	end
end

function createGauge()
	local sg = Instance.new("ScreenGui")
	Gauge = sg
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0.15, 0, 0.15/2, 0)
	frame.Position = UDim2.new((1-frame.Size.X.Scale)/2, 0, 0.7, 0)
	frame.Style = "RobloxRound"
	frame.Parent = sg
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 0.5, 0)
	text.TextScaled = true
	text.TextStrokeTransparency = 0
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Position = UDim2.new(0, 0, -0.5, 0)
	text.Text = "Steampunk Bow"
	text.BackgroundTransparency = 1
	text.Parent = frame
	
	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 0, 1, 0)
	bar.BorderColor3 = Color3.new(0, 0, 0)
	bar.BorderSizePixel = 2
	bar.Parent = frame
	
	GaugeEvent = Power.Changed:connect(function()
		local r = Power.Value / 100
		local a = Vector3.new(0, 0, 0)
		local b = Vector3.new(1, 1, 1)
		local c = a + (b - a) * r
		bar.Size = UDim2.new(r, 0, 1, 0)
		bar.BackgroundColor3 = Color3.new(c.X, c.Y, c.Z)
	end)
	
	sg.Parent = Player.PlayerGui
end

function destroyGauge()
	if Gauge then
		Gauge:Destroy()
	end
	if GaugeEvent then
		GaugeEvent:disconnect()
	end
end

function onEquipped()
	--ensure unequip
	onUnequipped()
	
	--gauge
	createGauge()
	
	--animations
	startAnimation()
	
	--bind
	CAS:BindActionToInputTypes(
		ActionName,
		onAction,
		false,
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	)
end

function onUnequipped()
	--unbind
	CAS:UnbindAction(ActionName)
	
	--gauge stuff
	destroyGauge()
	
	--animations
	endAnimation()
end

--connect
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)