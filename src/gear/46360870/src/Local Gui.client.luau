local Tool = script.Parent

local stillEquipped = true


function onEquippedLocal(mouse)
	stillEquipped = true
	if mouse == nil then 
		print("NO MOUSE")
		return
	end

	while stillEquipped do
		print("Setting Mouse to Go")
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
		while Tool.Enabled and stillEquipped do
			wait(.01)
		end
		print("Setting Mouse to Wait")
		mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
		
		while not Tool.Enabled and stillEquipped do 
			wait(.01)	
		end
	end
end

function onUnequippedLocal()
	stillEquipped = false
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
