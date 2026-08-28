local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerMouse = Player:GetMouse()

local Tool = script.Parent

local Remotes = Tool:WaitForChild("Remotes")
local RemoteFunction = Remotes:WaitForChild("RemoteFunction")

function RemoteFunction.OnClientInvoke(mode, ...)
	if mode == "GetMousePosition" then 
		return PlayerMouse.Hit
	end
end