local Tool = script.Parent

local UserInputTypes = {
	CreateRope = 1;
	BreakRope = 2;
}

local UserInputRemoteEvent = script.Parent:WaitForChild("UserInput")

function onButton1Down(mouse)
	--print("Local mousedown")
	UserInputRemoteEvent:FireServer(UserInputTypes.CreateRope, mouse.Hit.p)
end

function onKeyDown(key)
	print("Local keydown")
	key = key:lower()
	if key == "q" then
		UserInputRemoteEvent:FireServer(UserInputTypes.BreakRope)
	end
end

function onEquippedLocal(mouse)
	print("Local equipped")
	if mouse == nil then
		print("Mouse not found")
		return 
	end

	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)
	mouse.KeyDown:connect(onKeyDown)
end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(function() UserInputRemoteEvent:FireServer(UserInputTypes.BreakRope) end)