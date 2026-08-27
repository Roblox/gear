--Made by Luckymaxer

Humanoid = script.Parent

Humanoid.PlatformStand = true
Humanoid.AutoRotate = false

Humanoid.Changed:connect(function(Property)
	if Property == "Jump" then
		Humanoid.Jump = false
	elseif Property == "PlatformStand" then
		Humanoid.PlatformStand = true
	elseif Property == "AutoRotate" then
		Humanoid.AutoRotate = false
	end
end)