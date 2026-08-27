-- probably a lot of ineffeciency in this right now :(

local gameState = 0 --[[
0 = no game
1 = waiting for opponent to accept or decline
2 = game running
3 = game over message pending
]]

local opponentSettingUpShips = true
local playerSettingUpShips = true
local playerSalvo = 5
local opponentSalvo = 5

-- 19259975 = loud hohoho
-- 19260023 = soft hohoho
-- 19358641 = jingle

-- 5 - 1, santa, ball
-- 41741823
-- 41741863
-- 41741879
-- 41741892
-- 41741902
-- 41741922

-- 41741939

-- load in images once to get them in cache (sometimes they take awhile to load cold)
loader = Instance.new("ImageLabel")
--loader.Image = "http://www.roblox.com/asset/?id=26729984"
--loader.Image = "http://www.roblox.com/asset/?id=26730038"
--loader.Image = "http://www.roblox.com/asset/?id=26730082"
--loader.Image = "http://www.roblox.com/asset/?id=26730112"
loader.Image = "http://www.roblox.com/asset/?id=41739828"
loader.Image = "http://www.roblox.com/asset/?id=41739870"
loader.Image = "http://www.roblox.com/asset/?id=41739905"
loader.Image = "http://www.roblox.com/asset/?id=41739991"

loader.Image = "http://www.roblox.com/asset/?id=41741823"
loader.Image = "http://www.roblox.com/asset/?id=41741863"
loader.Image = "http://www.roblox.com/asset/?id=41741879"
loader.Image = "http://www.roblox.com/asset/?id=41741892"
loader.Image = "http://www.roblox.com/asset/?id=41741902"
loader.Image = "http://www.roblox.com/asset/?id=41741922"
loader.Image = "http://www.roblox.com/asset/?id=41741922"
loader:remove()

local playerShipIndex = 1

local playerShips = {}          -- create the matrix
	for j=1,5 do
		if j == 5 then
			playerShips[j] = {{0,0},{0,0},{0,0},{0,0},{0,0}}
		elseif j == 4 then
			playerShips[j] = {{0,0},{0,0},{0,0},{0,0}}
		elseif j == 3 then
			playerShips[j] = {{0,0},{0,0},{0,0}}
		elseif j == 2 then
			playerShips[j] = {{0,0},{0,0},{0,0}}
		elseif j == 1 then
			playerShips[j] = {{0,0},{0,0}}
		end
	end

local opponentShipIndex = 1

local opponentShips = {}          -- create the matrix
	for j=1,5 do
		if j == 5 then
			opponentShips[j] = {{0,0},{0,0},{0,0},{0,0},{0,0}}
		elseif j == 4 then
			opponentShips[j] = {{0,0},{0,0},{0,0},{0,0}}
		elseif j == 3 then
			opponentShips[j] = {{0,0},{0,0},{0,0}}
		elseif j == 2 then
			opponentShips[j] = {{0,0},{0,0},{0,0}}
		elseif j == 1 then
			opponentShips[j] = {{0,0},{0,0}}
		end
	end

local opponentLastClick = {0,0}
local playerLastClick = {0,0}
local playerShipNum = 1
local opponentShipNum = 1

local gameTurn = true --[[
true = your turn
false = opponents turn

acts as a spinlock for the main loop
]]

local resourceGui = script.Parent.BattleshipGui
resourceGui.Parent = nil
local opponentGui = nil
local playerGui = nil --[[
the guis for your and the opponent
]]

local right = true
local left = true
local up = true
local down = true
local playerValidSpots = {{0,0},{0,0},{0,0},{0,0}}
local opponentValidSpots = {{0,0},{0,0},{0,0},{0,0}}

local gridMaker = Instance.new("ImageButton")
gridMaker.Size = UDim2.new(0,32,0,28.5)
gridMaker.BackgroundColor3 = Color3.new(255,0,0)
gridMaker.BackgroundTransparency = 1
gridMaker.ZIndex = 10

local shipGrid = Instance.new("ImageButton")
shipGrid.Size = UDim2.new(0,32,0,28,5)
shipGrid.BackgroundColor3 = Color3.new(0,0,255)
shipGrid.BackgroundTransparency = 1
shipGrid.ZIndex = 10

for i = 1, 11 do

	for j = 1,9 do
		
		local name = tostring(i) .. tostring(j)

		local gridSpot = gridMaker:clone()
		gridSpot.Name = name
		gridSpot.Position = UDim2.new(0,2 + (i - 1) * 32,0,(j - 1) * 28.5)
		gridSpot.Parent = resourceGui.MainFrame.StrikeBoard

		local shipSpot = shipGrid:clone()
		shipSpot.Name = name
		shipSpot.Position = UDim2.new(0,2 + (i - 1) * 32,0, (j - 1) * 28.5)
		shipSpot.Parent = resourceGui.MainFrame.ShipBoard

	end

end

local opponentCleanupScript = nil --[[
script to clean up the opponent's gui if I leave
]]

local playerStrikeBoard = {}          -- create the matrix
for i=1,11 do
	playerStrikeBoard[i] = {}     -- create a new row
	for j=1,9 do
		playerStrikeBoard[i][j] = 0 -- [0 = open spot] [1 = has pin, no hit] [2 = has pin, has hit]
	end
end

local playerShipBoard = {}          -- create the matrix
for i=1,11 do
	playerShipBoard[i] = {}     -- create a new row
	for j=1,9 do
		playerShipBoard[i][j] = 0 -- [0 = open spot] [1 = has pin, no hit] [2 = has pin, has hit]
	end
end

local opponentStrikeBoard = {}          -- create the matrix
for i=1,11 do
	opponentStrikeBoard[i] = {}     -- create a new row
	for j=1,9 do
		opponentStrikeBoard[i][j] = 0 -- [0 = open spot] [1 = has pin, no hit] [2 = has pin, has hit]
	end
end

local opponentShipBoard = {}          -- create the matrix
for i=1,11 do
	opponentShipBoard[i] = {}     -- create a new row
	for j=1,9 do
		opponentShipBoard[i][j] = 0 -- [0 = open spot] [1 = has pin, no hit] [2 = has pin, has hit]
	end
end

local player = nil
local opponent = nil --[[
me and the opponent, (and possibly other players / viewers in other games)
]]

local opponentChangedSignal = nil --[[
signal must be connected when the tool is deselected, unlike mouse ones which expire automatically
]]

function hasWon(num)
	if num == 1 then

		local opHits = 0
		for i = 1,11 do
			for j = 1, 9 do
				if opponentShipBoard[i][j] == 2 then
					opHits = opHits + 1
				end
			end
		end
		
		if opHits > 16 then
			return true
		else
			return false
		end

	elseif num == 2 then

		local hits = 0
		for i = 1,11 do
			for j = 1, 9 do
				if playerShipBoard[i][j] == 2 then
					hits = hits + 1
				end
			end
		end
		
		if hits > 16 then
			return true
		else
			return false
		end

	end
end

function boardFull()

	return false

end

function setupPlayerBoard()
		for x = 1, 11 do
			for y = 1, 9 do

				local stringer = tostring(x) .. tostring(y)

				playerGui.MainFrame.ShipBoard[tonumber(stringer)].MouseEnter:connect(function()
					playerGui.MainFrame.ShipBoard[tonumber(stringer)].Image = "http://www.roblox.com/asset/?id=26637734"
				end)
				playerGui.MainFrame.ShipBoard[tonumber(stringer)].MouseLeave:connect(function()
					playerGui.MainFrame.ShipBoard[tonumber(stringer)].Image = ""
				end)

			end
		end
end


function setupOpponentBoard()
	for x = 1, 11 do
			for y = 1, 9 do

				local stringer = tostring(x) .. tostring(y)
				opponentGui.MainFrame.ShipBoard[tonumber(stringer)].MouseEnter:connect(function()
					opponentGui.MainFrame.ShipBoard[tonumber(stringer)].Image = "http://www.roblox.com/asset/?id=26637734"
				end)
				opponentGui.MainFrame.ShipBoard[tonumber(stringer)].MouseLeave:connect(function()
					opponentGui.MainFrame.ShipBoard[tonumber(stringer)].Image = ""
				end)

			end
		end
end

function createPlayerGui()
	--remove the old gui
	if playerGui then
		playerGui:remove()
	end
	--set up the player's GUI
	playerGui = resourceGui:clone()
	playerGui.Parent = player.PlayerGui
	playerGui.SideFrame.Visible = true
	setupPlayerBoard()
	--make the popupframe hide on ok pressed
	playerGui.PopupFrame.Accept.MouseButton1Down:connect(function()
		--hack, this must be the gameover message if gameState is 3, reset game state
		if gameState == 3 then
			playerGui.MainFrame.Visible = false
			playerGui.SideFrame.TXT1.Text = "Click on a player to"
			playerGui.SideFrame.TXT2.Text = "challenge them"
			playerGui.SideFrame.Visible = true
			Spawn(function()
				for i = -128, 0, 4 do
					playerGui.SideFrame.Position = UDim2.new(0, i, 0.5, -16)
					wait()
				end	
			end)			
			gameState = 0
		end
		--hide me
		playerGui.PopupFrame.Visible = false
	end)
end

function findValidPlayerPlaces(x,y,shipSize)

	if x + (shipSize - 1) <= 11 then
		for i = x + 1, x + shipSize - 1 do
			if playerShipBoard[i][y] == 1 then
				right = false
				print("no right")
				break
			end
		end
	else
		print("no right")
		right = false
	end

	if x - (shipSize - 1) > 0 then
		for i = x - shipSize + 1, x - 1 do
			if playerShipBoard[i][y] == 1 then
				left = false
				print("no left")
				break
			end
		end
	else
		print("no left")
		left = false
	end

	if y - (shipSize - 1) > 0 then
		for i = y - (shipSize - 1),y - 1 do
			if playerShipBoard[x][i] == 1 then
				up = false
				break
			end
		end
	else
		up = false
	end

	if y + (shipSize - 1) < 10 then
		for i = y + 1, y + shipSize - 1 do
			if playerShipBoard[x][i] == 1 then
				down = false
				print("no down")
				break
			end
		end
	else
		print("no down")
		down = false
	end

	if right then

		local pc = playerGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637753"
		pc.Parent = playerGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.ZIndex = 60
		pc.Visible = true
		pc.Name = "right"
		pc.Position = UDim2.new(0,2 + 32*(x - 1 + (shipSize - 1)), 0, 28.5*(y -1))
		playerValidSpots[1] = {x + (shipSize - 1),y}


	end

	if left then

		local pc = playerGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637753"
		pc.Parent = playerGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.ZIndex = 60
		pc.Name = "left"
		pc.Visible = true
		pc.Position = UDim2.new(0,2 + 32*(x - 1 -  (shipSize - 1)), 0, 28.5*(y -1))
		playerValidSpots[2] = {x - (shipSize - 1),y}

	end

	if up then

		local pc = playerGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637753"
		pc.Parent = playerGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.ZIndex = 60
		pc.Name = "down"
		pc.Visible = true
		pc.Position = UDim2.new(0,2 + 32*(x - 1), 0, 28.5*(y - 1 -  (shipSize - 1)))
		playerValidSpots[4] = {x,y -  (shipSize - 1)}

		
	end

	if down then

		local pc = playerGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637753"
		pc.Parent = playerGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.ZIndex = 60
		pc.Name = "up"
		pc.Visible = true
		pc.Position = UDim2.new(0,2 + 32*(x - 1), 0, 28.5*(y - 1 +  (shipSize - 1)))
		playerValidSpots[3] = {x,y +  (shipSize - 1)}

	end

	resetPlaces()

end


function findValidOpponentPlaces(x,y,shipSize)

	if x + (shipSize - 1) <= 11 then
		for i = x + 1, x + shipSize - 1 do
			if opponentShipBoard[i][y] == 1 then
				right = false
				print("no right")
				break
			end
		end
	else
		print("no right")
		right = false
	end

	if x - (shipSize - 1) > 0 then
		for i = x - shipSize + 1, x - 1 do
			if opponentShipBoard[i][y] == 1 then
				left = false
				print("no left")
				break
			end
		end
	else
		print("no left")
		left = false
	end

	if y - (shipSize - 1) > 0 then
		for i = y - (shipSize - 1),y - 1 do
			if opponentShipBoard[x][i] == 1 then
				up = false
				break
			end
		end
	else
		up = false
	end

	if y + (shipSize - 1) < 10 then
		for i = y + 1, y + shipSize - 1 do
			if opponentShipBoard[x][i] == 1 then
				down = false
				print("no down")
				break
			end
		end
	else
		print("no down")
		down = false
	end

	if right then

		local pc = opponentGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637753"
		pc.Parent = opponentGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.ZIndex = 60
		pc.Visible = true
		pc.Name = "right"
		pc.Position = UDim2.new(0,2 + 32*(x - 1 + (shipSize - 1)), 0, 28.5*(y -1))
		opponentValidSpots[1] = {x + (shipSize - 1),y}


	end

	if left then

		local pc = opponentGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637753"
		pc.Parent = opponentGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.ZIndex = 60
		pc.Name = "left"
		pc.Visible = true
		pc.Position = UDim2.new(0,2 + 32*(x - 1 -  (shipSize - 1)), 0, 28.5*(y -1))
		opponentValidSpots[2] = {x - (shipSize - 1),y}

	end

	if up then

		local pc = opponentGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637753"
		pc.Parent = opponentGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.ZIndex = 60
		pc.Name = "down"
		pc.Visible = true
		pc.Position = UDim2.new(0,2 + 32*(x - 1), 0, 28.5*(y - 1 -  (shipSize - 1)))
		opponentValidSpots[4] = {x,y -  (shipSize - 1)}

		
	end

	if down then

		local pc = opponentGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637753"
		pc.Parent = opponentGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.ZIndex = 60
		pc.Name = "up"
		pc.Visible = true
		pc.Position = UDim2.new(0,2 + 32*(x - 1), 0, 28.5*(y - 1 +  (shipSize - 1)))
		opponentValidSpots[3] = {x,y +  (shipSize - 1)}

	end

	resetPlaces()

end


function resetPlaces()

	right = true
	left = true
	up = true
	down = true

end

function removePlayerPlaces()

	local leftGui = playerGui.MainFrame.ShipBoard:FindFirstChild("left",false)
	if leftGui ~= nil then
		leftGui:remove()
	end

	local rightGui = playerGui.MainFrame.ShipBoard:FindFirstChild("right",false)
	if rightGui ~= nil then
		rightGui:remove()
	end

	local upGui = playerGui.MainFrame.ShipBoard:FindFirstChild("up",false)
	if upGui ~= nil then
		upGui:remove()
	end

	local downGui =playerGui.MainFrame.ShipBoard:FindFirstChild("down",false)
	if downGui ~= nil then
		downGui:remove()
	end

	playerValidSpots = {{0,0},{0,0},{0,0},{0,0}}

end

function removeOpponentPlaces()

	local leftGui = opponentGui.MainFrame.ShipBoard:FindFirstChild("left",false)
	if leftGui ~= nil then
		leftGui:remove()
	end

	local rightGui = opponentGui.MainFrame.ShipBoard:FindFirstChild("right",false)
	if rightGui ~= nil then
		rightGui:remove()
	end

	local upGui = opponentGui.MainFrame.ShipBoard:FindFirstChild("up",false)
	if upGui ~= nil then
		upGui:remove()
	end

	local downGui = opponentGui.MainFrame.ShipBoard:FindFirstChild("down",false)
	if downGui ~= nil then
		downGui:remove()
	end

	validSpots = {{0,0},{0,0},{0,0},{0,0}}

end

function chooseRightImage(pc,size)

	if size == 5 then
		pc.Image = "http://www.roblox.com/asset/?id=41739975"
	elseif size == 4 then
		pc.Image = "http://www.roblox.com/asset/?id=41739890"
	elseif size == 3 then
		pc.Image = "http://www.roblox.com/asset/?id=41739856"
	elseif size ==2 then
		pc.Image = "http://www.roblox.com/asset/?id=41739815"
	end

end

function chooseLeftImage(pc,size)

	if size == 5 then
		pc.Image = "http://www.roblox.com/asset/?id=41739955"
	elseif size == 4 then
		pc.Image = "http://www.roblox.com/asset/?id=41739881"
	elseif size == 3 then
		pc.Image = "http://www.roblox.com/asset/?id=41739849"
	elseif size ==2 then
		pc.Image = "http://www.roblox.com/asset/?id=41739797"
	end

end

function chooseDownImage(pc,size)

	if size == 5 then
		pc.Image = "http://www.roblox.com/asset/?id=41739944"
	elseif size == 4 then
		pc.Image = "http://www.roblox.com/asset/?id=41739879"
	elseif size == 3 then
		pc.Image = "http://www.roblox.com/asset/?id=41739839"
	elseif size ==2 then
		pc.Image = "http://www.roblox.com/asset/?id=41739788"
	end

end

function setupPlayerShip(x,y,name,size)

	local pc = playerGui.MainFrame.BoardPiece:clone()
	if size == 5 then
		pc.Image = "http://www.roblox.com/asset/?id=41739991"
	elseif size == 4 then
		pc.Image = "http://www.roblox.com/asset/?id=41739905"
	elseif size == 3 then
		pc.Image = "http://www.roblox.com/asset/?id=41739870"
	elseif size ==2 then
		pc.Image = "http://www.roblox.com/asset/?id=41739828"
	end
	pc.Visible = true
	pc.ZIndex = 50
	local validPlayerTarget = false

	for i = 1, #playerValidSpots do

		local spot = playerValidSpots[i]
		if x ~= 0 and y ~= 0 and spot[1] == x and spot [2] == y then
			validPlayerTarget = true
			if x < playerLastClick[1] then
				playerShips[playerShipIndex][1] = {playerLastClick[1],playerLastClick[2]}
				for j = x, playerLastClick[1] do
					chooseLeftImage(pc,size)
					pc.Size = UDim2.new(0,32 * size,0,28.5)
					pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(y -1))
					playerShipBoard[j][y] = 1
					playerShips[playerShipIndex][j - (x - 1)] = {j,y}
				end
			elseif x > playerLastClick[1] then
				playerShips[playerShipIndex][1] = {playerLastClick[1],playerLastClick[2]}
				for j = playerLastClick[1], x do
					chooseRightImage(pc,size)
					pc.Size = UDim2.new(0,32 * size,0,28.5)
					pc.Position = UDim2.new(0,2 + 32*(playerLastClick[1]-1), 0, 28.5*(y -1))
					playerShipBoard[j][y] = 1
					playerShips[playerShipIndex][j - (playerLastClick[1] - 1)] = {j,y}
				end
			elseif y > playerLastClick[2] then
				playerShips[playerShipIndex][1] = {playerLastClick[1],playerLastClick[2]}
				for j = playerLastClick[2], y do
					pc.Size = UDim2.new(0,32,0,28.5 * size)
					chooseDownImage(pc,size)
					pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(playerLastClick[2] -1))
					playerShipBoard[x][j] = 1
					playerShips[playerShipIndex][j - (playerLastClick[2] - 1)] = {x,j}
				end
			elseif y < playerLastClick[2] then
				playerShips[playerShipIndex][1] = {playerLastClick[1],playerLastClick[2]}
				for j = y, playerLastClick[2] do
					pc.Size = UDim2.new(0,32,0,28.5 * size)
					pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(y -1))
					playerShipBoard[x][j] = 1
					playerShips[playerShipIndex][j - (y - 1)] = {x,j}
				end
			end
			pc.Parent = playerGui.MainFrame.ShipBoard
			break
		end

	end

	if validPlayerTarget == false then

		pc:remove()
		playerShipBoard[x][y] = 0

	else
		playerShipNum = playerShipNum + 1
		if playerShipNum > 5 then
			playerSettingUpShips = false
			playerGui.MainFrame.SetupShipFrame.Status.Text = "Waiting for opponent..."
		end
	end

	removePlayerPlaces()

	invalidatePlayerClicks(name,x,y)

