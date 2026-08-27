--Fixed by Luckymaxer

local MyCharacter = script.Parent
local MyHumanoid = MyCharacter:FindFirstChild("Humanoid")
local MyTorso = MyCharacter:FindFirstChild("Torso")

if MyTorso and MyHumanoid then
	MyTorso.Anchored = true
	MyHumanoid.WalkSpeed = 0
	wait(2.5)
	if MyHumanoid.Health > 0 then
		MyTorso.Anchored = false
		MyHumanoid.WalkSpeed = 16
	end
end

script:Destroy()
