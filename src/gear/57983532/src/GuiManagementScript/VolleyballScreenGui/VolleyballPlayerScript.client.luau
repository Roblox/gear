function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local ScreenGui = script.Parent
local Frame = waitForChild(ScreenGui, "Frame")
local HitButton = waitForChild(Frame, "HitButton")
local NoButton = waitForChild(Frame, "NoButton")
local YesButton = waitForChild(Frame, "YesButton")
local AskingLabel = waitForChild(Frame, "AskingLabel")

local myPlayer
local WantsToPlayBool = Instance.new("BoolValue")
WantsToPlayBool.Name = "WantsToPlayVolleyball"
local myCharacter
local myHumanoid
local LeftArm

local debris = game:GetService("Debris")

local HitAnim

function noise()
	return 2 * (Vector3.new(math.random(), math.random(), math.random()) - Vector3.new(0.5, 0.5, 0.5))
end	

function tryToHitVolleyball()
	myPlayer = ScreenGui.Parent.Parent
	if not myPlayer then return end
	myCharacter = myPlayer.Character
	if myCharacter then
		LeftArm = myCharacter:FindFirstChild("Left Arm")
		Torso = myCharacter:FindFirstChild("Torso")
		myHumanoid = myCharacter:FindFirstChild("Humanoid")
		if LeftArm and Torso and myHumanoid then
			HitAnim = ScreenGui:FindFirstChild("VolleyballHit")
			if HitAnim then
				HitAnim = myHumanoid:LoadAnimation(HitAnim)
				HitAnim:Play()
			end
			local nearbyParts = game.Workspace:FindPartsInRegion3(Region3.new(Torso.Position - Vector3.new(7, 7, 7), Torso.Position + Vector3.new(7, 7, 7)), myCharacter, 50)
			for index, part in pairs(nearbyParts) do
				if part.Name == "Volleyball" and part:FindFirstChild("LastHitTime") and part.LastHitTime.ClassName == "NumberValue" then
					local lookVector = Torso.CFrame.lookVector
					part.Velocity = 60 * lookVector + Vector3.new(0, 70, 0) + 10 * noise()
					local LastHitTime = part:FindFirstChild("LastHitTime")
					if LastHitTime then LastHitTime.Value = tick() end
					if part:FindFirstChild("HitSound") then part.HitSound:Play() end
				end
			end
		end
	end
end

function wantsToPlay()
	myPlayer = ScreenGui.Parent.Parent	--Yuck
	WantsToPlayBool.Value = true
	WantsToPlayBool.Parent = myPlayer

	AskingLabel.Visible = false
	NoButton.Visible = false
	YesButton.Visible = false
	HitButton.Visible = true

	HitButton.MouseButton1Click:connect(tryToHitVolleyball)
end

function doesntWantToPlay()
	myPlayer = ScreenGui.Parent.Parent	--EEEEWWWWWWWW
	WantsToPlayBool.Value = false
	WantsToPlayBool.Parent = myPlayer
	ScreenGui:Remove()
end
	
myPlayer = ScreenGui.Parent.Parent
if myPlayer:FindFirstChild("WantsToPlayVolleyball") then
	wantsToPlay()
else
	NoButton.MouseButton1Click:connect(doesntWantToPlay)
	YesButton.MouseButton1Click:connect(wantsToPlay)
end
