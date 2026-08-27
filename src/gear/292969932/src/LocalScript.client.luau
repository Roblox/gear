--By Rukiryo

repeat wait() until game.Players.LocalPlayer ~= nil

local player = game.Players.LocalPlayer
local char = player.Character
local mouse = player:GetMouse()

mouse.Button1Down:connect(function()
	if script.Parent.Parent:IsA("Model") then
		if char["Right Arm"]:findFirstChild("RightGrip") ~= nil then
			script.Parent.Handle.RemoteEvent:FireServer({"drop"})
		end
	end
end)
