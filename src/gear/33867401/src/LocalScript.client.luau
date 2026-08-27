local Tool = script.Parent
local gui = nil
local mapParts = {}
local player = nil

local keyDownCon = nil
local keyUpCon = nil
local clickCon = nil

local platforming = false

local time = 0

local gaming = true

local head = nil

local left = false
local right = false
local jump = false

local prize = nil
local prizeRegenTimer = 0

local walkCounter = 0
local playerWalkForward = {"32171523","32171543","32171566","32171582","32171594"}
local playerWalkBackward = {"32168430","32168450","32168470","32168483","32168492"}

local playerVelocity = Vector2.new(0,0) 

function onEquipped(mouse)

	Tool.Handle.Song:Stop()
	Tool.Handle.Jump:Stop()
	Tool.Handle.Prize:Stop()
	Tool.Handle.Fail:Stop()
	enabled = false

	gui = Tool.GameGui:clone()
	player = gui.Cabinet.Screen.Player
	mapParts = gui.Cabinet.Screen.Map:GetChildren()

	keyDownCon = mouse.KeyDown:connect(onKeyDown)
	keyUpCon = mouse.KeyUp:connect(onKeyUp)
	clickCon = gui.Cabinet.SoundOnOff.MouseButton1Click:connect(soundChanger)

	if Tool.Handle.Song.Volume == 0 then
		gui.Cabinet.SoundOnOff.Image = "http://www.roblox.com/asset/?id=32203595"
	else
		gui.Cabinet.SoundOnOff.Image = "http://www.roblox.com/asset/?id=32203454"
	end

	head = Tool.Parent:FindFirstChild("Head")

end

Tool.Equipped:connect(onEquipped)

function onUnequipped()

	gaming = false
	head.Anchored = false

	Tool.Handle.Song:Stop()
	Tool.Handle.Jump:Stop()
	Tool.Handle.Prize:Stop()
	Tool.Handle.Fail:Stop()

	game.Workspace.CurrentCamera.CameraType = 5
	gui:remove()

	keyDownCon:disconnect()
	keyUpCon:disconnect()
	clickCon:disconnect()
	clickCon = nil
	keyDownCon = nil
	keyUpCon = nil

end

Tool.Unequipped:connect(onUnequipped)

local enabled = false

function onActivated()

	if enabled then return end

	enabled = true

	game.Workspace.CurrentCamera.CameraType = 1
	head.Anchored = true
	prize = nil
	prizeRegenTimer = 0
	time = 0
	gui.Parent = game.Players:GetPlayerFromCharacter(Tool.Parent).PlayerGui

	Tool.Handle.Song:Play()
	
	gameLoop()
	
	Tool.Handle.Song:Stop()
	gui:remove()
	gui = Tool.GameGui:clone()
	clickCon = gui.Cabinet.SoundOnOff.MouseButton1Click:connect(soundChanger)
	if Tool.Handle.Song.Volume == 0 then
		gui.Cabinet.SoundOnOff.Image = "http://www.roblox.com/asset/?id=32203595"
	else
		gui.Cabinet.SoundOnOff.Image = "http://www.roblox.com/asset/?id=32203454"
	end
	player = gui.Cabinet.Screen.Player
	mapParts = gui.Cabinet.Screen.Map:GetChildren()
	game.Workspace.CurrentCamera.CameraType = 5
	head.Anchored = false

	enabled = false

end

Tool.Activated:connect(onActivated)

function soundChanger()

	if gui.Cabinet.SoundOnOff.Image == "http://www.roblox.com/asset/?id=32203454" then
		gui.Cabinet.SoundOnOff.Image = "http://www.roblox.com/asset/?id=32203595"
		Tool.Handle.Song.Volume = 0
		Tool.Handle.Jump.Volume = 0
		Tool.Handle.Prize.Volume = 0
		Tool.Handle.Fail.Volume = 0
	else
		gui.Cabinet.SoundOnOff.Image = "http://www.roblox.com/asset/?id=32203454"
		Tool.Handle.Song.Volume = 0.5
		Tool.Handle.Jump.Volume = 0.5
		Tool.Handle.Prize.Volume = 0.5
		Tool.Handle.Fail.Volume = 0.5
	end

end

function onKeyDown(key)

	key:lower()
	if key == "a" then
		left = true
		right = false
	elseif key == "d" then
		left = false
		right = true
	elseif key == "w" then
		jump = true
	end

end


function onKeyUp(key)
	
	key:lower()
	if key == "a" then
		left = false
	elseif key == "d" then
		right = false
	elseif key == "w" then
		jump = false
	end

end


