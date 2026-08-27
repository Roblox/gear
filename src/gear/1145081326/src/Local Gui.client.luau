Tool = script.Parent 

local stillEquipped = true

function onEquippedLocal(mouse)
	stillEquipped = true
	if mouse == nil then
		return
	end
	while stillEquipped do 
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
		while Tool.Enabled and stillEquipped do
			wait(0.01)
		end
		mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
		while not Tool.Enabled and stillEquipped do
			wait(0.01)
		end		
	end
end

function onUnequippedLocal()
	stillEquipped = false
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
