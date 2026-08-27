local function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do wait() end 
	return parent:FindFirstChild(instance)
end 
local vPlayer = game.Players.LocalPlayer
local Tool = script.Parent 
local Sword = Tool.Handle
local Input = (game:FindService("UserInputService") or game:GetService("UserInputService"))
local Remote = (Tool:WaitForChild("WingSlash"))

local RBX_Debris = game:GetService("Debris")

local Animating_Bool = false 

local PlayerGui 
local Wing_Gui 
local Wing_Frame 
local Bar_Frame 

local MouseDown
local MouseUp
local KeyInput

local function createBarGui()
	if PlayerGui then 
		Wing_Gui = Instance.new("ScreenGui")
		Wing_Gui.Name = "WingGui"
		Wing_Gui.Parent = PlayerGui 

		Wing_Frame = Instance.new("Frame")
		Wing_Frame.BackgroundTransparency = 1.0 
		Wing_Frame.Name = "WingFrame"
		Wing_Frame.Style = Enum.FrameStyle.RobloxSquare
		Wing_Frame.Parent = Wing_Gui
		Wing_Frame.Size = UDim2.new(0, 220, 0, 30)
		Wing_Frame.Position = UDim2.new(0.5, -110, 1, -130) 

		Bar_Frame = Instance.new("Frame") 
		Bar_Frame.BackgroundTransparency = 0.0 
		Bar_Frame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.9) 
		Bar_Frame.Parent = Wing_Frame 
		Bar_Frame.Size = UDim2.new(0, 0, 0, 30) 
		Bar_Frame.Position = UDim2.new(0, -8, 0, -8)
		Bar_Frame.Name = "Bar"
	end  
end 

local function onEquipped(mouse)
	PlayerGui = waitForChild(vPlayer, "PlayerGui")
	if not Wing_Gui or not Wing_Gui.Parent then
		createBarGui() 
	end
	local debounce = false
	MouseDown = mouse.Button1Down:Connect(function()
			MouseDown_Bool = true 
			if debounce or not Tool.Enabled then return end
			debounce = true
			while MouseDown_Bool and debounce do
				debounce = true 						
				Bar_Frame.Size = UDim2.new(0,math.min((Bar_Frame.Size.X.Offset +3),220), 0, 30) 
				wait(0.1) 
			end 
	end) 

	MouseUp = mouse.Button1Up:Connect(function()
		if not MouseDown_Bool then return end
		MouseDown_Bool = false 
		--wait(1.5)
		repeat
			wait()
		until
		Tool.Changed:Wait()=="Enabled"			
		Bar_Frame.Size = UDim2.new(0, 0, 0, 30)
		debounce = false
	end)
	
	KeyInput = Input.InputBegan:Connect(function(InputObject,Processed)
		if InputObject.UserInputType == Enum.UserInputType.Keyboard then
			if InputObject.KeyCode == Enum.KeyCode.Q then
				if Remote then
					Remote:InvokeServer(InputObject.KeyCode)
				end
			end
		end
	end) 
	
end 

local function onUnequipped()
	-- Do stuff
	if Wing_Gui and Wing_Gui.Parent then --Fix implemented by Luckymaxer
		Wing_Gui:Destroy()
	end
	MouseDown_Bool = false 
	if MouseDown then MouseDown:Disconnect() end
	if MouseUp then MouseUp:Disconnect() end
	if KeyInput then KeyInput:Disconnect() end
end 

local function onChanged()
	
end

Tool.Changed:Connect(onChanged)

Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)