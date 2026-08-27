-- UMAD? --  
-- TODO: Merge the movement and physics code together  -- DONE -- 

-- Need to decide the inherent velocity of game objects -- DONE -- 

-- World Size is always 640x480 -- DONE -- 
-- Place it at the center of the screen regardless of screen resolution -- DONE -- 

--- PRELOAD ASSETS OYUS -- 

Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58449099") -- Background
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58344744") -- ??
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58461425") -- Character
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58462272") -- Character inverse
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58512337") -- Projectile
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58449256") -- Water, I think, 02.png
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58449411") -- Weed
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58450141") -- Water layer 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58450165") -- Water layer 2
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58484376") -- Wave
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58484457") -- Wave 2
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58458224") -- Frame 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58463565") -- ??
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58518986") -- Sea Monster
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58520924") -- Enemy
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58525251") -- Enemy Projectile
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58541175") -- Boss
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58541632") -- Boss
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58541721") -- Boss
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58541762") -- Boss
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58541780") -- Boss
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58546354") -- Fireball
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=58556170") -- Fireball 2 
-- 

local Tool = script.Parent
local RPG = Tool.Handle

Tool.Enabled = true 

local vCharacter
local myTorso 
local myHumanoid

-- Game Toggle
local gameStillOn
local gameDuration = 480 -- 8 minutes to finish the game

-- Coroutines
local co
local respawnCo 
local accelerateCo -- for gravity

-- I like 3, old school
local numberOfLives = 3

-- Gui Stuff
local gameGui
local gameFrame
local gameChar
local RPGFrame
local RPGImage
local lifeLayer
local gameTimeText
local cloudsLeft = {}
local cloudsRight = {}
local cloudAssets = {58482096, 58482106, 58482119, 58482126}

-- Sounds
local projectileSound
local bossSound
local screamSound 

-- Platforms
local maxPlatforms = 7 -- lets cap it at 7, since that's my favorite number
local minPlatforms = 3 -- 3 sounds fine to me
local screenCount = 0

local numPlatforms -- How many were actually created?

local spawnPlatform -- to keep account of where to spawn our character
local spawnPoint = 1.0 -- Left most spawn platform's location 
-- Need to know when to pan the camera to the right to make more platforms  
-- NOTE: This becomes the spawnPlatform for the next screen 
local endScreenPlatform 
local standingOnPlatform = true
local basePlatform

-- Have a table of physics objects, for ease in collision detection and st00f 
local physicsObjects = {} 
local movableObjects = {}
local AIObjects  = {} -- WUT? Easiest thing to classify thingies as living, store 'em!!
local gravity = 0.00384 -- LOL, what a small value eh?
local velocity = Vector2.new(0, 0)
local jumpTimer = 0.0

-- TODO: Pan Camera to generate the world 

-- For GameChar movement
local forwards = false
local backwards = false
local falling = false
local jumping = false
local firing = false
local forcefield  -- To stop spawnKill
local stopFall

-- Projectile
local gameProjectile
local enemyProjectiles = {}
local gameProjectileClones = {}

-- Boolean Toggles 
local accelerateBool = false
local worldScrolling = false
local killCharacter = false
-- 

-- Tentative
local platforms = {}

-- AI
local boss
local seaMonster
local enemies = {}

--------------------------------------------------- OOP STUFF(NOT COMPLETE) ----------------------------------

local World = {} -- Ideally, I want all of the code to be a part of the World class i.e. table
function World:Update() -- Updating the world	
	setCharacterVelocity()
	--projectileCharMovement()
	simulateCharacterPhysics()
	-- Animation
	-- AI	
	moveCharacter()
end 
--------------------------------------------------- PHYSICS ---------------------------------------------------

-- Box Collision Detection
-- Returns if collision can occur
function checkForCollision(worldObject, currentObject, offset)	-- OMG -- 
	local leftMostCurrentObjectX = currentObject.Position.X.Scale + offset.X
	local rightMostCurrentObjectX = currentObject.Position.X.Scale + (5 * currentObject.Size.X.Scale/7) + offset.X
	local topMostCurrentObjectY = currentObject.Position.Y.Scale --[[]] + (2 * currentObject.Size.Y.Scale/7)  + offset.Y
	local bottomMostCurrentObjectY = currentObject.Position.Y.Scale + (5 * currentObject.Size.Y.Scale/7) + offset.Y
	local leftMostWorldObjectX = worldObject.Position.X.Scale
	local rightMostWorldObjectX = worldObject.Position.X.Scale + worldObject.Size.X.Scale
	local topMostWorldObjectY = worldObject.Position.Y.Scale
	local bottomMostWorldObjectY = worldObject.Position.Y.Scale + worldObject.Size.Y.Scale

	if (rightMostCurrentObjectX > leftMostWorldObjectX) and (bottomMostCurrentObjectY > topMostWorldObjectY) 
		and (rightMostWorldObjectX > leftMostCurrentObjectX) and (bottomMostWorldObjectY > topMostCurrentObjectY) then		
		return true
	else 
		return false
	end	
