Tool = script.Parent
local GLib = require(Tool:WaitForChild'GLib')
Swing = Tool:WaitForChild("Swing")
ReloadTime = 2

function Activated()
	local Character, Player, Humanoid = GLib.GetCharacter(Tool)
	local Torso = Humanoid.Torso
	
	if Tool.Enabled and Player and Humanoid and Humanoid.Health > 0 and Torso then
		Tool.Enabled = false
		SwingAnim = Humanoid:LoadAnimation(Swing)
		if SwingAnim then
			SwingAnim:Play()
		end
		Tool.ActivatedRemote:FireServer()
		wait(0.4)
		if SwingAnim then
			SwingAnim:Stop()
		end
		wait(ReloadTime)
		Tool.Enabled = true
	end
end
function Unequipped()
	if SwingAnim then
		SwingAnim:Stop()
	end
end

Tool.Activated:connect(Activated)
Tool.Unequipped:connect(Unequipped)