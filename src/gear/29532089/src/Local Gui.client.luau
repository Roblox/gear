local Tool = script.Parent;
local con = nil
local enabled = true
local mouser = nil

function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	wait(.2)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	enabled = true

end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	mouser = mouse
	con = mouse.Move:connect(changeValues)

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
end

function onUnequippedLocal()

	mouser = nil
	con:disconnect()

end

function changeValues()

	Tool.X.Value = mouser.X
	Tool.Y.Value = mouser.Y

end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

