local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Character = script.Parent
local Humanoid = Character:FindFirstChild("Humanoid")

local Controller = script:WaitForChild("Controller")

function DestroyScript()
	if DisableJump then
		DisableJump:Disconnect()
	end
	Debris:AddItem(script, 1)
end

if not Controller or not Controller.Value or not Humanoid or Humanoid.Health == 0 then
	DestroyScript()
	return
end

Controller = Controller.Value

Controller.Changed:Connect(function(Property)
	if not Controller or not Controller.Parent or not Controller.Parent.Parent then
		DestroyScript()
	end
end)

DisableJump = Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
	Humanoid.Jump = false
end)