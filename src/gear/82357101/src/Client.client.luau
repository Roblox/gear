local function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do 
		wait()
	end 
	return parent[child]
end 


local Tool = script.Parent 
local Prison = Tool.Handle

local vCharacter
local vTorso
local vHumanoid

local vPlayer
local PlayerGui

local Help_Gui 
local Help_Frame
local Help_TextLabel 

local LockSound 

local Prison_Anim 

local Mouse 

Tool.Enabled = true

local function onActivated()
	if not Tool.Enabled then
		return 
	end 

	Tool.Enabled = false 
	--print(Mouse)
	
	if Mouse and Mouse.Target then
		local ePart = Mouse.Target 
		local distance = (vTorso.Position - ePart.Position).magnitude
		if distance < 15 then 			
			if Mouse.Target.Parent then 
				Prison_Anim = vHumanoid:LoadAnimation(Tool:FindFirstChild("PrisonAnim".. vHumanoid.RigType.Name))
				if Prison_Anim then Prison_Anim:Play() end 
				wait(0.25)
				local enemyCharacter = Mouse.Target.Parent 
				local enemyHumanoid = enemyCharacter:FindFirstChildOfClass("Humanoid") 
				if enemyHumanoid and not enemyCharacter:FindFirstChild("PrisonScript") then 
					--Send Remote to Server
					local MouseClick = Tool:FindFirstChildOfClass("RemoteEvent")
					if MouseClick then
						MouseClick:FireServer(enemyCharacter)
					end

				end 
			end
		else 
			spawn(function() 
				Help_TextLabel.Text = "Too far!" 
				wait(1.5)
				Help_TextLabel.Text = "Trap others with your portacell!" 
			end) 
		end 
	end  

	wait(2.0)
	Prison.Transparency = 0.0
	Tool.Enabled = true 
end 

local function onEquipped(mouse)
	vCharacter = Tool.Parent 
	vTorso = vCharacter:FindFirstChild("HumanoidRootPart")
	vHumanoid = vCharacter:FindFirstChildOfClass("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	PlayerGui = waitForChild(vPlayer, "PlayerGui")
	Mouse = mouse 

	if not Help_Gui then 
		Help_Gui = Instance.new("ScreenGui")
		Help_Gui.Parent = PlayerGui 
		Help_Gui.Name = "HelpGui"
 
		Help_Frame = Instance.new("Frame")
		Help_Frame.Name = "Help Frame"
		Help_Frame.Size = UDim2.new(0, 250, 0, 50) 
		Help_Frame.Position = UDim2.new(0.5, -125, 1, -130)
		Help_Frame.Style = Enum.FrameStyle.RobloxSquare
		Help_Frame.Parent = Help_Gui 
		Help_Frame.BackgroundTransparency = 1.0  		

		Help_TextLabel = Instance.new("TextLabel") 
		Help_TextLabel.Name = "Help Text" 
		Help_TextLabel.Size = UDim2.new(1, 0, 1, 0) 
		Help_TextLabel.Position = UDim2.new(0, 0, 0, 0)
		Help_TextLabel.Parent = Help_Frame 
		Help_TextLabel.BackgroundTransparency = 1.0 
		Help_TextLabel.Text = "Trap others with your portacell!" 
		Help_TextLabel.TextColor3 = Color3.new(1, 1, 1)
		Help_TextLabel.FontSize = Enum.FontSize.Size12
	else 
		Help_Gui.Parent = PlayerGui 
	end 
end 

local function onUnequipped()
	if LockSound then LockSound:Play() end
	if Help_Gui then 
		Help_Gui.Parent = nil 
	end 
	if Prison_Anim then 
		Prison_Anim:Stop() 
	end 
end 

Tool.Activated:Connect(onActivated)
Tool.Equipped:Connect(onEquipped) 
Tool.Unequipped:Connect(onUnequipped)