local Tool = script.Parent;

enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end

	enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	wait(.5)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	enabled = true

end

function slamDown(mouse, key)
	if not Tool:FindFirstChild('JustEquipped').Value and key:lower() == "x" then
		mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

		wait(17.5)
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
	end
end


function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	--mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	mouse.KeyDown:connect(function(key) slamDown(mouse, key) end)
end


Tool.Equipped:connect(onEquippedLocal)
