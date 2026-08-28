local Tool = script.Parent;
local MyMouse
local Enabled = true

function OnButton1Down(mouse)
	if not Enabled then
		return
	end

	Enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	wait(2)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	Enabled = true

end

function OnKeyDown( key )
end

function OnEquipped(mouse)
	if mouse == nil then
		print("Mouse not found")
		return 
	end
	MyMouse = mouse
	MyMouse.Icon = "rbxasset://textures\\GunCursor.png"
	MyMouse.Button1Down:connect(function() OnButton1Down(MyMouse) end)
	MyMouse.KeyDown:connect(OnKeyDown)
end

function OnUnequipped()

end


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