end

-- Steps through the array of physics objects, and computes necessary collision
-- Very basic at the moment
-- Add a space partition perhaps? buckets? 
function simulateCharacterPhysics()	
	stopFall = false
	if #physicsObjects > 0 then 
		if #movableObjects > 0 then 
			for i = 1, #movableObjects do 
				for j = 1, #physicsObjects do 
					if physicsObjects[j] ~= movableObjects[i] then						
						collidedX = checkForCollision(physicsObjects[j], movableObjects[i], Vector2.new(velocity.X, 0))						
						collidedY = checkForCollision(physicsObjects[j], movableObjects[i], Vector2.new(0, velocity.Y))
						if collidedX then velocity = Vector2.new(0, velocity.Y) end
						if collidedY then 
							if velocity.Y < 0 then
								velocity = Vector2.new(velocity.X, 0)
							elseif velocity.Y > 0 then
								velocity = Vector2.new(velocity.X, 0)
								stopFall = true
								basePlatform = physicsObjects[j]
								if basePlatform == endScreenPlatform then 									
									if worldScrolling == false then
										worldScrolling = true 
										coroutine.resume(coroutine.create(scrollWorld))
									end
								end
								falling = false
							end
						end
					end					
				end
				if not stopFall then 
					falling  = true 					
				end				
			end			
		end
	end
	collided = false
end  

function fallAcceleration()	
	while falling do
		gravity = gravity + 2 * gravity * wait()		
		wait()
	end
	gravity = 0.00384
	accelerateBool = false
end  

------------------------------------------------------------------------------------------------------ 

-- To reset the RPG back to its original state and to enable the tool
function waitUntilDone()
	while gameStillOn do
		wait(1)
	end
	destroyGameInterface()
	RPG.Transparency = 0.0
	Tool.Enabled = true
end

----------------------------------------------- ANIMATIONS --------------------------------------------

function linearAnimate(layer, sign)
	local defaultPos = layer.Position 
	while layer do 		
		layer.Position = UDim2.new(layer.Position.X.Scale + sign * 0.005, 0, layer.Position.Y.Scale, 0)
		sign = sign * -1
		wait()
	end
end

function animateClouds()	
	while #cloudsLeft > 0 and #cloudsRight > 0 do 		
		for i = 1, #cloudsLeft do 			
			tick()
			if cloudsLeft[i].Position.X.Scale > 0.94 then				
				cloudsLeft[i].Position = UDim2.new(0.04, 0, math.random(5, 15)/100, 0)
			else
				cloudsLeft[i].Position = cloudsLeft[i].Position + UDim2.new(math.random(3, 5)/1000, 0, 0, 0)
			end
		end
		for i = 1, #cloudsRight do 			
			tick()
			if cloudsRight[i].Position.X.Scale < 0.02 then				
				cloudsRight[i].Position = UDim2.new(0.98, 0, math.random(5, 15)/100, 0)
			else
				cloudsRight[i].Position = cloudsRight[i].Position + UDim2.new(-math.random(4, 6)/1000, 0, 0, 0)
			end
		end
		wait(0.25) 
	end
end

function waveAnimate(waveLayer, waveLayer2)
	local offset = 0.025 
	local sign = 1 
	while waveLayer and waveLayer2 do
		waveLayer.Position = waveLayer.Position +UDim2.new(0, 0, offset * sign, 0)
		--waveLayer2.Position = waveLayer2.Position + UDim2.new(0, 0, offset * - sign, 0)
		sign = sign * - 1
		wait(0.25)
	end
end

--------------------------------------------------- SCROLL WORLD ---------------------------------------
function scrollWorld()	
	for i = 1, #enemies do enemies[i]:Remove() enemies[i] = nil end
	enemies = {}
	while endScreenPlatform.Position.X.Scale > 0.07 do 		
		for i = 1, #platforms do
			if platforms[i] then
				platforms[i].Position = platforms[i].Position - UDim2.new(0.01, 0, 0, 0)
			end
			if platforms[i] == endScreenPlatform then
				gameChar.Position = gameChar.Position - UDim2.new(0.01, 0, 0, 0)
			end
			if platforms[i] and platforms[i] ~= endScreenPlatform and platforms[i].Position.X.Scale <= 0 then 				
				platforms[i]:Remove()				
				table.remove(platforms, i)
			end			
		end	
		wait(0.1)
	end
	if seaMonster then seaMonster:Remove() seaMonster = nil end
	spawnPlatform = endScreenPlatform
	spawnPlatform.Name = "Spawn Platform"
	endScreenPlatform = nil 
	worldScrolling = false			
	createPlatforms()		
end

----------------------------------------------- AI(OYUS!) ----------------------------------------------

