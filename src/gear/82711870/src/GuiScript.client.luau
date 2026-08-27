local Tool = script.Parent 
local Lantern = Tool.Handle

local vCharacter 
local vPlayer 

local sg 
local frame 

function onEquipped()
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
			frame.Size = UDim2.new(0, 220, 0, 30)
			frame.Position = UDim2.new(0.5, -110, 1, -130) 
			frame.Style = Enum.FrameStyle.RobloxRound

			local genericTextLabel = Instance.new("TextLabel")
			genericTextLabel.BackgroundTransparency = 1.0
			genericTextLabel.Size = UDim2.new(1, 0, 1, 0)
			genericTextLabel.Visible = true 
			genericTextLabel.ZIndex = 10 
			genericTextLabel.FontSize = Enum.FontSize.Size10 
			genericTextLabel.Font = Enum.Font.Legacy
			genericTextLabel.TextColor3 = Color3.new(105/255, 89/255, 205/255)
			genericTextLabel.TextXAlignment = Enum.TextXAlignment.Center
			genericTextLabel.TextYAlignment = Enum.TextYAlignment.Top
			genericTextLabel.Parent = frame
			genericTextLabel.Text = "Summon the Snarffle!" 
		end 
	end 
end 

function onUnequipped()
	if sg then sg:Remove() end 
end 

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

while true do 
	if vCharacter and genericTextLabel then 
		if vCharacter:FindFirstChild("MonkeyAIScript") then 
			genericTextLabel.Text = "Command him onto your enemies!" 
		else 
			genericTextLabel.Text = "Summon the Monkey!" 
		end 
	end 
	wait()
end 
