local Tool = script.Parent;

local cooldown = 20
local crown1, crown2 = "GoldCrown","NinjaTwinSwords"

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	wait(1)
	local reloadTime = Tool.Reload.Value - 1
	wait(reloadTime)
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
