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


-- ~~SET-UP ON-EQUIP and ON-UNEQUIP HERE~~
local keying = false
local keyDown = nil

function onKeyDown(key)
if key == nil then return end
if keying then return end
	keying = true
	selection = script.Parent.Mode.Value
	--radius = vCharacter.Radius.Value

	key:lower()
	if key == "f" then
		--selection = selection + 1
		--if selection == 3 then selection = 0 end
		if selection == 1 then 
			if onShieldClick ~= nil then onShieldClick() end
		end
		if selection == 2 then 
			if onBlastClick ~= nil then onBlastClick() end
		end
		if selection == 0 then 
			if onStormClick ~= nil then onStormClick() end
		end
	elseif key == "r" then
		--selection = selection -1
		--if selection == -1 then selection = 2 end
		if selection == 2 then 
			if onShieldClick ~= nil then onShieldClick() end
		end
		if selection == 0 then 
			if onBlastClick ~= nil then onBlastClick() end
		end
		if selection == 1 then 
			if onStormClick ~= nil then onStormClick() end
		end
	end
	if key == "t" then
		if onUpClick ~= nil then onUpClick() end
	elseif key == "g" then
		if onDownClick ~= nil then onDownClick() end
	end

	keying = false
end

local screen = vPlayer.PlayerGui:FindFirstChild("EnergyScreenGui")
function onEquippedLocal(mouse)

	if mouse == nil then
		print("Mouse not found")
		return 
	end

	radius_tag = vCharacter:FindFirstChild("Radius")
	if radius_tag == nil then
		radius_tag = Instance.new("NumberValue")
		radius_tag.Name = "Radius"
		radius_tag.Value = 7
		radius_tag.Parent = vCharacter
	end

	--if (Tool.Enabled) then mouse.Icon = "rbxasset://textures\\GunCursor.png"
	--else mouse.Icon = "rbxasset://textures\\GunWaitCursor.png" end
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function() onButton1Down(mouse) end)

	keyDown = mouse.KeyDown:connect(onKeyDown)

	if screen == nil then
		print("Screen Nil!")
	else screen.Parent = vPlayer.PlayerGui end

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

	while Tool.Enabled do
		wait(.01)
	end

	print("Setting Mouse To Wait")
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"

	while not Tool.Enabled do
		wait(.01)
	end

	print("Setting Mouse to Go")
	mouse.Icon = "rbxasset://textures\\GunCursor.png"

	enabled = true
end


-- ~~SET-UP GUI SCREEN HERE~~
if (screen == nil) then
	print("Creating Screen!")
	-- need to make a new screen
	screen = script:FindFirstChild("EnergyScreenGui")
	if screen == nil then print("ENERGY SCREEN NOT CLONEABLE!") end
	screen:Clone().Parent = vPlayer.PlayerGui
	screen = vPlayer.PlayerGui:FindFirstChild("EnergyScreenGui")
end


function onUnequippedLocal()
	if keyDown ~= nil then keyDown:disconnect() end
	screen.Parent = nil -- remove gun GUI
	print("Deleting Screen!")
end
Tool.Unequipped:connect(onUnequippedLocal)





local storm = screen.StormButton
local shield = screen.ShieldButton
local blast = screen.BlastButton
local up = screen.UpButton
local down = screen.DownButton

local rArrow = screen.rArrow
local fArrow = screen.fArrow

local radiusImages = {screen.endImage, screen.radius5, screen.radius6, screen.radius7, screen.radius8, screen.radius9, screen.radius10, screen.radius11, screen.radius12, screen.radius13, screen.radius14, screen.radius15, screen.endImage}

-- ~~FLY-IN ANIMATION~~ 
local stormX = 0
local stormY = 0
local shieldX = 1
local shieldY = 0
local blastX = 1
local blastY = 1

-- not actually the centroid we need to calculate, but rather the circumcenter
	-- (we use the fact that two diameters of a circle must intersect at its center,
	--  and the perpendicular bisector of any chord in a circle gives us a diameter:
	--  geometry FTW!)
local ABmidX = (shieldX+blastX)/2
local ABmidY = (shieldY+blastY)/2
local BCmidX = (stormX+blastX)/2
local BCmidY = (stormY+blastY)/2
local ABPerpSlope = (blastX-shieldX)/(shieldY-blastY)
local BCPerpSlope = (stormX-blastX)/(blastY-stormY)

