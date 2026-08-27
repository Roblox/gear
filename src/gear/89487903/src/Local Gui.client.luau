--Stickmasterluke
--A nice simple axe
function waitForChild(obj,name)
	while not obj:FindFirstChild(name) do
		wait()
		print("1waiting for " .. name)
	end
	return obj:FindFirstChild(name)
end

local sp=script.Parent
local sword=waitForChild(sp,"Handle")


enabled=true
taunting=false

function onButton1Down(mouse)
	if not enabled then
		return
	end
	enabled=false
	mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
	wait(1.25)
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	enabled=true
end

function swordUp()
	sp.Grip=CFrame.new(0, 0, -1.1, 1, 0, -0, 0, -0, -1, -0, 1, -0)
end

function swordOut()
	sp.Grip=CFrame.new(0, 0, -1.1, 1, 0, -0, 0, -0, -1, -0, 1, -0)*CFrame.Angles(math.pi/4,.4,0)
end

function onEquippedLocal(mouse)
	local currentlast=lastequipped
	if mouse==nil then
		print("Mouse not found")
		return 
	end
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		onButton1Down(mouse)
	end)
end
sp.Equipped:connect(onEquippedLocal)