function followChar(seaMonster)			
	while seaMonster and gameChar do		
		local direction = Vector2.new(gameChar.Position.X.Scale - seaMonster.Position.X.Scale + (gameChar.Size.X.Scale/2.0 - seaMonster.Size.X.Scale/2.0), 0).unit
		seaMonster.Position = seaMonster.Position + UDim2.new(direction.X * 0.03, 0, 0, 0)
		wait(0.25)
	end
end

function shoot(direction, ball)	
	local collision
	while ball do 			
		ball.Position = ball.Position + UDim2.new((direction.X * 0.035) , 0, (direction.Y * 0.035) ,0) 		
		if ball.Position.X.Scale >= 1 or ball.Position.X.Scale <= 0 or ball.Position.Y.Scale >= 1 or ball.Position.Y.Scale <= 0 then
			ball:Remove() 
			ball = nil
		end
		if ball then
			for i = 1, #physicsObjects do 
				if ball then
					local collision = checkForCollision(physicsObjects[i], ball, Vector2.new(0, 0))
					if collision then ball:Remove() ball = nil end 
				end
			end		
			if ball and gameChar then collision = checkForCollision(gameChar, ball, Vector2.new(0, 0)) end
			if collision and gameChar and not forcefield then 					
				killCharacter = true
				if ball then 
					ball:Remove() 
					ball = nil
				end
			end		
		end
		wait(0.125)		
	end	
end

function shootChar(i)		
	while enemies[i] and enemies[i].Parent and gameChar do 			
		local direction = Vector2.new(gameChar.Position.X.Scale - enemies[i].Position.X.Scale, gameChar.Position.Y.Scale - enemies[i].Position.Y.Scale).unit		
		local ball = Instance.new("ImageLabel")
		ball.Size = UDim2.new(0.03, 0, 0.03, 0)
		ball.Image = "http://www.roblox.com/asset/?id=58525251"
		ball.Parent = gameFrame
		ball.Name = "Ball"
		ball.Position = enemies[i].Position - UDim2.new(0.04, 0, 0, 0)
		ball.BackgroundTransparency = 1.0		
		table.insert(enemyProjectiles, ball)				
		coroutine.resume(coroutine.create(function() shoot(direction, ball) end))
		wait(3.0)				
	end
end

function rainFire(fireball)	
	local collision
	while fireball and boss do		
		fireball.Position = fireball.Position + UDim2.new(0, 0, 0.01, 0)
		if gameChar then 
			collision = checkForCollision(gameChar, fireball, Vector2.new(0, 0)) 
		end
		if collision and gameChar and not forcefield then			
			killCharacter = true 
			if fireball then 
				fireball:Remove() 
				fireball = nil 
			end
		end					
		if fireball and fireball.Position.Y.Scale > 1.0 then fireball:Remove() fireball = nil end
		wait()		
	end	
end

function spawnFireball()
	wait(3.0)
	while gameChar and boss do
		pos = gameChar.Position.X.Scale 
		local fireball = Instance.new("ImageLabel")
		fireball.Name = "FireBall"
		fireball.Parent = gameFrame
		fireball.Image = "http://www.roblox.com/asset/?id=58546354"
		fireball.BackgroundTransparency = 1.0
		fireball.Size = UDim2.new(0.05, 0, 0.1, 0)
		fireball.Position = UDim2.new(pos, 0, 0, 0)
		coroutine.resume(coroutine.create(function() rainFire(fireball) end))
		wait(math.random(2, 3))
	end
end

function laserify(laser, direction)	
	print("Laserifying")
	local collision
	while laser and boss do		
		laser.Position = laser.Position + UDim2.new(direction.X * 0.02, 0, direction.Y * 0.02, 0)
		if gameChar then 
			collision = checkForCollision(gameChar, laser, Vector2.new(0, 0)) 
		end
		if collision and gameChar and not forcefield then			
			killCharacter = true 
			if laser then 
				laser:Remove() 
				laser = nil 
			end
		end	
		for i = 1, #physicsObjects do 
			if laser then
				local collision = checkForCollision(physicsObjects[i], laser, Vector2.new(0, 0))
				if collision then 
					laser:Remove() 
					laser = nil 
				end 
			end
		end		
		if laser and laser.Position.X.Scale < 0.0 then laser:Remove() laser = nil end
		wait()		
	end	
end

function fireLaser()
	print("Firing Laser")
	wait(4.0)
	while gameChar and boss do
		direction = Vector2.new(gameChar.Position.X.Scale - boss.Position.X.Scale, gameChar.Position.Y.Scale - boss.Position.Y.Scale)
		local laser = Instance.new("ImageLabel")
		laser.Name = "Laser"
		laser.Parent = gameFrame
		laser.Image = "http://www.roblox.com/asset/?id=58556170"
		laser.BackgroundTransparency = 1.0
		laser.Size = UDim2.new(0.05, 0, 0.05, 0)
		laser.Position = boss.Position + UDim2.new(-0.1, 0, 0, 0)
		print("Starting laserify")
		coroutine.resume(coroutine.create(function() laserify(laser, direction) end))
		print("Coroutine spawned")
		wait(math.random(2, 3))
	end