function Physics()

	if playerVelocity.y < 8 then
		playerVelocity = Vector2.new(playerVelocity.x,playerVelocity.y + 1)
	end
	if playerVelocity.y > 1 then
		platforming = false
	end
	local enemies = gui.Cabinet.Screen.Enemies:GetChildren()
	for i = 1, #enemies do
		enemies[i].Position = UDim2.new(0,enemies[i].Position.X.Offset,0,enemies[i].Position.Y.Offset + 5)
	end

end


function Touching(a,b)
	local ap = Vector2.new(a.Position.X.Offset, a.Position.Y.Offset)
	local as = Vector2.new(a.Size.X.Offset, a.Size.Y.Offset)
	local bp = Vector2.new(b.Position.X.Offset, b.Position.Y.Offset)
	local bs = Vector2.new(b.Size.X.Offset, b.Size.Y.Offset)
	local c = (ap.x + as.x > bp.x) and (bp.x + bs.x > ap.x) and (ap.y + as.y > bp.y) and (bp.y + bs.y > ap.y)
	if c then
		return true
	else
		return false
	end
end 



function Collision()

	-- check player against map
	for i = 1, #mapParts do

		if Touching(mapParts[i],player) then

			if player.Position.X.Offset < mapParts[i].Position.X.Offset and not platforming then
				player.Position = UDim2.new(0, mapParts[i].Position.X.Offset - player.Size.X.Offset,0,player.Position.Y.Offset)
				playerVelocity = Vector2.new(0,playerVelocity.y)
			elseif player.Position.X.Offset + player.Size.X.Offset > mapParts[i].Position.X.Offset + mapParts[i].Size.X.Offset and not platforming then
				player.Position = UDim2.new(0, mapParts[i].Position.X.Offset + mapParts[i].Size.X.Offset,0,player.Position.Y.Offset)
				playerVelocity = Vector2.new(0,playerVelocity.y)
			else
				if player.Position.Y.Offset > mapParts[i].Position.Y.Offset then
					playerVelocity = Vector2.new(playerVelocity.x,10)
					platforming = false
				elseif player.Position.Y.Offset + player.Size.Y.Offset > mapParts[i].Position.Y.Offset then
					platforming = true
					playerVelocity = Vector2.new(playerVelocity.x,0)
				end
			end

		end

	end

	-- check enemies against map, player
	local enemies = gui.Cabinet.Screen.Enemies:GetChildren()
	for i = 1, #enemies do
		for j = 1, #mapParts do
			if Touching(mapParts[j],enemies[i]) then
				enemies[i].Position = UDim2.new(0,enemies[i].Position.X.Offset,0,mapParts[j].Position.Y.Offset - enemies[i].Size.Y.Offset)
			end
		end
		if enemies[i].Position.X.Offset > 384 or enemies[i].Position.X.Offset < 0  then
			if enemies[i].Position.Y.Offset > 230 then
				enemies[i]:remove()
			else
				enemies[i].Left.Value = not enemies[i].Left.Value
			end
		end
		if Touching(enemies[i],player) then
			gaming = false
		end
 	end

	-- check game bounds
	if player.Position.X.Offset < 0 then
		playerVelocity = Vector2.new(0,playerVelocity.y)
		player.Position = UDim2.new(0,0,0,player.Position.Y.Offset)
	elseif player.Position.X.Offset > 384 then
		playerVelocity = Vector2.new(0,playerVelocity.y)
		player.Position = UDim2.new(0,384,0,player.Position.Y.Offset)
	end

	if player.Position.Y.Offset < 0 then
		playerVelocity = Vector2.new(playerVelocity.x,0)
		player.Position = UDim2.new(0,player.Position.X.Offset,0,0)
	end
	
	-- check player against prize
	if prize ~= nil and Touching(player,prize) then
		time = time + 100
		Tool.Handle.Prize:Play()
		prize:remove()
		prize = nil
		prizeRegenTimer = math.random(180,360)
	end

end

function updatePlayerPos()

	if math.abs(playerVelocity.x) > 4 then
		if playerVelocity.x  < 0 then	
			playerVelocity = Vector2.new(-4,playerVelocity.y)
		else
			playerVelocity = Vector2.new(4,playerVelocity.y)
		end
	end
	player.Position = UDim2.new(0,player.Position.X.Offset + playerVelocity.x,0,player.Position.Y.Offset + playerVelocity.y)
	playerVelocity = Vector2.new(playerVelocity.x * 0.5,playerVelocity.y * 0.9)

end

function Controls()

	if left then
		playerVelocity = Vector2.new(playerVelocity.x - 3,playerVelocity.y)
	elseif right then
		playerVelocity = Vector2.new(playerVelocity.x + 3,playerVelocity.y)
	end
	if jump and platforming then
		jump = false
		platforming = false
		Tool.Handle.Jump:Play()
		playerVelocity = Vector2.new(playerVelocity.x,playerVelocity.y - 20)
	end

end