end


function setupOpponentShip(x,y,name,size)

	local pc = opponentGui.MainFrame.BoardPiece:clone()
	if size == 5 then
		pc.Image = "http://www.roblox.com/asset/?id=41739991"
	elseif size == 4 then
		pc.Image = "http://www.roblox.com/asset/?id=41739905"
	elseif size == 3 then
		pc.Image = "http://www.roblox.com/asset/?id=41739870"
	elseif size ==2 then
		pc.Image = "http://www.roblox.com/asset/?id=41739828"
	end
	pc.Visible = true
	pc.ZIndex = 50
	local validTarget = false

	for i = 1, #opponentValidSpots do

		local spot = opponentValidSpots[i]
		if x ~= 0 and y ~= 0 and spot[1] == x and spot [2] == y then
			validTarget = true
			if x < opponentLastClick[1] then
				opponentShips[opponentShipIndex][1] = {opponentLastClick[1],opponentLastClick[2]}
				for j = x, opponentLastClick[1] do
					chooseLeftImage(pc,size)
					pc.Size = UDim2.new(0,32 * size,0,28.5)
					pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(y -1))
					opponentShipBoard[j][y] = 1
					opponentShips[opponentShipIndex][j - (x - 1)] = {j,y}
				end
			elseif x > opponentLastClick[1] then
				opponentShips[opponentShipIndex][1] = {opponentLastClick[1],opponentLastClick[2]}
				for j = opponentLastClick[1], x do
					chooseRightImage(pc,size)
					pc.Size = UDim2.new(0,32 * size,0,28.5)
					pc.Position = UDim2.new(0,2 + 32*(opponentLastClick[1]-1), 0, 28.5*(y -1))
					opponentShipBoard[j][y] = 1
					opponentShips[opponentShipIndex][j - (opponentLastClick[1] - 1)] = {j,y}
				end
			elseif y > opponentLastClick[2] then
				opponentShips[opponentShipIndex][1] = {opponentLastClick[1],opponentLastClick[2]}
				for j = opponentLastClick[2], y do
					chooseDownImage(pc,size)
					pc.Size = UDim2.new(0,32,0,28.5 * size)
					pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(opponentLastClick[2] -1))
					opponentShipBoard[x][j] = 1
					opponentShips[opponentShipIndex][j - (opponentLastClick[2] - 1)] = {x,j}
				end
			elseif y < opponentLastClick[2] then
				opponentShips[opponentShipIndex][1] = {opponentLastClick[1],opponentLastClick[2]}
				for j = y, opponentLastClick[2] do
					pc.Size = UDim2.new(0,32,0,28.5 * size)
					pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(y -1))
					opponentShipBoard[x][j] = 1
					opponentShips[opponentShipIndex][j - (y - 1)] = {x,j}
				end
			end
			pc.Parent = opponentGui.MainFrame.ShipBoard
			break
		end

	end

	if validTarget == false then

		pc:remove()
		opponentShipBoard[x][y] = 0

	else
		opponentShipNum = opponentShipNum + 1
		if opponentShipNum > 5 then
			opponentSettingUpShips = false
			opponentGui.MainFrame.SetupShipFrame.Status.Text = "Waiting for opponent..."
		end
	end

	removeOpponentPlaces()

	invalidateOpponentClicks(name,x,y)