end

function bossBattle()
	local perpY = 0.02 
	if boss then
		print("Found boss")
		coroutine.resume(coroutine.create(spawnFireball))			
		while boss do 
			if boss.Position.Y.Scale > 0.50 then 
				perpY = -0.02 
			elseif boss.Position.Y.Scale < 0.25 then 
				perpY = 0.02 
			end
			boss.Position = boss.Position + UDim2.new(0, 0, perpY, 0)
			wait(0.25)
		end
	end
end

function updateBoss()
	if boss then
		health = boss:FindFirstChild("Health")
		if health then
			if health.Value >= 300 and health.Value < 400 then
				boss.Image = "http://www.roblox.com/asset/?id=58541632"
			elseif health.Value > 200 and health.Value < 300 then 
				boss.Image = "http://www.roblox.com/asset/?id=58541721"
			elseif health.Value > 100 and health.Value < 200 then
				boss.Image = "http://www.roblox.com/asset/?id=58541762"
			elseif health.Value > 0 and health.Value < 100 then
				boss.Image = "http://www.roblox.com/asset/?id=58541780"
			end
			-- FIRING MAH LASER 
			if health.Value < 200 then 
				coroutine.resume(coroutine.create(fireLaser))				
			end
		end
	end
end

function spawnAI()	
	print("Spawning AI")
	if screenCount == 7 then 
		if endScreenPlatform then 
			endScreenPlatform:Remove() 
			endScreenPlatform = nil 
		end
		for i = 1, #platforms do
			if platforms[i].Position.X.Scale > 0.50 then 
				for j = 1, #physicsObjects do 
					if platforms[i] == physicsObjects[j] then 
						table.remove(physicsObjects, j)
					end
				end
				platforms[i]:Remove()				
			end
		end
		if spawnPlatform then 
			spawnPlatform.Position = spawnPlatform.Position + UDim2.new(0, 0, 0.25, 0)
			if gameChar then 
				gameChar.Position = gameChar.Position + UDim2.new(0, 0, 0.25, 0)
			end
		end
		boss = Instance.new("ImageLabel")
		boss.Name = "Boss"
		boss.Image = "http://www.roblox.com/asset/?id=58541175"
		boss.Size = UDim2.new(0.3, 0, 0.3, 0)
		boss.Position = UDim2.new(0.70, 0, 0.35, 0)
		boss.BackgroundTransparency = 1.0
		boss.ZIndex = 2.0 
		boss.Parent = gameFrame

		health = Instance.new("NumberValue")
		health.Name = "Health"
		health.Parent = boss
		health.Value = 500
		health.Changed:connect(updateBoss)

		coroutine.resume(coroutine.create(function() bossBattle() end))
		elseif screenCount < 7 and screenCount > 0 then 		
		seaMonster = Instance.new("ImageLabel")
		seaMonster.Name = "Sea Monster"
		seaMonster.Image = "http://www.roblox.com/asset/?id=58518986"
		seaMonster.Size = UDim2.new(0.2, 0, 0.2, 0)
		seaMonster.Position = UDim2.new(math.random(25, 75)/100, 0, 0.79, 0)
		seaMonster.Parent = gameFrame
		seaMonster.BackgroundTransparency = 1.0
		seaMonster.ZIndex = 4.0
		table.insert(AIObjects , seaMonster)	

		coroutine.resume(coroutine.create(function() followChar(seaMonster) end))		
		
		tick()			 
		for i = 1, 2 do 
			enemies[i] = Instance.new("ImageLabel")
			enemies[i].Name = "Enemy"
			enemies[i].Image = "http://www.roblox.com/asset/?id=58520924"
			enemies[i].Size = UDim2.new(0.1, 0, 0.1, 0)
			enemies[i].Parent = gameFrame
			enemies[i].BackgroundTransparency = 1.0
			enemies[i].Position = platforms[(i+1) + (i-1) * math.random(1, 2)].Position + UDim2.new(0, 0, -0.075, 0)				
			coroutine.resume(coroutine.create(function() wait(3.0) shootChar(i) end))

			health = Instance.new("NumberValue")
			health.Name = "Health"
			health.Value = 35
			health.Parent = enemies[i]
		end		
	else
		-- do nothing
	end
end

----------------------------------------------- GUI CODE -----------------------------------------------

