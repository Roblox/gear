local Tool = script.Parent
local blow = nil

local sound = Instance.new("Sound")
sound.Parent  = Tool.Handle
local sounds = {"29029134","29029143","29029154","29029170","29029176"}
sound.Volume = 0.01

local Animations = Tool:WaitForChild("Animations")
local R6Folder = Animations:WaitForChild("R6")
local R15Folder = Animations:WaitForChild("R15")

for i = 1, #sounds do
	sound.SoundId = "http://www.roblox.com/asset/?id=" .. sounds[i]
	sound:Play()	
end

sound:Stop()
sound.Volume = 0.5

function onEquipped()
	sound:Stop()
	local Humanoid = Tool.Parent:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			blow = Humanoid:LoadAnimation(R15Folder:WaitForChild("hornblow"))
		else
			blow = Humanoid:LoadAnimation(R6Folder:WaitForChild("hornblow"))
		end
	end
end

function onUnequipped()
	if blow then
		blow:Stop()
		blow:Destroy()
	end
	blow = nil	
	sound:Stop()
end

local enabled = false

function onActivated()

	if enabled then
		return
	end

	enabled = true

	if blow then
		blow:Play()
	end
	sound.SoundId = "http://www.roblox.com/asset/?id=" .. sounds[math.random(1,#sounds)]
	sound.Pitch = math.random(0.7,1)
	sound:Play()

	wait(1)

	enabled = false

end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)