local Tool = script.Parent
local vCharacter = Tool.Parent
local vPlayer = game.Players:playerFromCharacter(vCharacter)
--if vPlayer == nil then return end
while vPlayer == nil do
	Tool = script.Parent
	vCharacter = Tool.Parent
	vPlayer = game.Players:playerFromCharacter(vCharacter)
	wait(.3)
end

-- 15047813  = cookie crunching noise :)

-- ~~SET-UP ON-EQUIP and ON-UNEQUIP HERE~~

local screen = vPlayer.PlayerGui:FindFirstChild("FortuneCookieGui")
function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	--if (Tool.Enabled) then mouse.Icon = "rbxasset://textures\\GunCursor.png"
	--else mouse.Icon = "rbxasset://textures\\GunWaitCursor.png" end
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)

	if screen == nil then
		print("Screen Nil!")
	else screen.Parent = vPlayer.PlayerGui end

	cookieSound = Tool.Handle:FindFirstChild("CookieSound")
	if cookieSound == nil then
		cookieSound = Instance.new("Sound")
		cookieSound.Name = "CookieSound"
		cookieSound.Volume = 1
		cookieSound.SoundId = "http://www.roblox.com/asset/?id=15047813"
		cookieSound.Parent = Tool.Handle
	end


	--[[if screen == nil then
		print("Creating Screen!")
		-- need to make a new screen
		screen = script:FindFirstChild("EnergyScreenGui")
		if screen == nil then print("ENERGY SCREEN NOT CLONEABLE!") end
		screen:Clone().Parent = vPlayer.PlayerGui
		screen = vPlayer.PlayerGui:FindFirstChild("EnergyScreenGui")
	else screen.Parent = vPlayer.PlayerGui end]]--
end

Tool.Equipped:connect(onEquippedLocal)

local enabled = true
function onButton1Down(mouse)
	if not enabled then
		return
	end
	enabled = false


	Tool.GripForward = Vector3.new(-0.97, 1.02e-005, -0.243)
	Tool.GripPos = Vector3.new(-.1, 0.3, -1.53) -- -0.2, 0, -1.23
	Tool.GripRight = Vector3.new(0.197, 0.581, -0.79)
	Tool.GripUp = Vector3.new(-0.141, 0.814, 0.563)

	print("Setting Mouse To Wait")
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"


	cookieSound = Tool.Handle:FindFirstChild("CookieSound")
	cookieSound:Play()

	wait(1)

	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripPos = Vector3.new(0,-.5,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)


	if screen ~= nil then
		local fortunes = {screen.fortune1, screen.fortune2, screen.fortune3, screen.fortune4, screen.fortune5, screen.fortune6, screen.fortune7, screen.fortune8, screen.fortune9, screen.fortune10, screen.fortune11}
		-- GOOD RANDOMIZATION CODE!!
		--numLoops = math.random(0,math.floor(1000*tick()*time()))
		numLoops = math.random(0,math.floor(1000*time()))
		numLoops = numLoops - (math.floor(numLoops / 10000)*10000)
		for i = 1,numLoops do
			whichNum = math.random(1,11) --1,11
		end
		-- END OF GOOD RANDOMIZATION CODE!
		myFortune = fortunes[whichNum]
		print("Picked Fortune: ")
		print(whichNum)
	
		-- put in fortune here
		myFortune.Visible = true
		for i = 1,20 do
			myFortune.Position = UDim2.new(0.05+(20-i)*.02, 0, 0.7, 0)
			myFortune.Size = UDim2.new(0.9*i/20, 0, 0.3*i/20, 0)
			wait(.1)
		end
		myFortune.Position = UDim2.new(0.05, 0, 0.7, 0)
		myFortune.Size = UDim2.new(0.9, 0, 0.3, 0)
		

		wait(6)
		myFortune.Visible = false
	end

	print("Setting Mouse to Go")
	mouse.Icon = "rbxasset://textures\\GunCursor.png"


	enabled = true
end


-- ~~SET-UP GUI SCREEN HERE~~
if (screen == nil) then
	print("Creating Screen!")
	-- need to make a new screen
	screen = script:FindFirstChild("FortuneCookieGui")
	if screen == nil then print("FORTUNE COOKIE SCREEN NOT CLONEABLE!") end
	screen:Clone().Parent = vPlayer.PlayerGui
	screen = vPlayer.PlayerGui:FindFirstChild("FortuneCookieGui")
end


function onUnequippedLocal()
	cookieSound = Tool.Handle:FindFirstChild("CookieSound")
	if cookieSound ~= nil then cookieSound.Parent = nil end -- remove cookie sound
	screen.Parent = nil -- remove fortune cookie GUI
	print("Deleting Screen!")
	Tool.Handle.Mesh.VertexColor = Vector3.new(1, 0.5, 0)
end
Tool.Unequipped:connect(onUnequippedLocal)

Spawn(function()
	local mesh = Tool.Handle.Mesh
	local targetColors = {Vector3.new(1, 0.5, 0), Vector3.new(1, 0, 0)}
	local i = 1
	while true do
		if mesh.VertexColor:isClose(targetColors[i]) then
			i = math.random(#targetColors)
			print(i)
		end
		mesh.VertexColor = mesh.VertexColor:Lerp(targetColors[i], 0.1)
		wait(1/30)
	end
end)