function createPlatforms()
	tick()
	local posX = {math.random(18, 20)/100, math.random(34, 40)/100, math.random(52, 60)/100, math.random(72, 76)/100}
	local posY = {math.random(28, 40)/100, math.random(30, 46)/100, math.random(30, 32)/100, math.random(24, 28)/100}		
	screenCount = screenCount + 1	
	endScreenPlatform = Instance.new("ImageLabel")
	endScreenPlatform.Name = "EndScreenPlatform"
	endScreenPlatform.Image = "http://www.roblox.com/asset/?id=58344744"
	endScreenPlatform.Size = UDim2.new(0.10, 0, 0.025, 0)	
	endScreenPlatform.Position = UDim2.new(math.random(85, 92)/100,  0, math.random(15, 24)/100, 0)
	endScreenPlatform.Parent = gameFrame
	table.insert(platforms, endScreenPlatform)
	table.insert(physicsObjects, endScreenPlatform)
	
	-- initialize the world with 5 platforms? maybe?
	tick()
	--numPlatforms = math.random(minPlatforms, maxPlatforms - 2)
	numPlatforms = 4	
	for i = 1, numPlatforms do
		tick() -- seed that random!
		-- The platforms can never be lower than 60, unless you want to get eaten by the shark
		-- Or higher than 15 since we need to accomodate our character		
		local pf = Instance.new("ImageLabel")
		pf.Name = "Platform"
		pf.Image = "http://www.roblox.com/asset/?id=58344744"
		pf.Size = UDim2.new(0.1, 0, 0.025, 0)
		-- Another criteria to consider, can the platforms never be right on top of each other? Maybe?
		pf.Position = UDim2.new(posX[i],  0, posY[i], 0)
		pf.Parent = gameFrame
		table.insert(platforms, pf)
		table.insert(physicsObjects, pf)				
	end
	-- Create Character to control
	createLocalCharacter()

	-- Spawn a bunch of enemies
	spawnAI()
end