end

function invalidatePlayerClicks(name,x,y)
	local removeMe = name .. playerLastClick[1] .. playerLastClick[2]
	if playerShipBoard[x][y] == 0 then
		playerShipBoard[playerLastClick[1]][playerLastClick[2]] = 0
	end
	playerLastClick[1] = 0
	playerLastClick[2] = 0
	playerGui.MainFrame.ShipBoard:FindFirstChild(removeMe, false):remove()
end

function invalidateOpponentClicks(name,x,y)
	removeMe = name .. opponentLastClick[1] .. opponentLastClick[2]
	if opponentShipBoard[x][y] == 0 then
		opponentShipBoard[opponentLastClick[1]][opponentLastClick[2]] = 0
	end
	opponentLastClick[1] = 0
	opponentLastClick[2] = 0
	opponentGui.MainFrame.ShipBoard:FindFirstChild(removeMe, false):remove()
end


function setupShips()

	for x = 1, 11 do
		for y = 1, 9 do
		
			local stringer = tostring(x) .. tostring(y)

			playerGui.MainFrame.ShipBoard[stringer].MouseButton1Down:connect(function()

				if playerShipBoard[x][y] == 0 then
					-- clicked once, now we check to see if positions can be used properly
					if playerLastClick[1] > 0 then

						if playerShipNum == 1 then
							playerShipBoard[x][y] = 1
							playerShipIndex = 5
							setupPlayerShip(x,y,"first",5)
						elseif playerShipNum == 2 then
							playerShipBoard[x][y] = 1
							playerShipIndex = 4
							setupPlayerShip(x,y,"second",4)
						elseif playerShipNum == 3 then
							playerShipBoard[x][y] = 1
							playerShipIndex = 3
							setupPlayerShip(x,y,"third", 3)
						elseif playerShipNum == 4 then
							playerShipBoard[x][y] = 1
							playerShipIndex = 2
							setupPlayerShip(x,y,"fourth",3)
						elseif playerShipNum == 5 then
							playerShipBoard[x][y] = 1
							playerShipIndex = 1
							setupPlayerShip(x,y,"fifth", 2)
						end

					-- first click, remember position and mark it
					else

						if playerShipNum == 1 then
							placeFirstPlayerPosition("first",x,y)
						elseif playerShipNum == 2 then
							placeFirstPlayerPosition("second",x,y)
						elseif playerShipNum == 3 then
							placeFirstPlayerPosition("third",x,y)
						elseif playerShipNum == 4 then
							placeFirstPlayerPosition("fourth",x,y)
						elseif playerShipNum == 5 then
							placeFirstPlayerPosition("fifth",x,y)
						end

					end

				end

			end)

			opponentGui.MainFrame.ShipBoard[stringer].MouseButton1Down:connect(function()

				if opponentShipBoard[x][y] == 0 then
					-- clicked once, now we check to see if positions can be used properly
					if opponentLastClick[1] > 0 then

						if opponentShipNum == 1 then
							opponentShipBoard[x][y] = 1
							opponentShipIndex = 5
							setupOpponentShip(x,y,"first",5)
						elseif opponentShipNum == 2 then
							opponentShipBoard[x][y] = 1
							opponentShipIndex = 4
							setupOpponentShip(x,y,"second",4)
						elseif opponentShipNum == 3 then
							opponentShipBoard[x][y] = 1
							opponentShipIndex = 3
							setupOpponentShip(x,y,"third", 3)
						elseif opponentShipNum == 4 then
							opponentShipBoard[x][y] = 1
							opponentShipIndex = 2
							setupOpponentShip(x,y,"fourth",3)
						elseif opponentShipNum == 5 then
							opponentShipBoard[x][y] = 1
							opponentShipIndex = 1
							setupOpponentShip(x,y,"fifth", 2)
						end

					-- first click, remember position and mark it
					else

						if opponentShipNum == 1 then
							placeFirstOpponentPosition("first",x,y)
						elseif opponentShipNum == 2 then
							placeFirstOpponentPosition("second",x,y)
						elseif opponentShipNum == 3 then
							placeFirstOpponentPosition("third",x,y)
						elseif opponentShipNum == 4 then
							placeFirstOpponentPosition("fourth",x,y)
						elseif opponentShipNum == 5 then
							placeFirstOpponentPosition("fifth",x,y)
						end

					end
				end

			end)

		end
	end

	while playerSettingUpShips or opponentSettingUpShips do

		wait(1)

	end

	-- set up ships is done, time to play!

	playerGui.MainFrame.SetupShipFrame.Visible = false
	playerGui.MainFrame.InfoFrame.Visible = true
	opponentGui.MainFrame.SetupShipFrame.Visible = false
	opponentGui.MainFrame.InfoFrame.Visible = true

	updatePlayerSalvoGui()
	updateOpponentSalvoGui()


	for x = 1, 11 do
		for y = 1, 9 do

			playerStrikeBoard[x][y] = 0
		
			local stringer = tostring(x) .. tostring(y)

			opponentGui.MainFrame.StrikeBoard[tonumber(stringer)].MouseEnter:connect(function()
				opponentGui.MainFrame.StrikeBoard[tonumber(stringer)].Image = "http://www.roblox.com/asset/?id=26637811"
			end)
			opponentGui.MainFrame.StrikeBoard[tonumber(stringer)].MouseLeave:connect(function()
				opponentGui.MainFrame.StrikeBoard[tonumber(stringer)].Image = ""
			end)

			playerGui.MainFrame.StrikeBoard[tonumber(stringer)].MouseEnter:connect(function()
				playerGui.MainFrame.StrikeBoard[tonumber(stringer)].Image = "http://www.roblox.com/asset/?id=26637811"
			end)
			playerGui.MainFrame.StrikeBoard[tonumber(stringer)].MouseLeave:connect(function()
				playerGui.MainFrame.StrikeBoard[tonumber(stringer)].Image = ""
			end)

			playerGui.MainFrame.ShipBoard[tonumber(stringer)].MouseEnter:connect(function()
					playerGui.MainFrame.ShipBoard[tonumber(stringer)].Image = ""
				end)

			opponentGui.MainFrame.ShipBoard[tonumber(stringer)].MouseEnter:connect(function()
					opponentGui.MainFrame.ShipBoard[tonumber(stringer)].Image = ""
				end)

			playerGui.MainFrame.StrikeBoard[stringer].MouseButton1Down:connect(function()

				if playerStrikeBoard[x][y] == 0 and gameTurn == true then
					playerPlayPin(x,y)
				end

			end)

			opponentGui.MainFrame.StrikeBoard[stringer].MouseButton1Down:connect(function()

				if opponentStrikeBoard[x][y] == 0 and gameTurn == false then
					opponentPlayPin(x,y)
				end

			end)
		end
	end

