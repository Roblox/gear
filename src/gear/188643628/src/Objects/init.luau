--Made by Luckymaxer

ScreenAdjust = script:WaitForChild("ScreenAdjust")

Objects = {}

function Objects.CreateZoomGui()
	local ZoomGui = Instance.new("ScreenGui")
	ZoomGui.Name = "ZoomGui"
	local Frame1 = Instance.new("Frame")
	Frame1.Name = "Frame1"
	Frame1.BackgroundColor3 = Color3.new(0, 0, 0)
	Frame1.BorderColor3 = Color3.new(0, 0, 0)
	Frame1.Position = UDim2.new(0, -10, 0, -10)
	Frame1.Size = UDim2.new(0, 248, 1, 20)
	Frame1.ZIndex = 1
	Frame1.Parent = ZoomGui
	local Frame2 = Instance.new("Frame")
	Frame2.Name = "Frame2"
	Frame2.BackgroundColor3 = Color3.new(0, 0, 0)
	Frame2.BorderColor3 = Color3.new(0, 0, 0)
	Frame2.Position = UDim2.new(1, -238, 0, -10)
	Frame2.Size = UDim2.new(0, 248, 1, 20)
	Frame2.ZIndex = 1
	Frame2.Parent = ZoomGui
	local Scope = Instance.new("ImageLabel")
	Scope.Name = "Scope"
	Scope.BackgroundColor3 = Color3.new(0, 0, 0)
	Scope.BorderColor3 = Color3.new(0, 0, 0)
	Scope.BackgroundTransparency = 1
	Scope.Image = "http://www.roblox.com/asset/?id=72002022"
	Scope.ImageColor3 = Color3.new(255, 255, 255)
	Scope.Position = UDim2.new(0.5, -330, 0, -10)
	Scope.Size = UDim2.new(0, 659, 0, 659)
	Scope.ZIndex = 1
	Scope.Parent = ZoomGui
	local ScreenAdjustScript = ScreenAdjust:Clone()
	ScreenAdjustScript.Disabled = false
	ScreenAdjustScript.Parent = ZoomGui
	return ZoomGui
end

function Objects.CreateCrosshairGui()
	local CrosshairGui = Instance.new("ScreenGui")
	CrosshairGui.Name = "CrosshairGui"
	local CrosshairFrame = Instance.new("Frame")
	CrosshairFrame.Name = "CrosshairFrame"
	CrosshairFrame.BackgroundColor3 = Color3.new(0, 255, 0)
	CrosshairFrame.BackgroundTransparency = 1
	CrosshairFrame.Position = UDim2.new(0.5, -32, 0.5, -32)
	CrosshairFrame.Size = UDim2.new(0, 64, 0, 64)
	CrosshairFrame.BorderSizePixel = 0
	CrosshairFrame.ZIndex = 1
	CrosshairFrame.Parent = CrosshairGui
	local TopFrame = Instance.new("Frame")
	TopFrame.Name = "TopFrame"
	TopFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	TopFrame.BorderColor3 = Color3.new(0, 255, 0)
	TopFrame.BorderSizePixel = 1
	TopFrame.Position = UDim2.new(0.5, -1, 0, -15)
	TopFrame.Size = UDim2.new(0, 2, 0, 15)
	TopFrame.ZIndex = 1
	TopFrame.Parent = CrosshairFrame
	local BottomFrame = Instance.new("Frame")
	BottomFrame.Name = "BottomFrame"
	BottomFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	BottomFrame.BorderColor3 = Color3.new(0, 255, 0)
	BottomFrame.BorderSizePixel = 1
	BottomFrame.Position = UDim2.new(0.5, -1, 1, 0)
	BottomFrame.Size = UDim2.new(0, 2, 0, 15)
	BottomFrame.ZIndex = 1
	BottomFrame.Parent = CrosshairFrame
	local LeftFrame = Instance.new("Frame")
	LeftFrame.Name = "LeftFrame"
	LeftFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	LeftFrame.BorderColor3 = Color3.new(0, 255, 0)
	LeftFrame.BorderSizePixel = 1
	LeftFrame.Position = UDim2.new(0, -15, 0.5, -1)
	LeftFrame.Size = UDim2.new(0, 15, 0, 2)
	LeftFrame.ZIndex = 1
	LeftFrame.Parent = CrosshairFrame
	local RightFrame = Instance.new("Frame")
	RightFrame.Name = "RightFrame"
	RightFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	RightFrame.BorderColor3 = Color3.new(0, 255, 0)
	RightFrame.BorderSizePixel = 1
	RightFrame.Position = UDim2.new(1, -0, 0.5, -1)
	RightFrame.Size = UDim2.new(0, 15, 0, 2)
	RightFrame.ZIndex = 1
	RightFrame.Parent = CrosshairFrame
	local ReloadingLabel = Instance.new("TextLabel")
	ReloadingLabel.BackgroundTransparency = 1
	ReloadingLabel.Name = "ReloadingLabel"
	ReloadingLabel.Position = UDim2.new(0.5, 20, 0.5, -20)
	ReloadingLabel.Size = UDim2.new(0, 0, 0)
	ReloadingLabel.Font = Enum.Font.ArialBold
	ReloadingLabel.FontSize = Enum.FontSize.Size18
	ReloadingLabel.TextColor3 = Color3.new(0, 0, 0)
	ReloadingLabel.TextStrokeColor3 = Color3.new(0, 255, 0)
	ReloadingLabel.TextStrokeTransparency = 0
	ReloadingLabel.TextTransparency = 0
	ReloadingLabel.Text = "Reloading"
	ReloadingLabel.TextXAlignment = Enum.TextXAlignment.Left
	ReloadingLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	ReloadingLabel.ZIndex = 1
	ReloadingLabel.Visible = false
	ReloadingLabel.Parent = CrosshairGui
	local Spread = 0.1
	local SpreadChanged = Instance.new("RemoteFunction")
	SpreadChanged.OnServerInvoke = (function(Player, Mode, Value)
		if Mode == "SetSpread" and Value then
			Spread = Value.Spread
			local Speed = Value.Speed
			CrosshairFrame:TweenPosition(UDim2.new(0.5, ((1 - (Spread * CrosshairGui.AbsoluteSize.Y)) / 2), 0.5, (1 - ((Spread * CrosshairGui.AbsoluteSize.Y)) / 2)), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, Speed, true, (function() end))
			CrosshairFrame:TweenSize(UDim2.new(0, (Spread * CrosshairGui.AbsoluteSize.Y), 0, (Spread * CrosshairGui.AbsoluteSize.Y)), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, Speed, true, (function() end))
		end
	end)
	return {Gui = CrosshairGui, Spread = SpreadChanged}
end

return Objects