function createGameInterface()
	gameGui = Instance.new("ScreenGui")
	gameGui.Parent = game.Players.LocalPlayer.PlayerGui
	gameGui.Name = "Game Gui"

	gameFrame = Instance.new("Frame")
	gameFrame.Parent = gameGui	
	while gameGui.AbsoluteSize.X == 0 do wait() end -- WUT?
	local screenMidPoint = Vector2.new(gameGui.AbsoluteSize.x/2.0, gameGui.AbsoluteSize.y/2.0)	
	gameFrame.Position = UDim2.new(0, screenMidPoint.X - 320, 0, screenMidPoint.Y - 240)
	gameFrame.Size = UDim2.new(0, 640, 0, 480)
	gameFrame.BackgroundTransparency = 1.0
	gameFrame.Name = "Game Frame"

	local gameBackground = Instance.new("ImageLabel")
	gameBackground.Image = "http://www.roblox.com/asset/?id=58449099"
	gameBackground.Size = UDim2.new(1, 0, 1, 0)
	gameBackground.Parent = gameFrame
	gameBackground.BackgroundTransparency = 1.0
	gameBackground.Name = "Background"

	RPGImage = Instance.new("ImageLabel")
	RPGImage.Parent = gameFrame
	RPGImage.Name = "RPG Image"
	RPGImage.Image = "http://www.roblox.com/asset/?id=58458224"
	RPGImage.Position = UDim2.new(-0.3378, 0, -0.2, 0)
	RPGImage.Size = UDim2.new(1.669, 0, 1.38, 0)
	RPGImage.BackgroundTransparency = 1.0
	RPGImage.ZIndex = 10.0

	local gameWater

	local gameWeed = Instance.new("ImageLabel")
	gameWeed.Image = "http://www.roblox.com/asset/?id=58449411"
	gameWeed.Name = "SeaWeed"
	gameWeed.Size = UDim2.new(1, 0, 1, 0)
	gameWeed.Parent = gameFrame
	gameWeed.BackgroundTransparency = 1.0
	gameWeed.Position = UDim2.new(0, 0, 0, 0)

	local waterLayer = Instance.new("ImageLabel")
	waterLayer.Image = "http://www.roblox.com/asset/?id=58450141"
	waterLayer.Name = "WaterLayer2"
	waterLayer.Size = UDim2.new(1, 0, 1, 0)
	waterLayer.Parent = gameFrame
	waterLayer.BackgroundTransparency = 1.0
	waterLayer.Position = UDim2.new(0, 0, 0, 0)

	coroutine.resume(coroutine.create(function() linearAnimate(waterLayer, 1) end))

	local waterLayer2 = Instance.new("ImageLabel")
	waterLayer2.Image = "http://www.roblox.com/asset/?id=58450165"
	waterLayer2.Name = "WaterLayer2"
	waterLayer2.Size = UDim2.new(1, 0, 1, 0)
	waterLayer2.Parent = gameFrame
	waterLayer2.BackgroundTransparency = 1.0
	waterLayer2.Position = UDim2.new(0, 0, 0, 0)
	coroutine.resume(coroutine.create(function() linearAnimate(waterLayer2, -1) end))

	local waveLayer = Instance.new("ImageLabel")
	waveLayer.Name = "Wave"
	waveLayer.Image = "http://www.roblox.com/asset/?id=58484376"
	waveLayer.Size = UDim2.new(1, 0, 1, 0)
	waveLayer.Parent = gameFrame
	waveLayer.BackgroundTransparency = 1.0
	waveLayer.Position = UDim2.new(0, 0, 0, 0) 	
	
	local waveLayer2 = Instance.new("ImageLabel")
	waveLayer2.Name = "Wave2"
	waveLayer2.Image = "http://www.roblox.com/asset/?id=58484457"
	waveLayer2.Size = UDim2.new(1, 0, 1, 0)
	waveLayer2.Parent = gameFrame
	waveLayer2.BackgroundTransparency = 1.0
	waveLayer2.Position = UDim2.new(0, 0, 0, 0) 
	
	coroutine.resume(coroutine.create(function() waveAnimate(waveLayer, waveLayer2) end))

	lifeLayer = Instance.new("ImageLabel")
	lifeLayer.Image = "http://www.roblox.com/asset/?id=58463565"
	lifeLayer.Name = "Lives"
	lifeLayer.Size = UDim2.new(0.13, 0, 0.05, 0)
	lifeLayer.Position = UDim2.new(0.03, 0, 0.01, 0)
	lifeLayer.BackgroundTransparency = 1.0
	lifeLayer.Parent = gameFrame
	lifeLayer.ZIndex = 2.0	

	gameTimeText = Instance.new("TextLabel")
	gameTimeText.Text = tostring(gameDuration)
	gameTimeText.Parent = gameFrame
	gameTimeText.Position = UDim2.new(0.96, 0, 0.01, 0)

	-- Clouds, 7 of em
	for i = 1, 7 do 
		tick()
		cloud = Instance.new("ImageLabel")
		cloud.Name = "Cloud"
		cloud.Image = "http://www.roblox.com/asset/?id=" .. cloudAssets[math.random(1, 4)]
		cloud.ZIndex = 1.0
		cloud.Parent = gameFrame 
		cloud.Size = UDim2.new(0.1, 0, 0.04, 0)
		cloud.BackgroundTransparency = 1.0
		leftRight = math.random(1, 2)
		if leftRight == 1 then 
			table.insert(cloudsLeft, cloud)			
		else
			table.insert(cloudsRight, cloud)
		end		
		cloud.Position = UDim2.new(math.random(10, 90)/100, 0, math.random(5, 15)/100, 0)
	end

	coroutine.resume(coroutine.create(animateClouds))
	-- PLATFORMS -- 
	-- Special case, since when the world scrolls, the end platform becomes the spawning one
	spawnPlatform = Instance.new("ImageLabel")
	spawnPlatform.Name = "SpawnPlatform"
	spawnPlatform.Image = "http://www.roblox.com/asset/?id=58344744"
	spawnPlatform.Size = UDim2.new(0.1, 0, 0.025, 0)	
	spawnPlatform.Position = UDim2.new(0.05,  0, 0.19, 0)
	spawnPlatform.Parent = gameFrame
	table.insert(platforms, spawnPlatform)
	table.insert(physicsObjects, spawnPlatform)	
	
	print("Creating platforms")
	----------------------
	createPlatforms()
	----------------------

	-- Create the default projectile, can't think of a better place to put this
	gameProjectile = Instance.new("ImageLabel")
	gameProjectile.Image = "http://www.roblox.com/asset/?id=58512337"
	gameProjectile.Size = UDim2.new(0.020, 0, 0.020, 0)
	gameProjectile.BackgroundTransparency = 1.0
	gameProjectile.Name = "CharProjectile"		
end

function createLocalCharacter()
	if not gameChar then
		forcefield = true
		gameChar = Instance.new("ImageLabel")
		gameChar.BackgroundTransparency = 1.0
		gameChar.Image = "http://www.roblox.com/asset/?id=58461425"
		gameChar.Size = UDim2.new(0.03, 0, 0.1, 0) -- Wut? 
		gameChar.Name = "Hero"
		gameChar.ZIndex = 1.0
		-- Need to spawn the character on one of the platforms always 
		-- Ideally the leftmost platform in which case it's width value is the lowest
		--table.insert(physicsObjects, gameChar)
		movableObjects = {}
		table.insert(movableObjects, gameChar)
		if  #platforms > 0 then 
			gameChar.Position = spawnPlatform.Position - UDim2.new(0, 0, 0.075, 0)
		end
		if gameFrame then gameChar.Parent = gameFrame end	
		coroutine.resume(coroutine.create(function() wait(1.5) forcefield = false end))
	end
end

----------------------------------------------------------------------------------------------

function destroyGameInterface()
	if gameGui then gameGui:Remove() gameGui = nil end
	movableObjects = {}
	physicsObjects = {}
	platforms = {}
	if spawnPoint then spawnPoint = 1.0 end