local AByIntercept = ABmidY - ABPerpSlope*ABmidX
local BCyIntercept = BCmidY - BCPerpSlope*BCmidY

local centroidX = (BCyIntercept-AByIntercept)/(ABPerpSlope-BCPerpSlope)
local centroidY = ABPerpSlope*centroidX + AByIntercept

--print(centroidX)
--print(centroidY)

-- by symmetry, radius is the same from circumcenter
local radius = math.sqrt((stormX - centroidX)*(stormX - centroidX)+(stormY - centroidY)*(stormY - centroidY))
local alpha = 0
local stormAlphaOffset = math.atan2((stormY - centroidY),(stormX - centroidX))
local shieldAlphaOffset = math.atan2((shieldY - centroidY),(shieldX - centroidX))
local blastAlphaOffset = math.atan2((blastY - centroidY),(blastX - centroidX))

local angularV = .030 
local angularA = .007

for i = 0, 59 do
	-- so many maths...  trig time here:
	
	stormX = radius*math.cos(alpha+stormAlphaOffset) + centroidX
	stormY = radius*math.sin(alpha+stormAlphaOffset) + centroidY

	shieldX = radius*math.cos(alpha+shieldAlphaOffset) + centroidX
	shieldY = radius*math.sin(alpha+shieldAlphaOffset) + centroidY

	blastX = radius*math.cos(alpha+blastAlphaOffset) + centroidX
	blastY = radius*math.sin(alpha+blastAlphaOffset) + centroidY
	
	if i < 36 then radius = radius - .017 end
	alpha = alpha + angularV
	angularV = angularV + angularA
	

	if i > 34 then
		centroidX = centroidX - .02
		centroidY = centroidY + .02
	end
	
	-- show the updates
	storm.Position = UDim2.new(stormX, -50, stormY, -50)
	shield.Position = UDim2.new(shieldX, -50, shieldY, -50)
	blast.Position = UDim2.new(blastX, -50, blastY, -50)
	wait(.05)
end


local numIter = 20
-- convert relative to absolute coordinates
--local absoluteX = script.Parent.AbsoluteSize.X
--local absoluteY = script.Parent.AbsoluteSize.Y
local absoluteX = screen.AbsoluteSize.X
local absoluteY = screen.AbsoluteSize.Y

stormX = absoluteX*stormX - 50
stormY = absoluteY*stormY - 50 - absoluteY
shieldX = absoluteX*shieldX - 50
shieldY = absoluteY*shieldY - 50 - absoluteY
blastX = absoluteX*blastX - 50
blastY = absoluteY*blastY - 50 - absoluteY


-- 50, -200; 0, -100; 100, -100
local stormXStep = (50 - stormX)/numIter
local stormYStep = (-200 - stormY)/numIter
local shieldXStep = (100 - shieldX)/numIter
local shieldYStep = (-100 - shieldY)/numIter
local blastXStep = (0 - blastX)/numIter
local blastYStep = (-100 - blastY)/numIter


local upX = 150--100
local upY = -150--(-200)
local downX = 150--100
local downY = -100--(-100)


radius = 7

local firstRad = radiusImages[radius-3]
local aboveRad = radiusImages[radius-2]
local belowRad = radiusImages[radius-4]

for i = 1,numIter do
	stormX = stormX + stormXStep
	stormY = stormY + stormYStep
	shieldX = shieldX + shieldXStep
	shieldY = shieldY + shieldYStep
	blastX = blastX + blastXStep
	blastY = blastY + blastYStep
	storm.Position = UDim2.new(0, stormX, 1, stormY)
	shield.Position = UDim2.new(0, shieldX, 1, shieldY)
	blast.Position = UDim2.new(0, blastX, 1, blastY)

	upX = upX - 10
	downX = downX - 10

	up.Position = UDim2.new(1, upX, 1, upY)
	down.Position = UDim2.new(1, downX, 1, downY)

	--aboveRad.Position = UDim2.new(1, -175, 1, -200-(numIter-i)*50)
	--firstRad.Position = UDim2.new(1, -200+(numIter-i)*20, 1, -150)
	--belowRad.Position = UDim2.new(1, -175, 1, -50+(numIter-i)*10)
	aboveRad.Position = UDim2.new(1, -125, 1, -200-(numIter-i)*50)
	firstRad.Position = UDim2.new(1, -150+(numIter-i)*20, 1, -150)
	belowRad.Position = UDim2.new(1, -125, 1, -50+(numIter-i)*10)


	--rArrow.Position = UDim2.new(0, 185+(numIter-i)*50, 1, -100-(numIter-i)*50)
	--fArrow.Position = UDim2.new(0, 185+(numIter-i)*10, 1, -30+(numIter-i)*10)
	rArrow.Position = UDim2.new(0, 135+(numIter-i)*50, 1, -100-(numIter-i)*50)
	fArrow.Position = UDim2.new(0, 135+(numIter-i)*10, 1, -30+(numIter-i)*10)

	wait(.05)
