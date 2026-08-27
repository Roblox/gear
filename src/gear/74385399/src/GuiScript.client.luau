local Tool = script.Parent 
local Lantern = Tool.Handle

local vCharacter 
local vPlayer 

local sg 
local frame 
local genericTextLabel

local CAS = game:GetService("ContextActionService")
local ActionName = "RemoteDetonator"

local RE = Tool:WaitForChild("RemoteEvent")

function onAction(actionName, inputState, inputObject)
	local player = game:GetService("Players").LocalPlayer
	local mouse = player:GetMouse()
	
	if inputState == Enum.UserInputState.Begin then
		RE:FireServer("Activate", mouse.Hit.p)
	end
end

function onEquipped()
	onUnequipped()
	
	CAS:BindActionToInputTypes(
		ActionName,
		onAction,
		false,
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	)
	
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer then 
		local playerGui = vPlayer:FindFirstChild("PlayerGui")
		if playerGui and playerGui:FindFirstChild("LanternGui") == nil then 
			sg = Instance.new("ScreenGui")
			sg.Name = "LanternGui"
			sg.Parent = playerGui 

			frame = Instance.new("Frame")
			frame.Parent = sg 
			frame.Size = UDim2.new(0, 200, 0, 30)
			frame.Position = UDim2.new(0.5, -100, 1, -130) 
			frame.Style = Enum.FrameStyle.RobloxRound

			genericTextLabel = Instance.new("TextLabel")
			genericTextLabel.BackgroundTransparency = 1.0
			genericTextLabel.Size = UDim2.new(1, 0, 1, 0)
			genericTextLabel.Visible = true 
			genericTextLabel.ZIndex = 10 
			genericTextLabel.FontSize = Enum.FontSize.Size10 
			genericTextLabel.Font = Enum.Font.Legacy
			genericTextLabel.TextColor3 = Color3.new(1, 127/255, 0)
			genericTextLabel.TextXAlignment = Enum.TextXAlignment.Center
			genericTextLabel.TextYAlignment = Enum.TextYAlignment.Top
			genericTextLabel.Parent = frame
			genericTextLabel.Text = "Plant the bomb!" 
		end 
	end 
end 

function onUnequipped()
	CAS:UnbindAction(ActionName)
	if sg then sg:Destroy() end 
end 

Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)

local tooFar 

while not Tool:FindFirstChild("TooFar") do 
	wait()
end

tooFar = Tool.TooFar

tooFar.Changed:Connect(function()
	if tooFar and genericTextLabel then
		if tooFar.Value == 1 then 		
			genericTextLabel.Text = "Target too far away"  
			wait(2.0)
			genericTextLabel.Text = "Plant the bomb"
		elseif tooFar.Value == 0 then
			genericTextLabel.Text = "Plant the bomb"
		else 
			genericTextLabel.Text = "Time to detonate" 
		end 			
	end
end) 
