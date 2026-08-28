local Tool = script.Parent

local MouseInput = Tool:WaitForChild("MousePos",10)

function MouseInput.OnClientInvoke()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end