end

function checkPlayerSalvo()

	playerSalvo = 0

	for i = 1,5 do

		if i == 1 then

			for j = 1,2 do
				if playerShipBoard[playerShips[i][j][1]][playerShips[i][j][2]] == 1 then
					playerSalvo = playerSalvo + 1
					break
				end
			end

		elseif i == 2 then

			for j = 1,3 do
				if playerShipBoard[playerShips[i][j][1]][playerShips[i][j][2]] == 1 then
					playerSalvo = playerSalvo + 1
					break
				end
			end

		elseif i == 3 then

			for j = 1,3 do
				if playerShipBoard[playerShips[i][j][1]][playerShips[i][j][2]] == 1 then
					playerSalvo = playerSalvo + 1
					break
				end
			end

		elseif i == 4 then

			for j = 1,4 do
				if playerShipBoard[playerShips[i][j][1]][playerShips[i][j][2]] == 1 then
					playerSalvo = playerSalvo + 1
					break
				end
			end

		elseif i == 5 then

			for j = 1,5 do
				if playerShipBoard[playerShips[i][j][1]][playerShips[i][j][2]] == 1 then
					playerSalvo = playerSalvo + 1
					break
				end
			end

		end

	end

	local playerShipsSunk = 5 - playerSalvo
	opponentGui.MainFrame.InfoFrame.ShipsSunk.TXT.Text = playerShipsSunk

	

