local Tool = script.Parent 
local Hand = Tool.Handle

local vCharacter 
local myHumanoid 
local myTorso 
local vPlayer 
local myRightArm 

local otherHumanoid 

Tool.Enabled = true 

local highFiveAnim 
local otherHighFiveAnim 

local AOE = Vector3.new(5, 5, 5)

local clapSound

local sg 
local frame 
local genericTextLabel

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 

	local parts = game.Workspace:FindPartsInRegion3(Region3.new(myTorso.Position - AOE, myTorso.Position + AOE), vCharacter, 100)
	for i = 1, #parts do 
		if parts[i] and parts[i].Parent then 
			local humanoid = parts[i].Parent:FindFirstChild("Humanoid")
			if humanoid then 
				otherHumanoid = humanoid 
				break 
			end 
		end 
	end 
	
	if otherHumanoid then 
		local otherTorso = otherHumanoid.Parent:FindFirstChild("Torso")
		if otherTorso and myRightArm then 
			otherTorso.CFrame = CFrame.new(myRightArm.Position + myTorso.CFrame.lookVector * 3, myRightArm.Position)
		end 
		highFiveAnim = myHumanoid:LoadAnimation(Tool.HighFiveAnim)		
		otherFiveAnim = otherHumanoid:LoadAnimation(Tool.OtherFiveAnim)		
		myHumanoid.WalkSpeed = 0.0		
		otherHumanoid.WalkSpeed = 0.0
		if highFiveAnim then highFiveAnim:Play() end		
		if game.Players:GetPlayerFromCharacter(otherHumanoid.Parent) then 
			local animScript = Tool.AnimateScript:Clone() 
			animScript.Parent = otherHumanoid.Parent 
			animScript.Disabled = false 
		else 
			print("Playing other anim")
			if otherFiveAnim then otherFiveAnim:Play() end
		end 

		local duration = 0.95 
		local clapSound = Hand:FindFirstChild("ClapSound")
		if clapSound then clapSound:Play() end 
		while duration > 0 do 
			if duration > 0.6 then
				otherTorso.CFrame = (otherTorso.CFrame + otherTorso.CFrame.lookVector * 0.06) * CFrame.Angles(0, math.pi/90, 0)
			else
				otherTorso.CFrame = (otherTorso.CFrame + otherTorso.CFrame.lookVector * 0.06) * CFrame.Angles(0, math.pi/15, 0)
			end 
			duration = duration - wait()
			wait()
		end 
		myHumanoid.WalkSpeed = 16.0
		otherHumanoid.WalkSpeed = 16.0
	end 

	wait(2.0)
	otherHumanoid = nil
	Tool.Enabled = true 
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myRightArm = vCharacter:FindFirstChild("Right Arm")

	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if vPlayer then 
		local playerGui = vPlayer:FindFirstChild("PlayerGui")
		if playerGui and playerGui:FindFirstChild("HighFiveGui") == nil then 
			sg = Instance.new("ScreenGui")
			sg.Name = "HighFiveGui"
			sg.Parent = playerGui 

			frame = Instance.new("Frame")
			frame.Parent = sg 
			frame.Size = UDim2.new(0, 270, 0, 30)
			frame.Position = UDim2.new(0.5, -135, 1, -130) 
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
			genericTextLabel.Text = "Get close to your friends and active the hand!" 
		end 
	end 
end 

function onUnequipped()
	if highFiveAnim then highFiveAnim:Stop() end 
	if otherHighFiveAnim then otherHighFiveAnim:Stop() end 
	if otherHumanoid and otherHumanoid.WalkSpeed == 0.0 then 
		otherHumanoid.WalkSpeed = 16.0 	
		otherHumanoid = nil 
	end 
	if clapSound then clapSound:Stop() end
	if sg then sg:Destroy() end 
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)


