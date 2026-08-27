local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local songgui

local CAS = game:GetService("ContextActionService")
local ActionName = "PenguinAttack"

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

function onAction()
	Remote:FireServer("Activate", Mouse.Hit.p)
end

function onEquipped(mouse)
	--ensure unequip
	onUnequipped()
	
	--bind
	mouse.Button1Down:connect(onAction)
end

function onUnequipped()
	--unbind
	CAS:UnbindAction(ActionName)
	
	if songgui then
		songgui:Destroy()
	end
end

function playAnimation(name, ...)
	local anim = Tool:FindFirstChild(name)
	if anim then
		local human = Tool.Parent:FindFirstChild("Humanoid")
		if human then
			local track = human:LoadAnimation(anim)
			track:Play(...)
		end
	end
end

function chooseSong()
	if Player.PlayerGui:FindFirstChild("ChooseSongGui") then return end
	
	local sg = Instance.new("ScreenGui")
	sg.Name = "ChooseSongGui"
	
	local frame = Instance.new("Frame")
	frame.Style = "RobloxRound"
	frame.Size = UDim2.new(0.25, 0, 0.25, 0)
	frame.Position = UDim2.new((1-frame.Size.X.Scale)/2, 0, (1-frame.Size.Y.Scale)/2, 0)
	frame.Parent = sg
	frame.Draggable = true
	
	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.TextStrokeTransparency = 0
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Size = UDim2.new(1, 0, 0.6, 0)
	text.TextScaled = true
	text.Text = "Lay down the beat!\nPut in the ID number for a song you love that's been uploaded to ROBLOX.\nLeave it blank to stop playing music."
	text.Parent = frame
	
	local input = Instance.new("TextBox")
	input.BackgroundColor3 = Color3.new(0, 0, 0)
	input.BackgroundTransparency = 0.5
	input.BorderColor3 = Color3.new(1, 1, 1)
	input.TextColor3 = Color3.new(1, 1, 1)
	input.TextStrokeTransparency = 1
	input.TextScaled = true
	input.Text = "142376088"
	input.Size = UDim2.new(1, 0, 0.2, 0)
	input.Position = UDim2.new(0, 0, 0.6, 0)
	input.Parent = frame
	
	local button = Instance.new("TextButton")
	button.Style = "RobloxButton"
	button.Size = UDim2.new(0.75, 0, 0.2, 0)
	button.Position = UDim2.new(0.125, 0, 0.8, 0)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextStrokeTransparency = 0
	button.Text = "Play!"
	button.TextScaled = true
	button.Parent = frame
	button.MouseButton1Click:connect(function()
		Remote:FireServer("PlaySong", tonumber(input.Text))
		sg:Destroy()
	end)
	
	sg.Parent = Player.PlayerGui
	
	songgui = sg
end

function onRemote(func, ...)
	if func == "PlayAnimation" then
		playAnimation(...)
	end
	
	if func == "ChooseSong" then
		chooseSong()
	end
end

--connect
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnClientEvent:connect(onRemote)