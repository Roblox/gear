math.randomseed(tick()); math.random()

function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local Tool = script.Parent
local Handle = Tool.Handle

local Mouse

local targetChar

local SoundLengths = {313, 282, 314}
local SoundNames = {"AnnoyingLaugh", "CarAlarm", "Screams"}

local debris = game:GetService("Debris")

local Target = waitForChild(Tool, "TargetedPart")

function annoy()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	if Target.Value then
		targetChar = Target.Value.Parent
		if targetChar:IsA("Accessory") then targetChar = targetChar.Parent end
		Target.Value = nil	-- So that we can hit the same person twice in a row if we want.
		if targetChar:FindFirstChild("Humanoid") then
			targetHead = targetChar:FindFirstChild("Head")
			if targetHead then
				local Megaphone = Handle:Clone()
				Megaphone.CanCollide = false
				Megaphone.Name = "MouthMegaphone"
				Megaphone.Transparency = 0.0	--Just in case
				Megaphone.CFrame = Handle.CFrame

				Handle.Transparency = 1.0
				Megaphone.Parent = game.Workspace
				-- Just in case this script gets destroyed (e.g. if the Tool is lost) before the megaphone gets removed:
				debris:AddItem(Megaphone, 25)

				local deltaPos = targetHead.Position - Megaphone.Position
				while (deltaPos.magnitude > 5) do
					Megaphone.Velocity = 50 * deltaPos.unit
					Megaphone.CFrame = CFrame.new(Megaphone.Position, Megaphone.Position + Megaphone.Velocity) * CFrame.Angles(math.pi/2, math.pi, 0)
					wait()
					deltaPos = targetHead.Position - Megaphone.Position
				end

				tick()

				local randIndex = math.random(1, 3)
				local soundLength = SoundLengths[randIndex]
				local Sound = Megaphone:FindFirstChild(SoundNames[randIndex])

				local Motor = Instance.new("Motor")
				Motor.Part0 = targetHead
				Motor.Part1 = Megaphone
				Motor.C0 = CFrame.new() * CFrame.Angles(math.pi/2, 0, 0)
				Motor.C1 = CFrame.new(0, -deltaPos.magnitude, 0) * CFrame.Angles(math.pi, 0, 0)
				Motor.MaxVelocity = 0.15
				Motor.DesiredAngle = 100	--Just an arbitrary large value, so that it doesn't stop moving.
				local relPos = targetHead.CFrame:pointToObjectSpace(Megaphone.Position)
				if relPos.Z < 0 then 
					Motor.CurrentAngle = -math.atan(relPos.X / relPos.Z)
				else
					Motor.CurrentAngle = math.pi - math.atan(relPos.X / relPos.Z)
				end
				Motor.Parent = Megaphone
				
				if Sound then Sound:Play() end

				for i = 1, soundLength do
					wait()
				end
				
				Megaphone:Destroy()
				Handle.Transparency = 0.0
			end
		end
	end
	Tool.Enabled = true
end

function onUnequipped()
	if Tool.Parent == game.Workspace then
		Handle.Transparency = 0.0
	end
end

Target.Changed:connect(annoy)
Tool.Unequipped:connect(onUnequipped)
