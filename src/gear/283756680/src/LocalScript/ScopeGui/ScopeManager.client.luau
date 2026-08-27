--Made by Luckymaxer

wait()

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Player = Players.LocalPlayer
Mouse = Player:GetMouse()

Gui = script.Parent
MainFrame = Gui:WaitForChild("MainFrame")
Scope = MainFrame:WaitForChild("Scope")
LeftFrame = MainFrame:WaitForChild("LeftFrame")
RightFrame = MainFrame:WaitForChild("RightFrame")
Crosshair = MainFrame:WaitForChild("Crosshair")
ZoomPercentLabel = MainFrame:WaitForChild("ZoomPercentLabel")

Tool = Gui:WaitForChild("Tool").Value
ZoomPercent = Gui:WaitForChild("ZoomPercent")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

MainFrame.Visible = false

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function AdjustScreenSize()
	Scope.Position = UDim2.new(0.5, (-10 - (Gui.AbsoluteSize.Y / 2)), 0, -10)
	Scope.Size = UDim2.new(0, (20 + Gui.AbsoluteSize.Y), 0, (30 + Gui.AbsoluteSize.Y), 1, 20)
	LeftFrame.Size = UDim2.new(0, (30 + ((Gui.AbsoluteSize.X - Gui.AbsoluteSize.Y) / 2)), 1, 30)
	RightFrame.Size = UDim2.new(0, (30 + ((Gui.AbsoluteSize.X - Gui.AbsoluteSize.Y) / 2)), 1, 30)
	RightFrame.Position = UDim2.new(1, (-10 - ((Gui.AbsoluteSize.X - Gui.AbsoluteSize.Y) / 2)), 0, -10)
end

function SetSpread(Table)
	local Spread, Speed = Table.Spread, Table.Speed
	if not Spread or not Speed then
		return
	end
	Crosshair:TweenPosition(UDim2.new(0.5, ((1 - (Spread * Gui.AbsoluteSize.Y)) / 2), 0.5, (-18 - ((Spread * Gui.AbsoluteSize.Y)) / 2)), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, Speed, true, (function() end))
	Crosshair:TweenSize(UDim2.new(0, (Spread * Gui.AbsoluteSize.Y), 0, (Spread * Gui.AbsoluteSize.Y)), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, Speed, true, (function() end))
end

function AdjustSpread()
	if not Tool.Enabled then
		SetSpread({Spread = 0.125, Speed = 0.5})
	elseif Tool.Enabled then
		SetSpread({Spread = 0, Speed = 0.25})
	end
end

function AdjustZoomDisplay()
	ZoomPercentLabel.Visible = true
	ZoomPercentLabel.Text = ("Zoom : " .. tostring(ZoomPercent.Value) .. "%")
end

Tool.Changed:connect(function(Property)
	if Property == "Enabled" then
		AdjustSpread()
	end
end)

ZoomPercent.Changed:connect(function()
	AdjustZoomDisplay()
end)

Gui.Changed:connect(function()
	AdjustScreenSize()
end)

RunService.RenderStepped:connect(function()
	local MouseTarget = Mouse.Target
	local EnemyTarget = nil
	local CursorColor = BrickColor.new("Institutional white").Color
	if not Tool.Enabled then
		CursorColor = BrickColor.new("Medium stone grey").Color
	else
		if MouseTarget then
			local character = MouseTarget.Parent
			if character:IsA("Hat") or character:IsA("Tool") then
				character = character.Parent
			end
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local player = Players:GetPlayerFromCharacter(character)
				if not player or (player and player ~= Player and not IsTeamMate(Player, player)) then
					EnemyTarget = character
				end
			end
		end
		if EnemyTarget then
			CursorColor = BrickColor.new("Magenta").Color
		end
	end
	for i, v in pairs(Crosshair:GetChildren()) do
		if v:IsA("Frame") then
			v.BackgroundColor3 = CursorColor
			v.BorderColor3 = CursorColor
		end
	end
end)

AdjustScreenSize()
AdjustZoomDisplay()

MainFrame.Visible = true