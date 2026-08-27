local Tool = script.Parent

local StillEquipped = false

function onEquippedLocal(mouse)
	StillEquipped = true

	if not mouse then return end

	while StillEquipped do
		mouse.Icon = 'rbxasset://textures/GunCursor.png'
		while Tool.Enabled and StillEquipped do
			wait(0.01)
		end
		mouse.Icon = 'rbxasset://textures/GunWaitCursor.png'
		while not Tool.Enabled and StillEquipped do
			wait(0.01)
		end
	end
end

function onUnequippedLocal()
	StillEquipped = false
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
