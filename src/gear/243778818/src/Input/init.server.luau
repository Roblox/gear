--[[
	By ArceusInator
--]]
local GLib = require(206209239)
local Tool = script.Parent

local RemoteInputConnection
local Equipped = false

Tool.Equipped:connect(function()
	if Equipped then return end
	Equipped = true
	
	local character, player, humanoid = GLib.GetCharacter(Tool)
	
	RemoteInputConnection = script.RemoteInput.OnServerEvent:connect(function(client, type, state, ...)
		if client == player then
			if type == Enum.UserInputType.MouseButton1 then
				if state == Enum.UserInputState.Begin then
					Tool.Attack.AttackStateChanged:Fire(true)
				else
					Tool.Attack.AttackStateChanged:Fire(false)
				end
			end
		end
	end)
end)

Tool.Unequipped:connect(function()
	if not Equipped then return end
	Equipped = false
	
	if RemoteInputConnection then RemoteInputConnection:disconnect() RemoteInputConnection=nil end
end)