end

----------------------------------------------- MOVEMENT --------------------------------------
function moveCharacter()	
	if not worldScrolling then	-- freeze character, if the world is scrolling 
		pos = Vector2.new(gameChar.Position.X.Scale, gameChar.Position.Y.Scale)	
		if velocity then		
			if pos.Y + velocity.Y < 0 then
				gameChar.Position = gameChar.Position + UDim2.new(velocity.X, 0, 0, 0)		
			else 		
				gameChar.Position = gameChar.Position + UDim2.new(velocity.X, 0, velocity.Y, 0)
			end
		end
	end
end

function setCharacterVelocity()	
	if gameChar then		
		velocity = Vector2.new(0, 0)
		if forwards then 
			gameChar.Image = "http://www.roblox.com/asset/?id=58461425"			
			velocity = velocity + Vector2.new(0.005, 0)
		elseif backwards then 
			gameChar.Image = "http://www.roblox.com/asset/?id=58462272"				
			velocity = velocity - Vector2.new(0.005, 0)
		end
		if falling then 
			if accelerateBool == false then 
				accelerateBool = true
				accelerateCo = coroutine.create(fallAcceleration)
				coroutine.resume(accelerateCo) 
			end			
			velocity = velocity + Vector2.new(0, gravity)
		end
		if jumping then 			
			velocity = velocity - Vector2.new(0, 0.020)
		end
	end
end

function gameCharMovementStop(key)	
	if gameChar then
		key = key:lower()		
		if key == "w" then
			jumping = false
		elseif key =="a" then 
			backwards = false
		elseif key == "d" then
			forwards = false		
		end
	end
end

function gameCharMovementStart(key)	
	local timeNow
	if gameChar then		
		key = key:lower()			
		if key == "w" then 
			timeNow = tick()
			if timeNow - jumpTimer > 1.0 then					
				jumpTimer = timeNow
				jumping = true			
			end					
		elseif key == "a" then		
			backwards = true		
		elseif key == "d" then 		
			forwards = true							
		end
	end
end

----------------------------------------------- CHARACTER FIRING -----------------------------------------------

function transferToWorldCoordinates(mouse)
	if gameFrame then 
		local xPos = mouse.X - gameFrame.Position.X.Offset 
		local yPos = mouse.Y - gameFrame.Position.Y.Offset
		return Vector2.new(xPos, yPos)
	end
end

function fire(projectileClone, direction)	
	local collision
	-- Lets set the velocity to be 2 units 
	while projectileClone do 		
		projectileClone.Position = projectileClone.Position + UDim2.new((direction.X * 0.02), 0, (direction.Y * 0.02), 0)		
		if projectileClone.Position.X.Scale >= 1 or projectileClone.Position.X.Scale <= 0 or projectileClone.Position.Y.Scale >= 1 or projectileClone.Position.Y.Scale <= 0 then
			projectileClone:Remove() 
			projectileClone = nil
		end
		for i = 1, #physicsObjects do 
			if projectileClone then collision = checkForCollision(physicsObjects[i], projectileClone, Vector2.new(0, 0)) end
			if collision then if projectileClone then projectileClone:Remove() projectileClone = nil end end 
		end
		for i = 1, #enemies do 			
			if projectileClone then collision = checkForCollision(enemies[i], projectileClone, Vector2.new(0, 0)) end
			if collision and projectileClone then 
				projectileClone:Remove()
				projectileClone = nil
				health = enemies[i]:FindFirstChild("Health")				
				if health and health.Value > 0 then 						
					health.Value = health.Value - 17
				else 
					enemies[i]:Remove() 
					--enemies[i] = nil
				end				
			end 
		end
		if projectileClone and boss then
			collision = checkForCollision(boss, projectileClone, Vector2.new(0, 0))
			if collision and projectileClone then 
				projectileClone:Remove()
				projectileClone = nil
				health = boss:FindFirstChild("Health")
				if health and health.Value > 0 then 
					health.Value = health.Value - 17
				else 
					boss:Remove()	
					boss = nil
					-- End the Game
					worldScrolling = true 
					win = Instance.new("TextLabel")
					win.Parent = gameFrame
					win.Text = "YOU WON"
					win.TextColor3 = Color3.new(1.0, 0.0, 0.0)
					win.Position = UDim2.new(0.5, 0, 0.5, 0)
					win.ZIndex = 10.0
					win.FontSize = Enum.FontSize.Size24
				end
			end
		end
		wait()		
	end
end

