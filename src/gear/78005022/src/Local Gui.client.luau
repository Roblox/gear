--By QuantumSama
Tool = script.Parent

local checkConnection
local userMouse

function CheckEnabled()
	if userMouse ~= nil then
		if Tool.Enabled then
			userMouse.Icon = "rbxasset://textures\\GunCursor.png"
		else
			userMouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
		end
	end
end

function onEquippedLocal(mouse)
	if mouse == nil then 
		print("Mouse not found")
		return
	end
	userMouse = mouse
	checkConnection = Tool.Changed:connect( CheckEnabled )
end


function onUnequippedLocal()
	if checkConnection then checkConnection:disconnect() end
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)