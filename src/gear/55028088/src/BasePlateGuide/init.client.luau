local pointDirection = nil

local tailLength = 2 -- 2 or 7
--local dSize = -.05  -- .01 or .005
local dSize = 0 -- because we want the targets to all be the same size (tail isn't larger anymore; just "ghost" effect)
local dTime = .04 --.025

-- old targetLock pic (square): 48972746

local targetLockSize = .2
local arrowSize = .1

local arrowScreenProportionSize = .95
local arrowMoveFactor = .025

local targetMoveFactor = targetLockSize / 2 - .025

local halfDSize = dSize / 2

local r = game:service("RunService")

local vChar = script.Parent
if vChar == nil then script.Parent = nil end

local vPlay = game.Players:GetPlayerFromCharacter(vChar)
if vPlay == nil then script.Parent = nil end

local arrowGui = vPlay.PlayerGui:FindFirstChild("GuideArrowGui")
if arrowGui == nil then
	arrowGui = script.GuideArrowGui
	arrowGui.Parent = vPlay.PlayerGui
else
	script.GuideArrowGui:remove()
end

local upArrow = arrowGui.UpArrow
local downArrow = arrowGui.DownArrow
local leftArrow = arrowGui.LeftArrow
local rightArrow = arrowGui.RightArrow
local targetLock = arrowGui.TargetLock
local arrowList = {upArrow, downArrow, leftArrow, rightArrow, targetLock}

local goAway = arrowGui.GoAwayButton
goAway.Visible = true
goAway.Active = true
local keepShowing = true
goAway.MouseButton1Click:connect(function () keepShowing = false end)


local arrowHeightAugment = 0.0
local arrowWidthAugment = 0.0
local targetHeightAugment = 0.0
local targetWidthAugment = 0.0


local targetLockList = {targetLock}
for i = 1, tailLength do table.insert(targetLockList, targetLock:Clone()) end

targetLockList[1].Size = UDim2.new(targetLockSize, 0, targetLockSize, 0)
for i = 1, #targetLockList-1 do
	targetLockList[i+1].Parent = arrowGui
	--targetLockList[i+1].Size = UDim2.new(targetLockSize-i*dSize, 0, targetLockSize-i*dSize, 0)
end
-- switching over to a "ghost-like" transparency effect, but this means we have to upload separate images :(
-- if our tail is turned on, manually apply the ghosting to the next two images
if tailLength > 0 then targetLockList[2].Image = "http://www.roblox.com/asset/?id=49324811" end
if tailLength > 1 then targetLockList[3].Image = "http://www.roblox.com/asset/?id=49324846" end


function onResize() -- force arrows into a square resolution
	xSize = arrowGui.AbsoluteSize.X
	ySize = arrowGui.AbsoluteSize.Y

	if xSize >= ySize then
		arrowHeightAugment = 0.0

		-- calculate arrowWidthAugment and new arrow ratio here
		newArrowUDim = UDim2.new(ySize / xSize * arrowSize, 0, arrowSize, 0)
		rightArrow.Size = newArrowUDim 
		leftArrow.Size = newArrowUDim 
		upArrow.Size = newArrowUDim 
		downArrow.Size = newArrowUDim

		for tli = 1, #targetLockList do
			targetLockList[tli].Size = UDim2.new(ySize / xSize * (targetLockSize-tli*dSize), 0, targetLockSize-tli*dSize, 0)
		end

		arrowWidthAugment = (xSize - ySize)*arrowSize*.5 / xSize
	else
		arrowWidthAugment = 0.0

		-- calculate arrowHeightAugment here
		newArrowUDim = UDim2.new(arrowSize, 0, xSize / ySize * arrowSize, 0)
		rightArrow.Size = newArrowUDim
		leftArrow.Size = newArrowUDim
		upArrow.Size = newArrowUDim
		downArrow.Size = newArrowUDim

		for tli = 1, #targetLockList do
			targetLockList[tli].Size = UDim2.new(targetLockSize-tli*dSize, 0, xSize / ySize * (targetLockSize-tli*dSize), 0)
		end

		arrowHeightAugment = (ySize - xSize)*arrowSize*.5 / ySize
	end

	targetWidthAugment = targetLock.Size.X.Scale / 2 - .025
	targetHeightAugment = targetLock.Size.Y.Scale / 2 - .025
end

arrowGui.Changed:connect(onResize) -- dynamically resize the arrows on screen resize

function findMyBasePlate()
	--if true then return game.Workspace.Base end -- for testing purposes

	local buildingAreas = game.Workspace.BuildingAreas:GetChildren()
	for i = 1, #buildingAreas do
		if buildingAreas[i].Player.Value == script.Parent.Name then
			return buildingAreas[i]:FindFirstChild("BasePlate") or buildingAreas[i].PlayerArea:FindFirstChild("BasePlate")
		end
	end
end

local myBase = findMyBasePlate()
if myBase == nil then
	print("BasePlateGuide script error: no base plate found!")
	-- abort if no BasePlate found
	arrowGui:remove()
	script:remove()
end

function setVisible(whichArrow)
	for i = 1, #arrowList do
		if arrowList[i] == whichArrow then
			arrowList[i].Visible = true
		else
			arrowList[i].Visible = false
		end
	end
end

function truncate(number, augmentation)
	if number+augmentation < 0 then return 0 
   elseif number > (1 - arrowSize)+augmentation then return (1 - arrowSize)+2*augmentation -- furthest extent we want the arrows to reach is .95 - arrowSize
	else return number+augmentation end
end


function notInBasePlate(myPos, base)
	local corner1 = base.Position - base.Size/2
	local corner2 = base.Position + base.Size/2
	if myPos.X > corner1.X and myPos.Y > corner1.Y and myPos.Z > corner1.Z and myPos.X < corner2.X and myPos.Z < corner2.Z then -- we only care they're somewhere above baseplate
		return false
	else
		return true
	end
end

local lastTime = 0
local camera = game.Workspace.CurrentCamera
while notInBasePlate(script.Parent.Torso.Position, myBase) and keepShowing do
	--pointDirection = (myBase.Position - script.Parent.Torso.Position) * Vector3.new(1, 0, 1)
	camFrame = camera.CoordinateFrame
	pointDirection = camFrame:vectorToObjectSpace(myBase.Position - camFrame.p)
	camZ = pointDirection.Z
	camX = pointDirection.X/math.abs(camZ)
	camY = pointDirection.Y/math.abs(camZ)
	--print(camX, camY, camZ)

	-- was .55 for 610 (Y) and 1.15 for 1286 (X), so seems like scaling factor is universally 1114 on both axes	
	-- nvm:  at 1662 x 666, we have ... and .55, so seems like .55 always for Y, then X is scaled according to its proportion to Y

	local xThreshold = arrowGui.AbsoluteSize.X / arrowGui.AbsoluteSize.Y * .55
	local yThreshold = .55

	local nCamX = camX / xThreshold
	local nCamY = camY / yThreshold

	if (math.abs(nCamX) > 1 or math.abs(nCamY) > 1) or (camZ > 0) then -- camZ test makes sure we only lock on if facing right direction
		for j = 2, #targetLockList do
			targetLockList[j].Visible = false
		end
	
		if math.abs(nCamX) > math.abs(nCamY) then
			--if nCamY > 1 then nCamY = 1
			--elseif nCamY < -1 then nCamY = -1 end

			if camX > 0 then
				-- should go right
				rightArrow.Position = UDim2.new(arrowScreenProportionSize - arrowMoveFactor - .025 + 2*arrowWidthAugment, 0, truncate(arrowScreenProportionSize*(1-nCamY)/2 - arrowMoveFactor, arrowHeightAugment), 0)
				setVisible(rightArrow)
			else
				-- should go left
				leftArrow.Position = UDim2.new(0, 0, truncate(arrowScreenProportionSize*(1-nCamY)/2 - arrowMoveFactor, arrowHeightAugment), 0)
				setVisible(leftArrow)
			end
		else
			--if nCamX > 1 then nCamX = 1
			--elseif nCamX < -1 then nCamX = -1 end

			if camY > 0 then
				-- should go up
				upArrow.Position = UDim2.new(truncate(arrowScreenProportionSize*(nCamX+1)/2 - arrowMoveFactor, arrowWidthAugment), 0, 0, 0)
				setVisible(upArrow)
			else
				-- should go down
				downArrow.Position = UDim2.new(truncate(arrowScreenProportionSize*(nCamX+1)/2 - arrowMoveFactor, arrowWidthAugment), 0, arrowScreenProportionSize - arrowMoveFactor -.025 + 2*arrowHeightAugment, 0)
				setVisible(downArrow)
			end
		end
	else
		-- locked on target
		--for j = 2, #targetLockList do
			--targetLockList[j].Visible = true
		--end
		--targetLock.Position = UDim2.new(.95*(nCamX+1)/2 - targetMoveFactor, 0, .95*(1-nCamY)/2 - targetMoveFactor, 0)
		targetLock.Position = UDim2.new(.95*(nCamX+1)/2 - targetWidthAugment, 0, .95*(1-nCamY)/2 - targetHeightAugment, 0)
		setVisible(targetLock)
	end

	--wait()
	
	-- update every dTime seconds

	-- ok to do it this way instead of a ring array, because even though it's less efficient, it's less efficient by only one or two commands [since only have 2 "tails"]

	local t = r.Stepped:wait()
	if t - lastTime > dTime then
		lastTime = t
		for j = #targetLockList, 2, -1 do
			targetLockList[j].Position = targetLockList[j-1].Position + UDim2.new(halfDSize, 0, halfDSize, 0)
			targetLockList[j].Visible = targetLockList[j-1].Visible
		end
	end
end

--[[setVisible(nil)
for j = 2, #targetLockList do
	targetLockList[j].Visible = false
end
goAway.Visible = false
goAway.Active = false
]]--
arrowGui:remove()
script:remove()