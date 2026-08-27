local MyCharacter = script.Parent

if MyCharacter and MyCharacter:FindFirstChild('Humanoid') then
	local humanoid = MyCharacter.Humanoid
	local origSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	wait(0.8)
	humanoid.WalkSpeed = origSpeed
end

script:Destroy()
