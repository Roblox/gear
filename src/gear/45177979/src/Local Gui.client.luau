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


function onActivated()
	if not Tool.Enabled then return end
	local vChar = Tool.Parent
	if vChar == nil then return end
	
	local hum = vChar:FindFirstChild("Humanoid")
	if hum == nil then return end

	--wait(1)

	sledge1 = hum:LoadAnimation(Tool.sledgehammer3)
	sledge1:Play()
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