function walkAnimation(forward)

	walkCounter = walkCounter + 1
	if walkCounter > 8 then
		walkCounter = 1
	end

	local playIndex = walkCounter
	if walkCounter == 4 then
		playIndex = 2
	elseif walkCounter == 5 then
		playIndex = 1
	elseif walkCounter == 6 then
		playIndex = 4
	elseif walkCounter == 7 then
		playIndex = 5
	elseif walkCounter == 8 then
		playIndex = 4
	end

	if forward then
		player.Image = "http://www.roblox.com/asset/?id=" .. playerWalkForward[playIndex]
	else
		player.Image = "http://www.roblox.com/asset/?id=" .. playerWalkBackward[playIndex]
	end

end

local forward = true
function animation()
	
	if playerVelocity.x > 1 then
		forward = true
		walkAnimation(forward)
	elseif playerVelocity.x < -1 then
		forward = false
		walkAnimation(forward)
	elseif forward then
		player.Image = "http://www.roblox.com/asset/?id=" .. playerWalkForward[1]
		walkCounter = 1
	else
		player.Image = "http://www.roblox.com/asset/?id=" .. playerWalkBackward[1]
		walkCounter = 1
	end

end

local left = true
function spawnEnemy()

	local enemy = Instance.new("ImageLabel")
	enemy.Image = "http://www.roblox.com/asset/?id=32183056"
	enemy.Size = UDim2.new(0,16,0,16)
	enemy.BackgroundTransparency = 1
	enemy.BorderSizePixel = 0
	enemy.ZIndex = 2
	if left then
		enemy.Position = UDim2.new(0,0,0,0)
	else
		enemy.Position = UDim2.new(0,380,0,0)
	end
	enemy.Name = "Enemy"
	enemy.Parent = gui.Cabinet.Screen.Enemies

	local leftDirection = Instance.new("BoolValue")
	leftDirection.Name = "Left"
	leftDirection.Value = not left
	leftDirection.Parent = enemy

	left = not left

end

local spawned = false
local maxEnemies = 0
function updateEnemies()

	maxEnemies = 4 + (time/900)
	local enemies = gui.Cabinet.Screen.Enemies:GetChildren()
	if #enemies < maxEnemies and not spawned then
		spawned = true
		spawnEnemy()
		local co = coroutine.create(function() 
			wait(math.random(1,3))
			spawned = false
		end)
		coroutine.resume(co)
	end
	for i = 1, #enemies do

		if enemies[i].Left.Value then
			enemies[i].Position = UDim2.new(0,enemies[i].Position.X.Offset - 3,0,enemies[i].Position.Y.Offset)
		else
			enemies[i].Position = UDim2.new(0,enemies[i].Position.X.Offset + 3,0,enemies[i].Position.Y.Offset)
		end

	end

end

function updatePrize()
	if prizeRegenTimer > 0 then
		prizeRegenTimer = prizeRegenTimer - 1
		return
	end
	if prize ==  nil then
		prize = Instance.new("ImageLabel")
		prize.Name = "Prize"
		prize.Size = UDim2.new(0,24,0,24)
		prize.Image = "http://www.roblox.com/asset/?id=32190862"
		prize.BackgroundTransparency = 1
		prize.BorderSizePixel = 0
		prize.Parent = gui.Cabinet.Screen

		local pos = math.random(1,4)
		if pos == 1 then prize.Position = UDim2.new(0,24,0,120)
		elseif pos == 2 then prize.Position = UDim2.new(0,350,0,120)
		elseif pos == 3 then prize.Position = UDim2.new(0,350,0,230)
		else prize.Position = UDim2.new(0,24,0,230) end			
	end
end

function gameOver()

	Tool.Handle.Song:Stop()
	Tool.Handle.Fail:Play()
	wait(1)
	if gui:FindFirstChild("Cabinet") then
		gui.Cabinet:remove()
	end
	local scoreFrame = gui:FindFirstChild("ScoreFrame")
	if scoreFrame then
		scoreFrame.BackgroundTransparency = 0.2
	end
	while scoreFrame do
		gui.ScoreFrame.Position = UDim2.new(0.5,gui.ScoreFrame.Position.X.Offset,0.5,gui.ScoreFrame.Position.Y.Offset - 3)
		if gui.ScoreFrame.Position.Y.Offset <= 0 then wait(3) return end
		wait()
	end

end

function gameLoop()

	animTimer = 0
	gaming = true
	while gaming do
		Physics()
		Collision()
		Controls()
		updatePlayerPos()
		updateEnemies()
		updatePrize()
		time = time + 0.05
		animTimer = animTimer + 1
		if animTimer == 3 then
			animation()
			animTimer = 0
		end
		gui.ScoreFrame.Score.Text = tostring(math.floor(time))
		wait(0.03)
	end
	if head.Anchored then
		gameOver()
	end

end
