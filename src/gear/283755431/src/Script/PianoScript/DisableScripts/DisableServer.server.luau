--Made by Luckymaxer

DisableScript = script.Parent

Character = DisableScript.Parent
Humanoid = Character:WaitForChild("Humanoid")

DisableJump = Humanoid.Changed:connect(function(Property)
	if Property == "Jump" then
		Humanoid.Jump = false
	end
end)