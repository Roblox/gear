local Tool = script.Parent;
local myMouse = nil


enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end
	print("ending")
	enabled = false

	while Tool.Enabled do
		wait(.01)
	end

	print("Setting Mouse To Wait")
	if myMouse ~= nil then myMouse.Icon = "rbxasset://textures\\GunWaitCursor.png" end

	while not Tool.Enabled do
		wait(.01)
	end

	print("Setting Mouse to Go")
	if myMouse ~= nil then myMouse.Icon = "rbxasset://textures\\GunCursor.png" end

	enabled = true
end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	myMouse = mouse

	if Tool.Enabled then mouse.Icon = "rbxasset://textures\\GunCursor.png"
	else mouse.Icon = "rbxasset://textures\\GunWaitCursor.png" end
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
end


Tool.Equipped:connect(onEquippedLocal)