end

-- ~~ACTUAL FUNCTIONALITY~~
local scaleEnabled = true
function onStormClick()
	if (storm.Selected) or not scaleEnabled then return end
	storm.Selected = true
	shield.Selected = false
	blast.Selected = false

	--scaleButtons(130, 100, 100, 100, -100, 0, -100, 50, -200)
	--scaleButtons(100, 50, 50, 50, -50, 0, -50, 25, -100)
	scaleButtons(100, 50, 50, 50, -75, 0, -75, 25, -125)

	script.Parent.Mode.Value = 2
end

function onShieldClick()
	if (shield.Selected) or not scaleEnabled then return end
	storm.Selected = false
	shield.Selected = true
	blast.Selected = false	

	--scaleButtons(100, 130, 100, 50, -200, 100, -100, 0, -100)
	--scaleButtons(50, 100, 50, 25, -100, 50, -50, 0, -50)
	scaleButtons(50, 100, 50, 25, -125, 50, -75, 0, -75)
	script.Parent.Mode.Value = 0
end

function onBlastClick()
	if (blast.Selected) or not scaleEnabled then return end
	storm.Selected = false
	shield.Selected = false
	blast.Selected = true

	--scaleButtons(100, 100, 130, 0, -100, 50, -200, 100, -100)
	--scaleButtons(50, 50, 100, 0, -50, 25, -100, 50, -50)
	scaleButtons(50, 50, 100, 0, -75, 25, -125, 50, -75)
	script.Parent.Mode.Value = 1
end


function updateRadiusUp()
	local currentSelection = radiusImages[radius - 3] --the one coming from above, getting larger
	local oldSelection = radiusImages[radius - 4] -- the one getting smaller
	local belowSelection = radiusImages[radius - 5] -- the one disappearing
	local aboveSelection = radiusImages[radius - 2] -- the one appearing in the up-slot
	aboveSelection.Visible = true
	for i = 1,10 do
		if i == 10 then belowSelection.Visible = false end

		aboveSelection.Size = UDim2.new(0, i*5, 0, i*5)
		currentSelection.Size = UDim2.new(0, i*5+50, 0, i*5+50)
		oldSelection.Size = UDim2.new(0, 100-i*5, 0, 100-i*5)
		belowSelection.Size = UDim2.new(0, 50-i*5, 0, 50-i*5)
		
		
		-- -175, -200
		--aboveSelection.Position = UDim2.new(1, -175+(10-i)*2.5, 1, -200)
		aboveSelection.Position = UDim2.new(1, -125+(10-i)*2.5, 1, -200)
		
		-- -200, -150
		--currentSelection.Position = UDim2.new(1, -200+(10-i)*2.5, 1, -150-(10-i)*5)
		currentSelection.Position = UDim2.new(1, -150+(10-i)*2.5, 1, -150-(10-i)*5)

		-- -175, -50
		--oldSelection.Position = UDim2.new(1, -175-(10-i)*2.5, 1, -50-(10-i)*10)
		oldSelection.Position = UDim2.new(1, -125-(10-i)*2.5, 1, -50-(10-i)*10)

		-- -150, 0
		--belowSelection.Position = UDim2.new(1, -150-(10-i)*2.5, 1, 0-(10-i)*5)
		belowSelection.Position = UDim2.new(1, -100-(10-i)*2.5, 1, 0-(10-i)*5)
		wait(.02)
	end
	--belowSelection.Visible = false
end

