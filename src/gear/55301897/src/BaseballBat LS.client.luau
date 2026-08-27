-- Baseball bat. No damage, so it can be used for non-violent games. Though the giant baseballs can still kill you
--   by knocking you off the stage.
-- Code for number-of-baseballs-used GUI modeled on / copied from the one for ClamTrap (Seashell Snare).

local Tool = script.Parent

local SwingAnim
local SwingSound

local myCharacter
local myHumanoid
local myPlayer
local LeftArm
local RightArm
local Torso

local isBaseballisticObj
local baseballisticScript

local screenGui
local frame
local image
local text
local baseballsRemaining

local Baseball = Instance.new("Part")
Baseball.Name = "Baseball"
Baseball.formFactor = 3	--Custom
Baseball.Size = Vector3.new(0.3, 0.3, 0.3)
Baseball.Shape = Enum.PartType.Ball
Baseball.Material = "Grass"
Baseball.Locked = true

local BaseballMesh = Instance.new("SpecialMesh")
BaseballMesh.MeshId = "http://www.roblox.com/asset/?id=55021861"
BaseballMesh.TextureId = "http://www.roblox.com/asset/?id=55021914"
BaseballMesh.Parent = Baseball

local BaseballForce = Instance.new("BodyForce")
BaseballForce.force = Vector3.new(0, Baseball:GetMass() * 1400, 0)
BaseballForce.Name = "Baseball Force"

Tool.Enabled = true

function startSpecial(key)
	isBaseballisticObj = Tool:FindFirstChild("IsBaseballistic")
	if isBaseballisticObj then
		if key:lower() == "x" and Tool.Enabled and not isBaseballisticObj.Value then
			baseballsRemaining = Tool:FindFirstChild("BaseballsRemaining")
			if baseballsRemaining then
				baseballisticScript = Tool:FindFirstChild("BaseballisticScript")
				if baseballisticScript ~= nil and baseballsRemaining.Value > 0 then
					Tool.Enabled = false
					isBaseballisticObj.Value = true
					baseballisticScript = baseballisticScript:Clone()
					baseballisticScript.Name = "NewBaseballisticScript"
					baseballisticScript.Parent = Tool
					baseballisticScript.Disabled = false
				end
			end
		end
	end
end

function onActivated()
	-- A few necessary checks
	if not Tool.Enabled then return end
	isBaseballisticObj = Tool:FindFirstChild("IsBaseballistic")
	myCharacter = Tool.Parent
	if not myCharacter then return end
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	Torso = myCharacter:FindFirstChild("Torso")
	LeftArm = myCharacter:FindFirstChild("Left Arm")
	RightArm = myCharacter:FindFirstChild("Right Arm")
	if not (myHumanoid and Torso and LeftArm and RightArm) then return end

	-- Now on to the action.
	Tool.Enabled = false
	SwingSound = Tool:FindFirstChild("BatCrack")
	SwingAnim = myHumanoid:LoadAnimation(Tool:FindFirstChild("BaseballSwing"))
	if SwingAnim then SwingAnim:Play() end

	local Ball = Baseball:Clone()
	Ball.Parent = game.Workspace
	Ball.CanCollide = false

	local BallWeld = Instance.new("Weld")
	BallWeld.Name = "Baseball Weld"
	BallWeld.Part0 = LeftArm
	BallWeld.Part1 = Ball
	BallWeld.C1 = CFrame.new(Vector3.new(0, 1, 0))
	BallWeld.Parent = game.Workspace

	wait (0.7)
	BallWeld:Remove()
	
	local BallForce = BaseballForce:Clone()
	BallForce.Parent = Ball
	wait()
	BallForce:Remove()

	wait(0.27)
	if SwingSound then SwingSound:Play() end	--SwingSound has .13 secs of silence before really getting to the crack sound,
	wait(0.13)											--  so we have to play it early.
	Ball:Remove()
	
	local ProjectileScript = Tool:FindFirstChild("Projectile Script")
	if ProjectileScript then
		ProjectileScript = ProjectileScript:Clone()
		ProjectileScript.Parent = Tool
		ProjectileScript.Disabled = false
	end
	wait(0.2)
	
	
	Tool.Enabled = true	
end

function onEquipped(mouse)
	if mouse then mouse.KeyDown:connect(startSpecial) end

	myCharacter = Tool.Parent
	if not myCharacter then return end
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	if not myPlayer then return end

	-- Set up GUI displaying number of giant baseballs remaining for use.
	baseballsRemaining = Tool:FindFirstChild("BaseballsRemaining")
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BaseballsGui"
	screenGui.Parent = myPlayer.PlayerGui

	frame = Instance.new("Frame")
	frame.Name = "BaseballContainer"
	frame.Position = UDim2.new(0, 0, 0.75, 0)
	frame.Size = UDim2.new(0, 75, 0, 75)
	frame.Parent = screenGui
	frame.BackgroundTransparency = 1.0

	image = Instance.new("ImageLabel")
	image.Name = "Baseball"
	image.Image = "http://www.roblox.com/asset/?id=55120856"
	image.Parent = frame
	image.Position = UDim2.new(0, 2.5, 0, 2.5)
	image.Size = UDim2.new(0, 70, 0, 70)
	image.BackgroundTransparency = 1.0

	text = Instance.new("TextLabel")
	text.Text = baseballsRemaining.Value
	if baseballsRemaining then
		baseballsRemaining.Changed:connect(function() text.Text = baseballsRemaining.Value end)
	end
	text.Position = UDim2.new(0.75, 0, 0.75, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.Parent = frame
	text.BackgroundTransparency = 1.0
	text.TextColor = BrickColor.new("Bright red")
	text.FontSize = 7
end

function onUnequipped()
	if SwingAnim then SwingAnim:Stop() end
	if SwingSound then SwingSound:Stop() end

	if screenGui then screenGui.Parent = nil end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

