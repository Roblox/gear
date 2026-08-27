local Tool = script.Parent

local Remote = Tool:WaitForChild("MouseLoc")

function Remote.OnClientInvoke()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end