end

function checkOpponentSalvo()

	opponentSalvo = 0

	for i = 1,5 do

		if i == 1 then

			for j = 1,2 do
				if opponentShipBoard[opponentShips[i][j][1]][opponentShips[i][j][2]] == 1 then
					opponentSalvo = opponentSalvo + 1
					break
				end
			end

		elseif i == 2 then

			for j = 1,3 do
				if opponentShipBoard[opponentShips[i][j][1]][opponentShips[i][j][2]] == 1 then
					opponentSalvo = opponentSalvo + 1
					break
				end
			end

		elseif i == 3 then

			for j = 1,3 do
				if opponentShipBoard[opponentShips[i][j][1]][opponentShips[i][j][2]] == 1 then
					opponentSalvo = opponentSalvo + 1
					break
				end
			end

		elseif i == 4 then

			for j = 1,4 do
				if opponentShipBoard[opponentShips[i][j][1]][opponentShips[i][j][2]] == 1 then
					opponentSalvo = opponentSalvo + 1
					break
				end
			end

		elseif i == 5 then

			for j = 1,5 do
				if opponentShipBoard[opponentShips[i][j][1]][opponentShips[i][j][2]] == 1 then
					opponentSalvo = opponentSalvo + 1
					break
				end
			end

		end

	end

	local opponentShipsSunk = 5 - opponentSalvo
	playerGui.MainFrame.InfoFrame.ShipsSunk.TXT.Text = opponentShipsSunk

