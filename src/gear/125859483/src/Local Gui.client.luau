local Tool = script.Parent;

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end
	enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
	wait(1)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	enabled = true
end

function onEquippedLocal(mouse)
	if mouse == nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
end


Tool.Equipped:connect(onEquippedLocal)

--[[
both=125728293 125730305 125731912 125736357
box=125729168 125754735
pizza=125729422 125732887 125755847


]]