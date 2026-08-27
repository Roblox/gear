local MyCharacter = script.Parent

if MyCharacter and MyCharacter:FindFirstChild('Humanoid') then
	local humanoid = MyCharacter.Humanoid
	local origSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	wait(2)
	humanoid.WalkSpeed = origSpeed
end

script:Destroy()