end

function playerPlayPin(x,y)

	local pc = opponentGui.MainFrame.BoardPiece:clone()
	pc.Size = UDim2.new(0,32,0,28.5)
	pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(y -1))
	pc.Visible = true
	pc.ZIndex = 70

	if opponentShipBoard[x][y] == 1 then

		--pc.Image = "http://www.roblox.com/asset/?id=26614617"
		pc.Image = "http://www.roblox.com/asset/?id=41741939"
		pc.Parent = playerGui.MainFrame.StrikeBoard
		playerStrikeBoard[x][y] = 2
		opponentShipBoard[x][y] = 2

		local opHead = opponent.Character.Head
		sound = math.random(1,2)
		script.Parent.Handle.Yeehaw:Play()
		if sound == 1 then
			opHead.Shot:Play()
		else
			opHead.ShotTwo:Play()
		end

		local second = pc:clone()
		second.Parent = opponentGui.MainFrame.ShipBoard

	elseif opponentShipBoard[x][y] == 0 then
		
		pc.Image = "http://www.roblox.com/asset/?id=26614787"
		pc.Parent = playerGui.MainFrame.StrikeBoard
		playerStrikeBoard[x][y] = 1
		opponentShipBoard[x][y] = 1
		local second = pc:clone()
		second.Parent = opponentGui.MainFrame.ShipBoard
		local opHead = opponent.Character.Head
		opHead.Miss:Play()
		script.Parent.Handle.Miss:Play()
	end

	playerSalvo = playerSalvo - 1
	updatePlayerSalvoGui()
	if playerSalvo < 1 then
		gameTurn = false
	end

end

function opponentPlayPin(x,y)

	local pc = playerGui.MainFrame.BoardPiece:clone()
	pc.Size = UDim2.new(0,32,0,28.5)
	pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(y -1))
	pc.Visible = true
	pc.ZIndex = 70

	if playerShipBoard[x][y] == 1 then

		opponentStrikeBoard[x][y] = 2
		playerShipBoard[x][y] = 2
		--pc.Image = "http://www.roblox.com/asset/?id=26614617"
		pc.Image = "http://www.roblox.com/asset/?id=41741939"
		pc.Parent = opponentGui.MainFrame.StrikeBoard

		local opHead = opponent.Character.Head
		sound = math.random(1,2)
		opHead.Yeehaw:Play()
		if sound == 1 then
			script.Parent.Handle.Shot:Play()
		else
			script.Parent.Handle.ShotTwo:Play()
		end

		local second = pc:clone()
		second.Parent = playerGui.MainFrame.ShipBoard

	elseif playerShipBoard[x][y] == 0 then

		opponentStrikeBoard[x][y] = 1
		playerShipBoard[x][y] = 1
		pc.Image = "http://www.roblox.com/asset/?id=26614787"
		pc.Parent = opponentGui.MainFrame.StrikeBoard
		local second = pc:clone()
		second.Parent = playerGui.MainFrame.ShipBoard
		script.Parent.Handle.Miss:play()
		local opHead = opponent.Character.Head
		opHead.Miss:Play()
	end
	opponentSalvo = opponentSalvo - 1
	updateOpponentSalvoGui()
	if opponentSalvo < 1 then
		gameTurn = true
	end
end

function placeFirstPlayerPosition(name,x,y)

	if playerShipBoard[x][y]  == 0 then

		playerLastClick[1] = x
		playerLastClick[2] = y
		local pc = playerGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637827"
		pc.Parent = playerGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(y -1))
		pc.Visible = true
		pc.ZIndex = 50
		pc.Name = name .. tostring(x) .. tostring(y)
		playerShipBoard[x][y] = 1
		if name == "first" then
			findValidPlayerPlaces(x,y,5)
		elseif name == "second" then
			findValidPlayerPlaces(x,y,4)
		elseif name == "third" then
			findValidPlayerPlaces(x,y,3)
		elseif name == "fourth" then
			findValidPlayerPlaces(x,y,3)
		elseif name == "fifth" then
			findValidPlayerPlaces(x,y,2)
		end
	end

end


function placeFirstOpponentPosition(name,x,y)

	if opponentShipBoard[x][y]  == 0 then

		opponentLastClick[1] = x
		opponentLastClick[2] = y
		local pc = opponentGui.MainFrame.BoardPiece:clone()
		pc.Image = "http://www.roblox.com/asset/?id=26637827"
		pc.Parent = opponentGui.MainFrame.ShipBoard
		pc.Size = UDim2.new(0,32,0,28.5)
		pc.Position = UDim2.new(0,2 + 32*(x-1), 0, 28.5*(y -1))
		pc.Visible = true
		pc.ZIndex = 50
		pc.Name = name .. tostring(x) .. tostring(y)
		opponentShipBoard[x][y] = 1
		if name == "first" then
			findValidOpponentPlaces(x,y,5)
		elseif name == "second" then
			findValidOpponentPlaces(x,y,4)
		elseif name == "third" then
			findValidOpponentPlaces(x,y,3)
		elseif name == "fourth" then
			findValidOpponentPlaces(x,y,3)
		elseif name == "fifth" then
			findValidOpponentPlaces(x,y,2)
		end
	end

end

function updatePlayerSalvoGui()

	if gameTurn == true then
		if playerSalvo == 5 then
			playerGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741823"
		elseif playerSalvo == 4 then
			playerGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741863"
		elseif playerSalvo == 3 then
			playerGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741879"
		elseif playerSalvo == 2 then
			playerGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741892"
		elseif playerSalvo == 1 then
			playerGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741902"
		elseif playerSalvo == 0 then
			playerGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741922"
		end
	else
		playerGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741922"
	end
end

function updateOpponentSalvoGui()

	if gameTurn == false then
		if opponentSalvo == 5 then
			opponentGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741823"
		elseif opponentSalvo == 4 then
			opponentGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741863"
		elseif opponentSalvo == 3 then
			opponentGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741879"
		elseif opponentSalvo == 2 then
			opponentGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741892"
		elseif opponentSalvo == 1 then
			opponentGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741902"
		elseif opponentSalvo == 0 then
			opponentGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741922"
		end
	else
		opponentGui.MainFrame.InfoFrame.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=41741922"
	end
