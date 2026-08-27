-- // Recreated by StarWars
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local PlayerGui = Player:WaitForChild("PlayerGui")

local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local PaintSound = Handle:WaitForChild("PaintSound")
local PaletteGui = script:WaitForChild("PaletteGui")

local Remotes = Tool:WaitForChild("Remotes")
local ServerControls = Remotes:WaitForChild("ServerControls")

local ColorSelection = BrickColor.new("White").Color

local CurrentGui = nil
local SelectionBox = Instance.new("SelectionBox")
SelectionBox.Color3 = ColorSelection
SelectionBox.Parent = PlayerGui

local LineHandle = Instance.new("LineHandleAdornment")
LineHandle.Color3 = ColorSelection
LineHandle.Thickness = 5
LineHandle.Parent = PlayerGui

local ToolEquipped = false
local InPalette = false

local function SetupGui()
	if CurrentGui then
		CurrentGui:Destroy()
	end	
	
	CurrentGui = PaletteGui:Clone()
	local Palette = CurrentGui:WaitForChild("ColorPallet")	
	local ColorTitle = Palette:WaitForChild("ColorTitle")
	
	Palette.MouseEnter:Connect(function()
		Mouse.Icon = ""
		InPalette = true
	end)
	
	Palette.MouseLeave:Connect(function()
		InPalette = false
	end)
	
	for _, button in next, Palette:GetChildren() do
		if button:IsA("GuiButton") then
			button.MouseButton1Click:Connect(function()
				ColorSelection = BrickColor.new(button.Name).Color
				ColorTitle.Text = button.Name
				SelectionBox.Color3 = ColorSelection
				LineHandle.Color3 = ColorSelection
				ColorTitle:WaitForChild("ColorFrame").BackgroundColor3 = ColorSelection
			end)
		end
	end
	
	CurrentGui.Parent = PlayerGui
end

local function UpdateSelectionBox()
	if Mouse and Mouse.Target and SelectionBox then
		SelectionBox.Adornee = Mouse.Target
		if LineHandle and Player.Character then
			LineHandle.Adornee = Player.Character.PrimaryPart
			local OffsetTargetPosition = Player.Character.PrimaryPart.CFrame:pointToObjectSpace(Mouse.Hit.p)
			LineHandle.CFrame = CFrame.new(LineHandle.CFrame.p, OffsetTargetPosition)
			LineHandle.Length = (Mouse.Target.CFrame.p - Player.Character.PrimaryPart.CFrame.p).Magnitude
		end
	end
end

Tool.Equipped:Connect(function(mouse)
	if ToolEquipped then return end 
	
	ColorSelection = BrickColor.new("White").Color
	ToolEquipped = true
	mouse.Button1Up:Connect(function()
		if ColorSelection then
			local Data = {Part = mouse.Target, Color = ColorSelection}
			ServerControls:InvokeServer("PaintPart", Data)
			PaintSound:Play()
			PaintSound.PlaybackSpeed = 0.9 + (math.random() * .1)
		end		
	end)
	mouse.Move:Connect(function()
		if CurrentGui and not InPalette then
			mouse.Icon = "rbxasset://textures\\FillCursor.png"
		end
	end)
	
	SelectionBox.Color3 = ColorSelection
	LineHandle.Color3 = ColorSelection
		
	RunService:BindToRenderStep("UpdateSelectionBox", Enum.RenderPriority.Input.Value, UpdateSelectionBox)	
	SetupGui()
end)

Tool.Unequipped:Connect(function()
	if not ToolEquipped then return end 
	ToolEquipped = false
	if CurrentGui then
		CurrentGui:Destroy()
	end
	
	RunService:UnbindFromRenderStep("UpdateSelectionBox")
	if SelectionBox then
		SelectionBox.Adornee = nil
	end
	if LineHandle then
		LineHandle.Adornee = nil
	end

	InPalette = false
	CurrentGui = nil
	Mouse.Icon = ""
end)