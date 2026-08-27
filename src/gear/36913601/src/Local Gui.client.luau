local Tool = script.Parent;

enabled = true
function onButton1Down(mouse)
	Tool.WitchGas.Value = true
	if not enabled then
		return
	end
	print("ending")
	enabled = false

	while Tool.Enabled do
		wait(.01)
	end

	print("Setting Mouse To Wait")
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	while not Tool.Enabled do
		wait(.01)
	end

	print("Setting Mouse to Go")
	mouse.Icon = "rbxasset://textures\\GunCursor.png"

	enabled = true
end

function onButton1Up(mouse)
	Tool.WitchGas.Value = false
end

function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	mouse.Button1Up:connect(function() onButton1Up(mouse) end)
end


Tool.Equipped:connect(onEquippedLocal)
