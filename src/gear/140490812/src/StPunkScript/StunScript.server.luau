local MyCharacter = script.Parent
local Humanoid = MyCharacter:FindFirstChild('Humanoid')

if MyCharacter and Humanoid then
	local origSpeed = Humanoid.WalkSpeed
	Humanoid.WalkSpeed = 0
	wait(0.75)
	Humanoid.WalkSpeed = origSpeed
end

script:Destroy()
script.Parent = nil