end

function playGame()
	--== create a new board for the player (reusing old one causes some rendering bugs with the x and o images)
	createPlayerGui()
	--==set up the opponent's gui connections (the player's are setup on tool selection)
	setupOpponentBoard()
	--==hide the player's sideframe
	Spawn(function()
		for i = 0, -128, -4 do
			playerGui.SideFrame.Position = UDim2.new(0, i, 0.5, -16)
			wait()
		end	
	end)
	--==set turn and gamestate
	local gameRunning = true
	gameTurn = true
	gameState = 2
	--reset the board, and the player's board gui
	for x = 1,11 do
		for y = 1, 9 do
			stringer = tostring(x) .. tostring(y)
			playerGui.MainFrame.StrikeBoard[tonumber(stringer)].Image = ""
			playerGui.MainFrame.StrikeBoard[tonumber(stringer)].Image = ""
			opponentStrikeBoard[x][y] = 0
			opponentShipBoard[x][y] = 0
			playerShipBoard[x][y] = 0
			playerStrikeBoard[x][y] = 0
		end
	end
	playerSettingUpShips = true
	opponentSettingUpShips = true
	playerShipNum = 1
	opponentShipNum = 1
	playerSalvo = 5
	opponentSalvo = 5
	--==connection for if the opponent leaves
	local opponentLeftSignal = game.Players.ChildRemoved:connect(function(p)
		if p == opponent then
			gameState = 3
			playerGui.MainFrame.Visible = false
			playerGui.PopupFrame.TXT.Text = "Opponent has left"
			playerGui.PopupFrame.Visible = true
		end
	end)
	--==connection to put back the gui if the opponent dies
	local opponentDiedSignal = opponent.Changed:connect(function(property)
		if property == "Character" then
			--clean up connections to opponent
	--		opponentLeftSignal:disconnect()
		--	opponentDiedSignal:disconnect()
			--clean up opponentcleanup
			opponentCleanupScript:remove()
			--clean up guis
			opponentGui:remove()
			opponentGui = nil
			print("removed opp gui")

		--[[	if opponent ~= nil then
				local opHead = opponent.Character.Head
				if opHead ~= nil then
					opHead.Shot:remove()
					opHead.ShotTwo:remove()
					opHead.Yeehaw:remove()
					opHead.Miss:remove()
				end
			end]]
			playerGui:remove()
			playerGui = nil
			print("removed player gui")
		end
	end)

	--==player died, panic and trash the game
	local playerDiedSignal = player.Character.Humanoid.Died:connect(function()
		--clean up connections to opponent
		opponentLeftSignal:disconnect()
		opponentDiedSignal:disconnect()
		--clean up opponentcleanup
		opponentCleanupScript:remove()
		--clean up guis
		opponentGui:remove()
		opponentGui = nil

		if opponent ~= nil then
			local opHead = opponent.Character.Head
			if opHead ~= nil then
				opHead.Shot:remove()
				opHead.ShotTwo:remove()
				opHead.Yeehaw:remove()
				opHead.Miss:remove()
			end
		end
		--player's is going to get cleaned up right anyways, TODO : maybe show a popup message
		playerGui:remove()
		playerGui = nil
	end)
	--=="quit" button pressed connections
	local playerQuitSignal = playerGui.MainFrame.InfoFrame.BN_Quit.MouseButton1Down:connect(function()
		playerGui.MainFrame.Visible = false
		playerGui.PopupFrame.TXT.Text = "You have quit the game"
		playerGui.PopupFrame.Visible = true
		--
		opponentGui.MainFrame.Visible = false
		opponentGui.PopupFrame.TXT.Text = player.Name.." has quit, you win!"
		opponentGui.PopupFrame.Visible = true		
		--
		gameRunning = false
		gameTurn = not gameTurn

		if opponent ~= nil then
			local opHead = opponent.Character.Head
			if opHead ~= nil then
				opHead.Shot:remove()
				opHead.ShotTwo:remove()
				opHead.Yeehaw:remove()
				opHead.Miss:remove()
			end
		end
	end)
	local opponentQuitSignal = opponentGui.MainFrame.InfoFrame.BN_Quit.MouseButton1Down:connect(function()
		playerGui.MainFrame.Visible = false
		playerGui.PopupFrame.TXT.Text = opponent.Name.." has quit, you win!"
		playerGui.PopupFrame.Visible = true
		--
		opponentGui:remove()
		opponentGui = nil
		--
		gameRunning = false
		gameTurn = not gameTurn
		
		if opponent ~= nil then
			local opHead = opponent.Character.Head
			if opponent.Head ~= nil then
				opHead.Shot:remove()
				opHead.ShotTwo:remove()
				opHead.Yeehaw:remove()
				opHead.Miss:remove()
			end
		end
	end)
	--
	
	local piframe = playerGui.MainFrame.InfoFrame
	playerGui.MainFrame.Visible = true
	piframe.Visible = false
	piframe.Opponent.TXT.Text = opponent.Name
	piframe.Turn.TXT.Text = "Your turn"
	piframe.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=26647196"
	local oiframe = opponentGui.MainFrame.InfoFrame
	opponentGui.MainFrame.Visible = true
	oiframe.Visible = false
	oiframe.Opponent.TXT.Text = player.Name
	oiframe.Turn.TXT.Text = "Opponent's turn"
	oiframe.Turn.TurnImage.Image = "http://www.roblox.com/asset/?id=26647234"

	playerGui.MainFrame.SetupShipFrame.Visible = true
	playerGui.MainFrame.InfoFrame.Visible = false
	opponentGui.MainFrame.SetupShipFrame.Visible = true
	opponentGui.MainFrame.InfoFrame.Visible = false

	setupShips()
	--==enter the main gameloop
	while gameRunning do
		--wait for the spinlock, for a player to make a move
		local tmp = gameTurn
		while gameTurn == tmp do
			wait()
		end
		if not gameRunning then
			break
		end
		--change turn displays
		if gameTurn then
			piframe.Turn.TXT.Text = "Your turn"
			oiframe.Turn.TXT.Text = "Opponent's turn"
		else
			piframe.Turn.TXT.Text = "Opponent's turn"
			oiframe.Turn.TXT.Text = "Your turn"
		end
		--check for a win
		if hasWon(1) then
			--playerGui.MainFrame.Visible = false
			playerGui.PopupFrame.TXT.Text = "You have won!"
			playerGui.PopupFrame.Visible = true
			--
			--opponentGui.MainFrame.Visible = false
			opponentGui.PopupFrame.TXT.Text = "You have lost =("
			opponentGui.PopupFrame.Visible = true
			--
			break
		elseif hasWon(2) then
			--playerGui.MainFrame.Visible = false
			playerGui.PopupFrame.TXT.Text = "You have lost =("
			playerGui.PopupFrame.Visible = true
			--
			--opponentGui.MainFrame.Visible = false
			opponentGui.PopupFrame.TXT.Text = "You have won!"
			opponentGui.PopupFrame.Visible = true	
			--
			break			
		end
		checkPlayerSalvo()
		checkOpponentSalvo()
		updatePlayerSalvoGui()
		updateOpponentSalvoGui()
	end
	--==disconnect the signals made
	opponentDiedSignal:disconnect()
	opponentLeftSignal:disconnect()
	playerQuitSignal:disconnect()
	opponentQuitSignal:disconnect()
	--==set the gamestate to gameover message pending
	gameState = 3
