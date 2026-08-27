--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Controller = script:WaitForChild("Controller")

function DestroyScript()
	if DisableJump then
		DisableJump:disconnect()
	end
	Debris:AddItem(script, 1)
end

if not Controller or not Controller.Value or not Humanoid or Humanoid.Health == 0 then
	DestroyScript()
	return
end

Controller = Controller.Value

Controller.Changed:connect(function(Property)
	if not Controller or not Controller.Parent or not Controller.Parent.Parent then
		DestroyScript()
	end
end)

DisableJump = Humanoid.Changed:connect(function(Property)
	if Property == "Jump" then
		Humanoid.Jump = false
	end
end)