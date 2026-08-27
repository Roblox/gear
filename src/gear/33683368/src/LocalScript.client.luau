local Tool = script.Parent
local blow = nil

local sound = Instance.new("Sound")
sound.Parent  = Tool.Handle
local sounds = {"32727625","32727646","32727664","32727673"}
sound.Volume = 0.01

for i = 1, #sounds do
	sound.SoundId = "http://www.roblox.com/asset/?id=" .. sounds[i]
	sound:Play()	
end

sound:Stop()
sound.Volume = 0.6

local humanoid = nil

local Animations = {
	Hornblow = Tool:WaitForChild("hornblow");
	R15Hornblow = Tool:WaitForChild("R15Hornblow")
}

function onEquipped()
	humanoid = Tool.Parent:FindFirstChildOfClass("Humanoid")	
	
	sound:Stop()
	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			blow = Tool.Parent:FindFirstChild("Humanoid"):LoadAnimation(Animations.R15Hornblow)
		else
			blow = Tool.Parent:FindFirstChild("Humanoid"):LoadAnimation(Animations.Hornblow)
		end
	end
end

function unEquipped()
	if blow then
		blow:Destroy()
	end
	sound:Stop()
end

local enabled = false

function onActivated()

	if enabled then
		return
	end

	enabled = true

	if blow then
		blow:Play(0.1,1,0.9)
	end
	Tool.GripForward = Vector3.new(1,0,0)
	Tool.GripPos = Vector3.new(0.3,0.2,-0.2)
	Tool.GripRight = Vector3.new(0,0,-1)
	sound.SoundId = "http://www.roblox.com/asset/?id=" .. sounds[math.random(1,#sounds)]
	sound.Pitch = math.random(0.7,1)
	sound:Play()

	wait(2.3)

	Tool.GripForward = Vector3.new(0,0,-1)
	Tool.GripPos = Vector3.new(-0.05, 0.12, 0.37)
	Tool.GripRight = Vector3.new(1, 0, 0)

	enabled = false

end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(unEquipped)

