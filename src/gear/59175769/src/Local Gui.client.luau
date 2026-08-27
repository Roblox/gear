local Tool = script.Parent

local stillEquipped = true


function updateDir(mouse)
	if mouse then
		Tool.FlamethrowerScript.Dir.Value = mouse.Hit.lookVector
	end
end

function onButton1Down(mouse)	
	if not stillEquipped then
		return
	end	
	enabled = false
	while Tool.Enabled do
		updateDir(mouse)
		wait(.01)		
	end
	print("Setting Mouse To Wait")
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
	while not Tool.Enabled do
		updateDir(mouse)
		wait(.01)		
	end
	print("Setting Mouse to Go")
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

function onUnequippedLocal()
	stillEquipped = false
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