function gameCharFire(mouse)
	if mouse and gameProjectile and firing == false and gameChar then 
		firing = true
		local projectileClone = gameProjectile:Clone()
		local mouseInWorld = transferToWorldCoordinates(mouse)
		local gameCharPos = transferToWorldCoordinates(gameChar.AbsolutePosition)
		if mouseInWorld and mouseInWorld.X > gameCharPos.X then
			gameChar.Image = "http://www.roblox.com/asset/?id=58461425"
			projectileClone.Position = gameChar.Position + UDim2.new(0.03, 0, 0.025, 0)
		else 
			gameChar.Image = "http://www.roblox.com/asset/?id=58462272"
			projectileClone.Position = gameChar.Position + UDim2.new(-0.03, 0, 0.025, 0)
		end
		projectileClone.Parent = gameFrame
		table.insert(gameProjectileClones, projectileClone)
		-- GROSS
		-- Need to plug stuff into a generic physics engine
		-- Next on the plate, hopefully 
		local direction = (mouseInWorld - gameCharPos).unit
		if projectileSound then projectileSound:Play() end
		coroutine.resume(coroutine.create(function() fire(projectileClone, direction) end))			
		wait(0.75)
		firing = false
	end
end

----------------------------------------------- TOOL EVENTS -----------------------------------------------

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	
	Tool.Enabled = false 
	
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	if myTorso and myHumanoid then 
		wait(0.2)
		myTorso.Anchored = true
		myHumanoid.WalkSpeed = 0.0
	end
	projectileSound = RPG:FindFirstChild("ProjectileSound")
	bossSound = RPG:FindFirstChild("BossSound")
	screamSound = RPG:FindFirstChild("ScreamSound")
	gameSound = RPG:FindFirstChild("GameSound")
	numberOfLives = 3
	RPG.Transparency = 1.0
	if gameSound then gameSound:Play() end	
	gameStillOn = true	
	createGameInterface()	
	co = coroutine.create(waitUntilDone)
	coroutine.resume(co)
	gameUpdate()	
end

function onEquipped(mouse)
	if mouse then 		
		mouse.KeyDown:connect(gameCharMovementStart)
		mouse.KeyUp:connect(gameCharMovementStop)
		mouse.Button1Down:connect(function () gameCharFire(mouse) end)
	end
end

function onUnequipped()
	gameStillOn = false 
	if myTorso then myTorso.Anchored = false end	
	if myHumanoid then myHumanoid.WalkSpeed = 16.0 end
	RPG.Transparency = 0.0
	forwards = false
	backwards = false
	falling = false
	jumping = false
	firing = false	
	stopFall = false
	killCharacter = false
	worldScrolling = false
	screenCount = 0
	velocity = Vector2.new(0, 0)
	gravity = 0.0384
	gameDuration = 240
	jumpTimer = 0.0
	boss = nil
	enemies = {}
	destroyGameInterface() 
	if bossSound then bossSound:Stop() end
	if gameSound then gameSound:Stop() end
end 

-- Event Listeners 
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)

----------------------------------------------- GAME UPDATE FUNCTION --------------------------------------------

function gameUpdate()	
	while gameStillOn and gameDuration > 0 do
		World:Update()		
		gameDuration = gameDuration - wait()
		gameTimeText.Text = tostring(math.floor(gameDuration))
		if gameDuration < 60 then 
			gameTimeText.TextColor3 = Color3.new(255, 0, 0)
		end
		if gameChar.Position.Y.Scale > 0.7 then
			if screamSound then screamSound:Play() end
		end
		if gameChar.Position.Y.Scale > 0.85 or killCharacter == true then 			
			killCharacter = false			
			gameChar.Image = "http://www.roblox.com/asset/?id=58551023"						
			wait(1.0)
			gameChar:Remove()
			gameChar = nil
			if numberOfLives > 0 then 
				numberOfLives = numberOfLives - 1 
				if numberOfLives == 2 then 
					lifeLayer.Image = "http://www.roblox.com/asset/?id=58463962"
				elseif numberOfLives == 1 then 
					lifeLayer.Image = "http://www.roblox.com/asset/?id=58463982"
				else 
					lifeLayer.Image = "" 
				end
				createLocalCharacter()	
			else 
				lose = Instance.new("TextLabel")
				lose.Parent = gameFrame
				lose.Text = "YOU LOSE"
				lose.Position = UDim2.new(0.5, 0, 0.5, 0)
				lose.TextColor3 = Color3.new(0, 0, 1.0)
				lose.ZIndex = 10.0
				lose.FontSize = Enum.FontSize.Size24
				wait(3.0)
				gameStillOn = false 
			end						
			falling = false
			stopFall = true
		end
		wait() -- NO CRASH 
	end
	jumpTimer = 0.0
	screenCount = 0
	killCharacter = false
	forwards = false
	backwards = false
	falling = false
	jumping = false
	firing = false
	stopFall = false
	worldScrolling = false
	boss = nil
	enemies = {}
	gameDuration = 480
	velocity = Vector2.new(0, 0)
	gravity = 0.0384
	if bossSound then bossSound:Stop() end
	if gameSound then gameSound:Stop() end
end

----------------------------------------------- THE END(PEACE!!) -----------------------------------------------
