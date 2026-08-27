--[[
	By ArceusInator
--]]
local Tool = script.Parent
local UIS = game:GetService'UserInputService'

local InputBeganConnection, InputEndedConnection
local Equipped = false

Tool.Equipped:connect(function()
	if Equipped then return end
	Equipped = true
	
	InputBeganConnection = UIS.InputBegan:connect(function(input)
		Tool.Input.RemoteInput:FireServer(input.UserInputType, input.UserInputState, input.KeyCode)
	end)
	InputEndedConnection = UIS.InputEnded:connect(function(input)
		Tool.Input.RemoteInput:FireServer(input.UserInputType, input.UserInputState, input.KeyCode)
	end)
end)

Tool.Unequipped:connect(function()
	if not Equipped then return end
	Equipped = false
	
	if InputBeganConnection then InputBeganConnection:disconnect() InputBeganConnection=nil end
	if InputEndedConnection then InputEndedConnection:disconnect() InputEndedConnection=nil end
end)