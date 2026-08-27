--Made by Stickmasterluke


local sp=script.Parent

enabled=true
handle=sp:WaitForChild("Handle")
gui=sp:WaitForChild("StickGui")
local button=gui:WaitForChild("ButtonHolder"):WaitForChild("Button")
local fill=gui:WaitForChild("Bar"):WaitForChild("Fill")
local currentattack=sp:WaitForChild("CurrentAttack")
local energy=sp:WaitForChild("Energy")
magics={
	"Wave",
	"Strike",
	"Blast",
	"Fort",
	"Forest",
	"Lift",
}

function onButton1Down(mouse)
	if not enabled then
		return
	end
	enabled=false
	mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
	wait(.5)
	mouse.Icon="rbxasset://textures\\GunCursor.png"
	enabled=true
end

function changemode(a)
	currentmagic=currentmagic+a
	if currentmagic>#magics then
		currentmagic=1
	elseif currentmagic<1 then
		currentmagic=#magics
	end
	currentattack.Value=magics[currentmagic]
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
	mouse.KeyDown:connect(function(key)
		if key then
			key=string.byte(key)
			if key==string.byte("q") then
				changemode(-1)
			elseif key==string.byte("e") then
				changemode(1)
			end
		end
	end)
	local plr=game.Players.LocalPlayer
	if plr then
		local plrgui=plr:FindFirstChild("PlayerGui")
		if plrgui then
			gui.Parent=plrgui
		end
	end
end
sp.Equipped:connect(onEquippedLocal)
sp.Unequipped:connect(function()
	gui.Parent=sp
end)

sp:WaitForChild("RunAnim").Changed:connect(function()
	local h=sp.Parent:FindFirstChild("Humanoid")
	local t=sp.Parent:FindFirstChild("Torso")
	local anim=sp:FindFirstChild(sp.RunAnim.Value)
	if anim and t and h then
		theanim=h:LoadAnimation(anim)
		if theanim and h.Health>0 then
			theanim:Play()
		end
	end
end)

currentattack.Changed:connect(function()
	button.Text=currentattack.Value
end)
button.MouseButton1Down:connect(function()
	changemode(1)
end)

energy.Changed:connect(function()
	local percent=energy.Value/100
	fill.Size=UDim2.new(percent,0,1,0)
	fill.BackgroundColor3=Color3.new(percent,1,percent)
end)

currentmagic=math.random(1,#magics)
currentattack.Value=magics[currentmagic]




