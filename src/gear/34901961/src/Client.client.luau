local Tool = script.Parent

local MouseInput = Tool:WaitForChild("MouseInput",10)

function MouseInput.OnClientInvoke()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end