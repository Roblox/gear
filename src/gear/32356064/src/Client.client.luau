--Rescripted by TakeoHonorable

local Tool = script.Parent

local MouseLoc = Tool:WaitForChild("MouseLoc",10)

function MouseLoc.OnClientInvoke()
	return game:GetService("Players").LocalPlayer:GetMouse().Hit.p
end