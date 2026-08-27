--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

Camera = game:GetService("Workspace").CurrentCamera

ClientControls = Tool:WaitForChild("ClientControls")
ServerControls = Tool:WaitForChild("ServerControls")

ServerControls.OnClientInvoke = (function(Mode, Value)
	if not Humanoid then
		return
	end
	if Mode == "SetCamera" then
		Camera.CameraSubject = Value
	else
		return Humanoid.TargetPoint
	end
end)

function ExecuteControl(Mode, Value)
	pcall(function()
		ClientControls:InvokeServer(Mode, Value)
	end)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	Mouse.Button1Down:connect(function()
		ExecuteControl("Click", true)
	end)
	Mouse.Button1Up:connect(function()
		ExecuteControl("Click", false)
	end)
	Mouse.KeyDown:connect(function(Key)
		ExecuteControl("Key", {Key = Key, Down = true})
	end)
	Mouse.KeyUp:connect(function(Key)
		ExecuteControl("Key", {Key = Key, Down = false})
	end)
end

function Unequipped()
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)