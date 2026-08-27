-- Polar Bear Plushie

local Tool = script.Parent
local Handle = Tool.Handle
local running = false

-- Grip info
local gripPos = Tool.GripPos

-- Sound info
local onSqueek = Instance.new("Sound")
onSqueek.SoundId = "http://www.roblox.com/asset/?id=85469102"
onSqueek.Parent = Handle

local happySqueak = Instance.new("Sound")
happySqueak.SoundId = "http://www.roblox.com/asset/?id=85468995"
happySqueak.Parent = Handle

-- Do this when the player clicks
function onActivated()
	if running then return end
	running = true
	local gameCam = game.Workspace.CurrentCamera 
	local oldFoV = gameCam.FieldOfView
	local oldPos = gameCam.CoordinateFrame
	gameCam.CameraSubject = Handle
	onSqueek:Play()
	gameCam.FieldOfView = 20
	gameCam.CoordinateFrame = CFrame.new(Handle.Position + Handle.CFrame.lookVector * 5)


	wait(1.5)
	-- Spawn a sparkly part
	local dummyPart = Instance.new("Part")
	dummyPart.Parent = Workspace
	dummyPart.Position = Handle.Position + Handle.CFrame.lookVector
	 dummyPart.Velocity = Handle.CFrame.lookVector * -40
	dummyPart.Transparency = 1
	dummyPart.Size = dummyPart.Size * 0.03
	local newSparkles = Instance.new("Sparkles")
	newSparkles.Parent = dummyPart

	
	gameCam.FieldOfView = oldFoV
	gameCam.CameraSubject = dummyPart
	gameCam.CoordinateFrame = CFrame.new(Handle.Position + Vector3.new(0,40,0))
	wait(1.5)
	if dummyPart then
		dummyPart:Remove()
	end
	-- Restore old camera info
	gameCam.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
	gameCam.CoordinateFrame = oldPos
	
	local angle = 0

	while angle < math.pi * 2 do
		wait()
		Tool.Grip = Tool.Grip * CFrame.Angles(0, math.rad(30), 0)
		angle = angle + math.rad(30)
	end

	running = false
end

-- Do this when the player uses this item from thebackpack
function onEquipped()
	-- Set the grip position of the Handle so that the bear rests on the arm
	Tool.GripPos = Vector3.new(0, -1, -0.3)
	happySqueak:Play()

end

-- Do this when the player drops the item
function onUnequipped()

end



-- Connect the Activate functionality
script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)