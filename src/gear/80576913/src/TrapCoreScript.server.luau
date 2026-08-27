local Tool = script.Parent
local Trap = Tool.Handle

Tool.Enabled = true

local vCharacter
local vPlayer
local numberOfTraps 
local screenGui
local buzzer 

local myTorso
local myHumanoid 

local trapCFrame = CFrame.new()

function checkTrap(trap)	
	if trap and trap.Parent == nil then 
		numberOfTraps = Tool:FindFirstChild("NumberOfTraps")
		if numberOfTraps and numberOfTraps.Value < 12 then numberOfTraps.Value = numberOfTraps.Value + 1 end 
	end
end

function onActivated()	
	if not Tool.Enabled then return end
	numberOfTraps = Tool:FindFirstChild("NumberOfTraps")
	if numberOfTraps then
		if numberOfTraps.Value <= 0 then 
			buzzer = Tool:FindFirstChild("NoTrapsBuzzer")
			if buzzer then buzzer:Play() end
		return end
	end	
	numberOfTraps.Value = numberOfTraps.Value - 1	
	Tool.Enabled = false	
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if not myTorso or not myHumanoid then return end
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if not vPlayer then return end

	local fire = Trap:FindFirstChild("Fire")
	if fire then fire.Enabled = false end
	
	local clonedTrap = Trap:Clone()
	
	bodyGyro = Instance.new("BodyGyro")	
	bodyGyro.P = 10000
	bodyGyro.maxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)	
	--bodyGyro.cframe = (myTorso.CFrame + (myTorso.CFrame.lookVector * 2.0)) * CFrame.Angles(-math.pi/2, 0, 0)
	bodyGyro.cframe = trapCFrame
	bodyGyro.Parent = clonedTrap

	clonedTrap.Parent = Workspace
	clonedTrap.CanCollide = true
	clonedTrap.Mesh.Scale = Vector3.new(.4,.4,.4)
	Trap.Transparency = 1.0
	
	local cloneScript = Tool.TrapScript:Clone()
	cloneScript.Parent = clonedTrap
	
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = vPlayer 
	creatorTag.Name = "creator"
	creatorTag.Parent = cloneScript 

	cloneScript.Disabled = false	

	wait(0.25)	
	clonedTrap.AncestryChanged:connect(function() checkTrap(clonedTrap) end)
	wait(4.5)
	if fire then fire.Enabled = false end
	Trap.Transparency = 0.0
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent  
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	numberOfTraps = Tool:FindFirstChild("NumberOfTraps")	
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TrapsGui"
	if vPlayer then
		screenGui.Parent = vPlayer.PlayerGui
	end	

	frame = Instance.new("Frame")
	frame.Name = "TrapContainer"
	frame.Position = UDim2.new(0, 0, 0.75, 0)
	frame.Size = UDim2.new(0, 75, 0, 75)
	frame.Parent = screenGui
	frame.BackgroundTransparency = 1.0

	image = Instance.new("ImageLabel")
	image.Name = "Trap"
	image.Image = "http://www.roblox.com/asset/?id=63216452"
	image.Parent = frame
	image.Size = UDim2.new(0, 75, 0, 75)
	image.BackgroundTransparency = 1.0

	text = Instance.new("TextLabel")
	text.Text = numberOfTraps.Value

	numberOfTraps.Changed:connect(function() text.Text = numberOfTraps.Value end)
	text.Position = UDim2.new(0.75, 0, 0.75, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.Parent = frame
	text.BackgroundTransparency = 1.0
	text.TextColor = BrickColor.new("Deep orange")
	text.FontSize = 7	
end

function onUnequipped()
	Trap.Transparency = 0.0
	if screenGui then screenGui:Destroy() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
