local Tool = script.Parent

local sg = nil
local frame = nil

local stillEquipped = false

local function onEquippedLocal(mouse)
	stillEquipped = true

	local vPlayer = game.Players.LocalPlayer
	local playerGui = vPlayer:FindFirstChild("PlayerGui")
	if playerGui and playerGui:FindFirstChild("PetGui") == nil then
		sg = Instance.new("ScreenGui")
		sg.Name = "PetGui"
		sg.Parent = playerGui

		frame = Instance.new("Frame")
		frame.Parent = sg
		frame.Style = Enum.FrameStyle.RobloxRound
		frame.Size = UDim2.new(0, 120, 0, 30)
		frame.Position = UDim2.new(0.5, -60, 1, -130)

		local genericTextLabel = Instance.new("TextLabel")
		genericTextLabel.BackgroundTransparency = 1.0
		genericTextLabel.Size = UDim2.new(1, 0, 1, 0)
		genericTextLabel.Visible = true
		genericTextLabel.ZIndex = 10
		genericTextLabel.FontSize = Enum.FontSize.Size10
		genericTextLabel.Font = Enum.Font.Legacy
		genericTextLabel.TextColor3 = Color3.new(1, 0, 1)
		genericTextLabel.TextXAlignment = Enum.TextXAlignment.Center
		genericTextLabel.TextYAlignment = Enum.TextYAlignment.Top
		genericTextLabel.Parent = frame
		genericTextLabel.Text = "Click to call Crash!"
	end

	if not mouse then return end

	while stillEquipped do
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
		while Tool.Enabled and stillEquipped do
			wait(0.01)
		end
		mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
		while not Tool.Enabled and stillEquipped do
			wait(0.01)
		end
	end
end

local function onActivatedLocal()
	if frame and frame:FindFirstChild("TextLabel") then
		frame.Size = UDim2.new(0, 300, 0, 30)
		frame.Position = UDim2.new(0.5, -150, 1, -130)
		frame.TextLabel.Text = "Click players to see Crash do something crazy!"
	end
end

local function onUnequippedLocal()
	if sg then sg:Remove() end
	stillEquipped = false
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Activated:connect(onActivatedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
