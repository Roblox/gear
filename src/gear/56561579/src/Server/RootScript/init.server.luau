local vCharacter = script.Parent

local myHumanoid = vCharacter:FindFirstChildOfClass("Humanoid")

local myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")

local Smoke = script:WaitForChild("Smoke",10)

if vCharacter and myHumanoid and myTorso then
	myHumanoid.WalkSpeed = 0.0
	sparkle = Smoke:Clone()
	sparkle.Parent = myTorso
	sparkle.Enabled = true
	wait(3)	
	if sparkle then sparkle:Destroy() end
	myHumanoid.WalkSpeed = 16
end

wait(2)
script:Destroy() 