function updateRadiusDown()
	local currentSelection = radiusImages[radius - 3] --the one coming from below, getting larger
	local oldSelection = radiusImages[radius - 2] -- the one getting smaller
	local belowSelection = radiusImages[radius - 1] -- the one disappearing
	local aboveSelection = radiusImages[radius - 4] -- the one appearing in the down-slot
	aboveSelection.Visible = true
	for i = 1,10 do
		if i == 10 then belowSelection.Visible = false end

		aboveSelection.Size = UDim2.new(0, i*5, 0, i*5)
		currentSelection.Size = UDim2.new(0, i*5+50, 0, i*5+50)
		oldSelection.Size = UDim2.new(0, 100-i*5, 0, 100-i*5)
		belowSelection.Size = UDim2.new(0, 50-i*5, 0, 50-i*5)

--		oldSelection.Position = UDim2.new(1, -175-(10-i)*2.5, 1, -200+(10-i)*5)
--		currentSelection.Position = UDim2.new(1, -200+(10-i)*2.5, 1, -150+(10-i)*10)
--		aboveSelection.Position = UDim2.new(1, -175+(10-i)*2.5, 1, -50+(10-i)*5)
--		belowSelection.Position = UDim2.new(1, -150-(10-i)*2.5, 1, -200)

		oldSelection.Position = UDim2.new(1, -125-(10-i)*2.5, 1, -200+(10-i)*5)
		currentSelection.Position = UDim2.new(1, -150+(10-i)*2.5, 1, -150+(10-i)*10)
		aboveSelection.Position = UDim2.new(1, -125+(10-i)*2.5, 1, -50+(10-i)*5)
		belowSelection.Position = UDim2.new(1, -100-(10-i)*2.5, 1, -200)
		wait(.02)
	end
	--belowSelection.Visible = false
end


local scrollEnabled = true
function onUpClick()
	if not scrollEnabled or radius == 15 then return end
	scrollEnabled = false
	radius = radius + 1
	updateRadiusUp()
	scrollEnabled = true
	print(radius)
	vCharacter.Radius.Value = radius
end

function onDownClick()
	if not scrollEnabled or radius == 5 then return end
	scrollEnabled = false
	radius = radius - 1
	updateRadiusDown()
	scrollEnabled = true
	print(radius)
	vCharacter.Radius.Value = radius
end


function scaleButtons(stormScale, shieldScale, blastScale, stormPosX, stormPosY, shieldPosX, shieldPosY, blastPosX, blastPosY)
	if not scaleEnabled then return end
	scaleEnabled = false
	local numSteps = 10
	stormStep = (stormScale - storm.Size.X.Offset)/numSteps
	shieldStep = (shieldScale - shield.Size.X.Offset)/numSteps
	blastStep = (blastScale - blast.Size.X.Offset)/numSteps
	stormStepX = (stormPosX - storm.Position.X.Offset)/numSteps
	stormStepY = (stormPosY - storm.Position.Y.Offset)/numSteps
	shieldStepX = (shieldPosX - shield.Position.X.Offset)/numSteps
	shieldStepY = (shieldPosY - shield.Position.Y.Offset)/numSteps
	blastStepX = (blastPosX - blast.Position.X.Offset)/numSteps
	blastStepY = (blastPosY - blast.Position.Y.Offset)/numSteps

	for i = 1,numSteps do
		storm.Size = UDim2.new(0, stormStep+storm.Size.X.Offset, 0, stormStep+storm.Size.X.Offset)
		shield.Size = UDim2.new(0, shieldStep+shield.Size.X.Offset, 0, shieldStep+shield.Size.X.Offset)
		blast.Size = UDim2.new(0, blastStep+blast.Size.X.Offset, 0, blastStep+blast.Size.X.Offset)
		storm.Position = UDim2.new(0, storm.Position.X.Offset + stormStepX, 1, storm.Position.Y.Offset + stormStepY)
		shield.Position = UDim2.new(0, shield.Position.X.Offset + shieldStepX, 1, shield.Position.Y.Offset + shieldStepY)
		blast.Position = UDim2.new(0, blast.Position.X.Offset + blastStepX, 1, blast.Position.Y.Offset + blastStepY)
		wait(.02)
	end
	scaleEnabled = true
end

onShieldClick()

storm.MouseButton1Click:connect(onStormClick) 
shield.MouseButton1Click:connect(onShieldClick) 
blast.MouseButton1Click:connect(onBlastClick) 
up.MouseButton1Click:connect(onUpClick)
down.MouseButton1Click:connect(onDownClick)

