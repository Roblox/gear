local Tool = script.Parent;

local keepLooping = true

function onEquippedLocal(mouse)

	keepLooping = true

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	mouse.Icon = "rbxasset://textures\\GunCursor.png"

	while keepLooping do
		while Tool.Enabled do
			if not keepLooping then return end
			wait(.01)
		end
		
		print("Setting Mouse To Wait")
		mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

		while not Tool.Enabled do
			if not keepLooping then return end
			wait(.01)
		end

		print("Setting Mouse To Go")
		mouse.Icon = "rbxasset://textures\\GunCursor.png"
	end

	keepLooping = true
end

function onUnequippedLocal()
	keepLooping = false
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