end

script.Parent.Equipped:connect(function()
	print("BattleWagons Equipped")
	gameState = 0
	gameTurn = true
	player = game.Players:playerFromCharacter(script.Parent.Parent)
	--listen for a player clicked notification sent from the localscript
	opponentChangedSignal = script.Parent.Opponent.Changed:connect(function()
		--was set to nil, ignore change
		if not script.Parent.Opponent.Value then 
			print("Opponent value set back to nil") 
			return 
		end
		print("Clicked an opponent")
		--if there's no game, challenge this player
		if gameState == 0 then
			print("Starting game")
			--if they're allready playing tictactoe then return
			if script.Parent.Opponent.Value.PlayerGui:FindFirstChild("BattleshipGui") then 
				print("Opponent is already playing a game")
				if script.Parent.Opponent.Value.Character:FindFirstChild(script.Parent.Name) then
					playerGui.PopupFrame.TXT.Text = "Player is already playing a game"
					playerGui.PopupFrame.Visible = true
				else
					playerGui.PopupFrame.TXT.Text = "Player is already playing a game"
					playerGui.PopupFrame.Visible = true
				end
				wait(0.1)
				script.Parent.Opponent.Value = nil
				return 
			end
			if (script.Parent.Opponent.Value.Character.Torso.Position - player.Character.Torso.Position).magnitude > 16 then
				playerGui.PopupFrame.TXT.Text = "Player is too far away"
				playerGui.PopupFrame.Visible = true
				wait(0.1)
				script.Parent.Opponent.Value = nil
				return
			end
			--set the gamestate
			gameState = 1
			opponent = script.Parent.Opponent.Value
			wait(0.1)
			script.Parent.Opponent.Value = nil
			--set up the opponent's GUI
			opponentGui = resourceGui:clone()
			opponentGui.AcceptFrame.Visible = true
			opponentGui.AcceptFrame.TXT.Text = player.Name.." wants to play BattleSleighs with you!"
			--==set up the opponent's cleanup if this player leaves
			opponentCleanupScript = script.Parent.Connect4_OpponentCleanup:clone()
			opponentCleanupScript.Challenger.Value = player
			opponentCleanupScript.Cleanup.Value = opponentGui
			opponentCleanupScript.Disabled = false
			--should I put it straight in workspace or is that considered namespace pollution? that will work for now at least
			opponentCleanupScript.Parent = game.Workspace
			--on accept
			opponentGui.AcceptFrame.Accept.MouseButton1Down:connect(function()
				opponentGui.AcceptFrame.Visible = false
				local opHead = opponent.Character.Head
				if opHead ~= nil then
					local shotOne = script.Parent.Handle.Shot:clone()
					shotOne.Parent = opHead
					local shotTwoer = script.Parent.Handle.ShotTwo:clone()
					shotTwoer.Parent = opHead
					local yee = script.Parent.Handle.Yeehaw:clone()
					yee.Parent = opHead
					local miss = script.Parent.Handle.Miss:clone()
					miss.Parent = opHead
				end
				playGame()
			end)
			--on decline
			opponentGui.AcceptFrame.Decline.MouseButton1Down:connect(function()
				--reset player's sideframes' text
				playerGui.SideFrame.TXT1.Text = "Click on a player to"
				playerGui.SideFrame.TXT2.Text = "challenge them"
				--show me a popup stating player declined
				playerGui.PopupFrame.TXT.Text = "Opponent Declined =("
				playerGui.PopupFrame.Visible = true	
				--reset the game state
				gameState = 0
				--remove opponent gui
				opponentGui:remove()
				opponentGui = nil
				--remove opponent cleanup script
				opponentCleanupScript:remove()
				opponentCleanupScript = nil
			end)
			--hide popup on OK pressed
			opponentGui.PopupFrame.Accept.MouseButton1Down:connect(function()
				--only called on game waiting for over, delete this gui and "this player left" script if it exists
				if opponentCleanupScript then
					opponentCleanupScript:remove()
					opponentCleanupScript = nil
				end
				opponentGui:remove()
				opponentGui = nil
			end)
			--gui set up, add it
			opponentGui.Parent = opponent.PlayerGui
			--set the player's GUI
			playerGui.SideFrame.TXT1.Text = "Sending Challenge"
			playerGui.SideFrame.TXT2.Text = "Please wait..."
		else
			print("Game already started")
			wait(0.1)
			script.Parent.Opponent.Value = nil
		end
	end)
	--create the player's gui
	createPlayerGui()
	--pretty effects, scroll out the side frame
	for i = -128, 0, 4 do
		playerGui.SideFrame.Position = UDim2.new(0, i, 0.5, -16)
		wait()
	end
	print("BattleWagons finished setup")
end)

function doCleanUp()
	--clean up the guis if they exist
	if opponentGui then
		opponentGui:remove()
		opponentGui = nil
	end
	if playerGui then
		playerGui:remove()
		playerGui = nil
	end	
	
	--remove the connection to opponentchanged
	opponentChangedSignal:disconnect()

	playerSettingUpShips = true
	opponentSettingUpShips = true
	playerShipNum = 1
	opponentShipNum = 1

	if opponent ~= nil then
		local opHead = opponent.Character.Head
		if opHead ~= nil then
			opHead.Shot:remove()
			opHead.ShotTwo:remove()
			opHead.Yeehaw:remove()
			opHead.Miss:remove()
		end
	end
end

script.Parent.Unequipped:connect(function()
	print("Tool unequipped, clean up...")
	doCleanUp()
	--TODO: send some friendly notification to a possible
	--opponent that the player exited the map or deselected
	--the tool. As the player will have exited a separate
	--script is required for this
end)






