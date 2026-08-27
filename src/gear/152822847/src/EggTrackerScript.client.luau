local Tool = script.Parent 
local Tracker = Tool.Handle

local TrackerGui 
local TrackerFrame 

local Player 
local PlayerGui 

local Character 

local Eggs_Model = Game.Workspace:WaitForChild('SpawnedEggs')  

local ToolTip = Instance.new('TextLabel')
ToolTip.BackgroundTransparency = 0.25
ToolTip.BackgroundColor3 = Color3.new(1, 1, 1)
ToolTip.Size = UDim2.new(0, 140, 0, 20) 
ToolTip.TextColor3 = Color3.new(54/255, 96/255, 191/255)
ToolTip.FontSize = Enum.FontSize.Size18
ToolTip.Font = Enum.Font.ArialBold
ToolTip.Visible = false 

local function CreateTrackerGui()
	local eggsFrame 
	if TrackerFrame and TrackerFrame:FindFirstChild('EggsFrame') then 
		TrackerFrame['EggsFrame']:ClearAllChildren() 
	end
	
	if not TrackerGui then 
		TrackerGui = Instance.new('ScreenGui')
		TrackerGui.Parent = PlayerGui 
		TrackerGui.Name = 'TrackerGui'
		
		local frame = Instance.new('Frame')
		frame.Size = UDim2.new(0, 650, 0, 340) 
		frame.BackgroundTransparency = 1.0
		frame.Position = UDim2.new(0.5, -325, 0.5, -170)
		frame.Name = 'TrackerFrame' 
		frame.Parent = TrackerGui
		
		TrackerFrame = frame 
	
		ToolTip.Parent = TrackerFrame 
		
		local background = Instance.new('ImageLabel')
		background.BackgroundTransparency = 1.0
		background.Name = 'Background' 
		background.Image = "http://www.roblox.com/asset/?id=110700195"
		background.Parent = TrackerFrame 
		background.Size = UDim2.new(1, 0, 1, 0)
		
		eggsFrame = Instance.new('Frame')
		eggsFrame.Parent = TrackerFrame 
		eggsFrame.Name = 'EggsFrame' 
		eggsFrame.BackgroundTransparency = 1.0
		eggsFrame.Size = UDim2.new(1, 0, 1, 0) 
	end 
	
	eggsFrame = eggsFrame or TrackerFrame:FindFirstChild('EggsFrame') 
	local rowNum = 1
	local columnNum = 0
	for _, egg in pairs(Eggs_Model:GetChildren()) do 
		if not eggsFrame:FindFirstChild(egg.Name) then 
			local eImage = Instance.new('ImageLabel') 
			eImage.Size = UDim2.new(0, 64, 0, 64)
			eImage.Parent = eggsFrame 
			eImage.BackgroundTransparency = 1.0
			eImage.Name = egg.Name
			eImage.ZIndex = 5.0
			eImage.Position = UDim2.new(0, 35 + (columnNum * 78), 0, 60 + (rowNum - 1) * 75) 
			eImage.Image = "http://www.roblox.com/asset/?id=" .. egg:WaitForChild('SelectedIcon').Value 
			rowNum = rowNum + 1
			if #eggsFrame:GetChildren()%3 == 0 then 
				columnNum = columnNum + 1
				rowNum = 1
			end 
			
			eImage.MouseEnter:connect(function()
				wait()
				ToolTip.Visible = true 
				ToolTip.Text = eImage.Name 
				ToolTip.Position = eImage.Position + UDim2.new(0, 40, 0, 40)
				ToolTip.ZIndex = 9.0 
			end)
			
			eImage.MouseLeave:connect(function()
				ToolTip.Visible = false 
			end) 
		end 
	end 
end 

local function OnEquipped()
	Character = Tool.Parent 
	Player = Game.Players:GetPlayerFromCharacter(Character) 
	PlayerGui = Player:WaitForChild('PlayerGui') 
	
	if not TrackerGui then 
		CreateTrackerGui() 
	else 
		TrackerGui.Parent = PlayerGui 
	end 
end 

local function OnUnequipped()
	TrackerGui.Parent = nil 
end 

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped) 

Eggs_Model.ChildAdded:connect(function()
	CreateTrackerGui()
end)

Eggs_Model.ChildRemoved:connect(function()
	CreateTrackerGui()
end)