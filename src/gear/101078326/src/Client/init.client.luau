local Tool = script.Parent

local MouseLoc = Tool:WaitForChild("MouseLoc")

function MouseLoc.OnClientInvoke()
	return game:GetService("Players").LocalPlayer:GetMouse().Hit.p
end