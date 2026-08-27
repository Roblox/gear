-- Game BG size is 800x600 

-- With 45 small blocks, only getting about 8 FPS, not good -- need to spatial partition the physics objects

-- Version 0.11 -- Elastic bodies

-- Version 0.2 -- making collision boxes to 100% 

-- Version 0.21 -- decoupled the character movement from the physics

-- Version 0.3 -- Quad Tree based physics 

-- Version 0.4 -- decoupled/removed the Quad Tree physics as the game requires less moving bodies, and less bugs 

-- Version 0.41 -- Added functional sprites for characters in the game, need to make this a generic class 

-- Version 0.45 -- Re-coupled the character movement to the physics and added health bar

-- Version 0.5 -- Now the world scrolls! 

-- Version 0.55 -- Added projectiles as separate things from the physics system, this isn't ideal. Need to couple it with the physics system and use a touch event 

-- Version 0.60 -- Added the clone boss to the game, and fixed lots of little bugs 

-- Version 0.70 -- Initiating the Water and Desert Levels 

-- Version 0.80 -- Medusa boss fight!

-- Version 0.90 -- Melee Enemies and 2 level scrolling 

-- Version 1.0 --  Sun boss fight and bug fixes


local Tool = script.Parent
local RPG = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

Tool.Enabled = true

--- PRELOAD ASSETS OYUS -- 

Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=65908682") -- Grass Mountains
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=65915569") -- Main Character
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=65909301") -- Grass Sky Image
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=65911902") -- Grass Level Ground
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=59460030") -- Block
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=59620891") -- Block
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=59620923") -- Block
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=59620949") -- Block
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=61243294") -- Circle
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=65910153") -- Sun

Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66188209") -- Melee Bot 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66188274") -- Melee Bot swing

Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66189603") -- Ranged enemy
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66189620") -- Float
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66189699") -- Projectile
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66189656") -- Enemy Hand 

-- Water Level 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225675") -- Water Sun
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225731") -- Water level Sky 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225756") -- Water level Rocks Close
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225894") -- Water level Rocks Mid
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225914") -- Water level Rocks far
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225949") -- Water level Plants 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225966") 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225981") 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66225995") 

-- Sand Level 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66356580") -- Desert Sun
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66226104") -- Desert Sky 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66226069") -- Desert Floor 
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66226112") -- Desert dunes close
Game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=66226129") -- Desert dunes far
-- Bosses
----------------------------------------------------------------------- 
-- Game Stuff
local gameScreen
local gameBackground
local gameBackground2
local gameFrame 
local gameChar
local gameCharObj
local gameFloor
local skyFrame
local sunImage

local gameBackground3 
local gameBackground4

local waterLevelRocksClose
local waterLevelRocksClose2
local waterLevelRocksMid
local waterLevelRocksMid2
local waterLevelRocksFar
local waterLevelRocksFar2

local gameCharHealthbarAssets = {66298629, 66298644, 66298656, 66298686, 66298698, 66298712}

for i = 1, #gameCharHealthbarAssets do 
	game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=" ..  gameCharHealthbarAssets[i]) 
end

local gameProjectile

local gameFloorObj = {}
local gameFloorObj2 = {}

local gameIntroScreen
local gameStartButton

local enemies = {}
enemies.NumEnemies = 0

local characterSprites = {65915569, 
	65915609, 
	65915569, 
	65915630}

characterSprites["Jumping"] = 65915653 
characterSprites["Default"] = 65915569 

local meleeEnemySprites = {66197277} -- 66194981} 
meleeEnemySprites["Attack"] = 66195009 

local rangedEnemySprites = {66189603, 66189620}
rangedEnemySprites["Attack"] = 66189656
rangedEnemySprites["Projectile"] = 66189699 

local cloneBossSprites = {66243554, 66243575, 66243591, 66243609} 
cloneBossSprites["Jumping"] = 66243524 
cloneBossSprites["Default"] = 66243554
cloneBossSprites["Attack"] = 66249162 

for i, assetId in pairs(cloneBossSprites) do 
	game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=" .. assetId)
end

local enemyProjectiles = {}
local gameProjectileClones = {}


-- Coroutines -- Here they come
local jumpCo

-- Game World
local World = {}
World.BossActive = false
World.SpawnAllowed = true
World.LivesRemaining = 3
World.CloneBossObj = {}
World.MedusaBossObj = {}
World.SunBossObj = {}
World.LevelName = "Grass" 
World.WorldDistance = 8.25 -- 8.0

World.Platforms = {}

-- Physics Objects
local physicsObjects = {}
local gravity = 0.000981

-- Assume that the origin is in the center of the world

-- Right now defining the quad size as 1/10 of the size of the screen minimum 
-- that would give us about a 100 nodes total in the QuadTree

local Node = {}
local QuadTree = {}   
QuadTree.MinQuadSize = 0.05
QuadTree.RootNode = nil

function Node:new(x1, y1, x2, y2, parent, name)
	local node = {}
	node.x1 = x1
	node.x2 = x2
	node.y1 = y1
	node.y2 = y2	

	node.Area = (x2 - x1) * (y2 - y1) 
	
	node.Objects = {} -- List of game objects that the given quad contains
	node.Parent = parent -- Parent node of the object , for root node this would be nil 	
	if name == nil or parent == nil then 
		node.Name = "Root" 
	else 
		node.Name = parent.Name .. name
	end 
	print(node.Name, " - ",  node.x1, node.x2, node.y1, node.y2)
	table.insert(QuadTree, node)
	node.Children = QuadTree:ComputeChildren(node) -- 4 children per level 
	return node
end

-- Given a frame or image Gui, this splits it up into regions and returns the tree 
function QuadTree:CreateTree(img)
	local rootNode = Node:new(0, 0, img.Size.X.Scale, img.Size.Y.Scale, nil, "Root")	
	return rootNode 
end 

function QuadTree:ComputeChildren(node)	
	-- Quad Size area is 0.05, i.e the minimum quad size relative is 0.125 
	if node.Area < QuadTree.MinQuadSize then return end 

	local midPoint = Vector2.new((node.x1 + node.x2)/2.0, (node.y1 + node.y2)/2.0)
	local n1 = Node:new(node.x1, node.y1, midPoint.X, midPoint.Y, node, "T1")
	local n2 = Node:new(midPoint.X, node.y1, node.x2, midPoint.Y, node, "T2")
	local n3 = Node:new(node.x1, midPoint.Y, midPoint.X, node.y2, node, "D1")
	local n4 = Node:new(midPoint.X, midPoint.Y, node.x2, node.y2, node, "D2")
	
	return {n1, n2, n3, n4} -- Return a table of children
end

function QuadTree:PrintTree(node)
	if node == nil then 
		node = QuadTree.RootNode				
		print(QuadTree.RootNode)
	end
	-- Iterate through the tree 
	--print(node.Name)
	if node.Children and #node.Children > 0 then
		for i = 1, #node.Children do
			QuadTree:PrintTree(node.Children[i])
		end
	end
end

function QuadTree:InsertObjectIntoQuad(object, quad)
	if quad == nil then 
		print("So, we are inserting to a nil parent, so find the parent!") 	
		local objectCoordinates = {Vector2.new(object.Position.X.Scale, object.Position.Y.Scale)}		
	end
end

function QuadTree:RemoveObjectFromQuad(object, quad)
	if quad == nil then 
		print("Can't remove the object, its not found in the tree in the first place!") 
	end
end
--
local worldSpace = {} -- The entire grid 

-- Box Collision
function checkForCollision(object, object2, offset) -- Need to add in the effects of velocity 
	local leftMostOfObject = object.Position.X.Scale --[[+ object.Size.X.Scale]] + offset.X
	local rightMostOfObject = object.Position.X.Scale + (10/10 * object.Size.X.Scale) + offset.X
	local topMostOfObject = object.Position.Y.Scale --[[+(1/10 * object.Size.Y.Scale)]] + offset.Y
	local bottomMostOfObject = object.Position.Y.Scale + (10/10 * object.Size.Y.Scale) + offset.Y
	
	local leftMostOfObject2 = object2.Position.X.Scale 
	local rightMostOfObject2 = object2.Position.X.Scale + object2.Size.X.Scale
	local topMostOfObject2 = object2.Position.Y.Scale 
	local bottomMostOfObject2 = object2.Position.Y.Scale + object2.Size.Y.Scale

	if (rightMostOfObject > leftMostOfObject2) and (bottomMostOfObject > topMostOfObject2) 
		and (rightMostOfObject2 > leftMostOfObject) and (bottomMostOfObject2 > topMostOfObject) then	
		return true
	else 		
		return false
	end	
end 

-- For circle collision, assume that its being fed square GUIs, otherwise, disaster strikes, so hard
function checkForCircleCollision(object, object2, offset)
	local r1 = object.Size.X.Scale/2.0 -- 
	local r2 = object2.Size.X.Scale/2.0

	local diff = math.abs((object.Position.X.Scale + offset.X - object2.Position.X.Scale) * 2.0) + math.abs((object.Position.Y.Scale + offset.Y - object2.Position.Y.Scale) * 2.0) 
	
	if diff < r1 + r2 then 		
	end
end

function resolveCollision(object, object2, offset)	
	local correctionVector = Vector2.new(0, 0) -- The direction in which this collision is going to push this object
	local leftMostOfObject = object.Position.X.Scale --[[+ (1/10 * object.Size.X.Scale)]] + offset.X
	local rightMostOfObject = object.Position.X.Scale + (10/10 * object.Size.X.Scale) + offset.X 
	local topMostOfObject = object.Position.Y.Scale --[[+ (1/10 * object.Size.Y.Scale)]] + offset.Y
	local bottomMostOfObject = object.Position.Y.Scale + (10/10 * object.Size.Y.Scale) + offset.Y

	local leftMostOfObject2 = object2.Position.X.Scale 
	local rightMostOfObject2 = object2.Position.X.Scale + object2.Size.X.Scale
	local topMostOfObject2 = object2.Position.Y.Scale 
	local bottomMostOfObject2 = object2.Position.Y.Scale + object2.Size.Y.Scale

	local x1 = rightMostOfObject - leftMostOfObject2 
	local x2 = -leftMostOfObject + rightMostOfObject2 
	local y1 = bottomMostOfObject - topMostOfObject2 
	local y2 = -topMostOfObject + bottomMostOfObject2

	local directionX = math.min(math.abs(x1), math.abs(x2))
	local directionY = math.min(math.abs(y1), math.abs(y2))

	if directionX < directionY then		
		if directionX == math.abs(x1) then			
			correctionVector = correctionVector + Vector2.new(-x1, 0)
		elseif directonX == math.abs(x2) then
			correctionVector = correctionVector + Vector2.new(x2, 0)
		end
	elseif directionY < directionX  then 		
		if directionY == math.abs(y1) then 			
			correctionVector = correctionVector + Vector2.new(0, -y1)
		elseif directionY == math.abs(y2) then			
			correctionVector = correctionVector + Vector2.new(0, y2)
		end
	end	
	return correctionVector
end

-- O(N^2) problem 
-- If N > 40, there is delay 
-- The general cap seems to be around 37 objects, tested in multiple machines
-- i.e Can't do more than 35*35 = 1225 collision checks a frame 
-- With QuadTree this becomes a lot nicer, about 70 - 80 objects should be supported
-- 75 log 75 base 2 should be 75 * 8, around 600 checks 
-- But of course we are introducing the overhead of inserting and removing from the region Quad Tree 
-- Still should be a LOT better once done 
-- NOTE: The draw calls are crazy expensive since they are drawn regardless of whether they will be visible or not 

function World:SimulatePhysics()
	-- Have to check for collision between themselves
	for i = 1, #physicsObjects do 
		if physicsObjects[i] then
			physicsObjects[i].ResolutionVectors = {} -- Null the table every time step
			physicsObjects[i].CollidingObjects = {} -- Null the object table, as well
			for j = 1, #physicsObjects do 
				if physicsObjects[i] and physicsObjects[j] and physicsObjects[i] ~= physicsObjects[j] and physicsObjects[i].Anchored == false then
					local collided = checkForCollision(physicsObjects[i][1], physicsObjects[j][1], physicsObjects[i].Velocity)				
					if collided then
						if physicsObjects[j] ~= gameFloorObj and physicsObjects[j] ~= gameFloorObj2 then end --print("Colliding Objects", physicsObjects[i][1], physicsObjects[j][1]) end
						local collidingObject = {}
						collidingObject.Velocity = physicsObjects[j].Velocity
						collidingObject.Mass = physicsObjects[j].Mass
						collidingObject.Anchored = physicsObjects[j].Anchored
						table.insert(physicsObjects[i].CollidingObjects, collidingObject) -- populate the COR table
						local correctionVector, direction = resolveCollision(physicsObjects[i][1], physicsObjects[j][1], physicsObjects[i].Velocity)					
						if correctionVector then 						
							table.insert(physicsObjects[i].ResolutionVectors, correctionVector) 
						end
						physicsObjects[i].FreeFall = false
						if physicsObjects[i].ClassName == "Bot" then 						
							if physicsObjects[i].Type == "Melee" and physicsObjects[j] == gameCharObj then 							
								physicsObjects[i].Attacking = true
								gameCharObj.Health = gameCharObj.Health - physicsObjects[i].Damage
							end
						end
					end
				end			
			end
			physicsObjects[i].CollectiveResolutionVector = Vector2.new(0, 0)
			if #physicsObjects[i].ResolutionVectors >= 1 then
				for a = 1, #physicsObjects[i].ResolutionVectors do  -- Add the returned list 								
					physicsObjects[i].CollectiveResolutionVector = physicsObjects[i].CollectiveResolutionVector + physicsObjects[i].ResolutionVectors[a] 				
				end								
			end			
			if physicsObjects[i].CollectiveResolutionVector.Y + gravity < 0 then 
				physicsObjects[i].FreeFall = false			
			else
				if physicsObjects[i] ~= gameCharObj then
					physicsObjects[i].FreeFall = true
				else 
					if physicsObjects[i].Jumping == false then 
						physicsObjects[i].FreeFall = true
					end
				end			
			end	
		end
	end	
end
----------------------------------------------------------------------- 

function World:SimulateMovement()
	for i = 1, #physicsObjects do 
		if physicsObjects[i] and physicsObjects[i].Anchored == false then
			if physicsObjects[i].FreeFall == true then 				
				--physicsObjects[i].FreeFallCounter = physicsObjects[i].FreeFallCounter + 1
				physicsObjects[i].Velocity = physicsObjects[i].Velocity + Vector2.new(0, gravity) 
				if physicsObjects[i].Velocity.magnitude > 0.030 then -- Make Terminal Velocity as 0.030, i.e. 33 frames i.e. 1 second to traverse the world from left to right, top to bottom
					physicsObjects[i].Velocity = physicsObjects[i].Velocity.unit * 0.030				
				end				
			else 
				physicsObjects[i].FreeFallCounter = 0				
			end				
			if physicsObjects[i] == gameCharObj and ((gameCharObj[1].Position.X.Scale > 0.50 and gameCharObj.Velocity.X > 0.0) or (gameCharObj[1].Position.X.Scale < 0.0 and gameCharObj.Velocity.X < 0.0)) then 
				-- nullify X Velocity 
				gameCharObj.Velocity = Vector2.new(0.0, gameCharObj.Velocity.Y)
				gameCharObj.HitEnd = true 
			else 
				gameCharObj.HitEnd = false 
				if gameCharObj[1].Position.Y.Scale > 0.8 then print("I am falling") end 
				if gameCharObj.Velocity.X ~= 0 then gameCharObj.PrevVelocity = gameCharObj.Velocity end
			end
			physicsObjects[i][1].Position = physicsObjects[i][1].Position + UDim2.new(physicsObjects[i].Velocity.X + physicsObjects[i].CollectiveResolutionVector.X, 0, physicsObjects[i].Velocity.Y + physicsObjects[i].CollectiveResolutionVector.Y, 0) 
			
			-- COR here ----------------------------------------------------------------- 
			for j = 1, #physicsObjects[i].CollidingObjects do 
				local mAuA = physicsObjects[i].Mass * physicsObjects[i].Velocity
				local mBuB = physicsObjects[i].CollidingObjects[j].Mass * physicsObjects[i].CollidingObjects[j].Velocity
				local mbCr = physicsObjects[i].CollidingObjects[j].Mass * physicsObjects[i].CR * (physicsObjects[i].CollidingObjects[j].Velocity - physicsObjects[i].Velocity)
				local mAmB = physicsObjects[i].Mass + physicsObjects[i].CollidingObjects[j].Mass
				if physicsObjects[i].CollidingObjects[j].Anchored == true then
					if physicsObjects[i].CollectiveResolutionVector.Y then
						physicsObjects[i].Velocity = Vector2.new(physicsObjects[i].Velocity.X * physicsObjects[i].CR, ((mAuA + mBuB + mbCr)/mAmB).Y) -- Apply in only 1 axis
					else
						physicsObjects[i].Velocity = Vector2.new(((mAuA + mBuB + mbCr)/mAmB).X, physicsObjects[i].Velocity.Y * physicsObjects[i].CR)
					end
				else 
					physicsObjects[i].Velocity = (mAuA + mBuB + mbCr)/mAmB
				end
			end
			-----------------------------------------------------------------------------			
			if physicsObjects[i][1].Position.Y.Scale > 1.0  then
				if physicsObjects[i] ~= gameCharObj then 				
					physicsObjects[i][1]:Destroy() 
					physicsObjects[i][1] = nil
					table.remove(physicsObjects, i) 	
				else 
					-- kill Character 
					gameCharObj.Health = 0
				end
			end 
		end
	end
end

-- Special animation for character as it might be more verbose
function characterAnimation()
	local spriteCount = 0
	while gameCharObj and gameCharObj[1] do 
		wait(0.1)
		if gameCharObj and gameCharObj.Jumping == true then 
			gameCharObj[1].Image = "http://www.roblox.com/asset/?id=" .. characterSprites["Jumping"]
			wait(0.8)
		elseif gameCharObj and gameCharObj.Moving == true then 
			gameCharObj[1].Image = "http://www.roblox.com/asset/?id=" .. characterSprites[(spriteCount%4) + 1]
			spriteCount = spriteCount + 1
		else 
			if gameCharObj then 
				gameCharObj[1].Image = "http://www.roblox.com/asset/?id=" .. characterSprites["Default"]
			end
		end
	end 
end

function cloneAnimation()
	local spriteCount = 0 
	while World.CloneBossObj do 
		wait(0.1)
		if World.CloneBossObj and gameCharObj and gameCharObj.Jumping == true then 
			World.CloneBossObj[1].Image = "http://www.roblox.com/asset/?id=" .. cloneBossSprites["Jumping"]
			wait(0.8)
		elseif World.CloneBossObj and gameCharObj and gameCharObj.Moving == true then 
			World.CloneBossObj[1].Image = "http://www.roblox.com/asset/?id=" .. cloneBossSprites[(spriteCount%4) + 1] 
			spriteCount = spriteCount + 1
		else 
			if World.CloneBossObj and gameCharObj then 
				World.CloneBossObj[1].Image = "http://www.roblox.com/asset/?id=" .. cloneBossSprites["Default"] 
			end
		end
	end
end

function animateSprites(object)
	local spriteCount= 1
	while object do 
		if object and object.Attacking == true then 
			print("Attacking")
			--object[1].Image = "http://www.roblox.com/asset/?id=" .. object.Sprites["Attack"] 
			wait(0.50)
		else
			--if object then object[1].Image = "http://www.roblox.com/asset/?id=" .. object.Sprites[spriteCount%(#object.Sprites - 1) + 1]  end
		end 
		wait(0.1)
	end
end

function shootCharacter(direction, projectile, enemy, damage)	
	local collision 
	while projectile do 	
		local velocity = 0.010 
		if enemy.Type == "Boss" then velocity = 0.020 end 
		projectile.Position = projectile.Position + UDim2.new(direction.X * 0.020, 0, direction.Y * 0.020, 0)
		if projectile.Position.X.Scale > 1.0 or projectile.Position.X.Scale < 0.0 or projectile.Position.Y.Scale > 1.0 or projectile.Position.Y.Scale < 0.0 then						
			projectile:Destroy()
			projectile = nil 
		end
		if projectile then 		
			if projectile and gameCharObj then 
				local collision = checkForCollision(projectile, gameCharObj[1], direction * 0.005) 
				if collision then 
					if projectile and gameCharObj and gameCharObj.ForceField == false then 						
						gameCharObj.Health = gameCharObj.Health - damage 
						projectile:Destroy()
						projectile = nil 
						if gameCharObj.Health < 0.0 then 
							gameCharObj.Dead = true 
						end
					end
				end
			end
		end 
		wait()
	end
	wait(1.75)
	if enemies[enemy] then enemies[enemy].CanFire = true end 
end

function World:AIUpdate()
	for i, enemy in pairs (enemies) do		
		if enemy and enemy ~= enemies.NumEnemies and gameCharObj and enemy[1] then
			local direction = Vector2.new(0, 0)
			if enemy.Type == "Melee" then 				
				if gameCharObj.Jumping == true and enemy[1] then
					direction = Vector2.new(gameCharObj[1].Position.X.Scale - enemy[1].Position.X.Scale, 0, 0, 0).unit
				else 
					direction = Vector2.new(gameCharObj[1].Position.X.Scale - enemy[1].Position.X.Scale, 0, 0, 0).unit
				end
				enemy.Velocity = direction * 0.004
			elseif enemy.Type  == "Ranged" and gameCharObj then 
				direction = Vector2.new(0 - enemy[1].Position.X.Scale, 0 - enemy[1].Position.Y.Scale).unit
				enemy.Velocity = Vector2.new(direction.X, 0.0) * 0.004
				if enemy.CanFire == true and enemy[1].Position.X.Scale > gameCharObj[1].Position.X.Scale then
					print("Ranged fire")
					enemy.CanFire = false 
					local projectile = Instance.new("ImageLabel")
					projectile.Size = UDim2.new(0.03, 0, 0.03, 0)
					projectile.Image = "http://www.roblox.com/asset/?id=" .. enemy.Sprites["Projectile"]
					projectile.Name = "Attack"
					projectile.Parent = gameFrame 
					print(projectile.Parent, projectile.Name)
					projectile.BackgroundTransparency = 1.0
					projectile.ZIndex = 5.0
					projectile.Position = enemy[1].Position + UDim2.new(enemy.Velocity.X, 0, enemy.Velocity.Y, 0)	
					direction = Vector2.new(gameCharObj[1].Position.X.Scale - projectile.Position.X.Scale, gameCharObj[1].Position.Y.Scale - projectile.Position.Y.Scale).unit 
					projectile.BackgroundTransparency = 1.0 
					table.insert(enemyProjectiles, projectile)					
					coroutine.resume(coroutine.create(function() shootCharacter(direction, projectile, enemy, enemy.Damage) end))
				end
				if enemy and enemy[1].Position.X.Scale > 1.0 or enemy[1].Position.X.Scale < 0.0 or enemy[1].Position.Y.Scale > 1.0 or enemy[1].Position.Y.Scale < 0.0 then		
					for i = 1, #physicsObjects do 
						if physicsObjects[i] == enemy then table.remove(physicsObjects, i) end
					end					
					enemy[1]:Destroy()					
					enemies[enemy] = nil 
					enemy = nil 
				end
			end
		end
	end 
end

function World:ScrollWorld()	
	if gameCharObj then 		
		if gameCharObj and gameCharObj[1] and gameCharObj[1].Position.X.Scale > 0.05 and not World.BossActive then 			
			if gameCharObj.PrevVelocity.X > 0 then World.DistanceTravelled = World.DistanceTravelled + (gameCharObj.PrevVelocity.X * 5) end			
			if World.DistanceTravelled > World.WorldDistance then 
				print(World.DistanceTravelled)
				World:SpawnBoss(World.LevelName)
			end
			if World.LevelName == "Grass" then 
				if gameBackground.Position.X.Scale < -1.0 or gameBackground2.Position.X.Scale > 1.0 then 
					gameBackground.Position = UDim2.new(1, 0, 0, 0)				
					gameBackground2.Position = UDim2.new(0, 0, 0, 0)			
				elseif gameBackground2.Position.X.Scale < -1.0 or gameBackground.Position.X.Scale > 1.0 then 
					gameBackground.Position = UDim2.new(0, 0, 0, 0)
					gameBackground2.Position = UDim2.new(1, 0, 0, 0)
				else 		
					--print("X - ", gameCharObj.PrevVelocity.X)
					gameBackground.Position = UDim2.new(gameBackground.Position.X.Scale - gameCharObj.PrevVelocity.X/10, 0, gameBackground.Position.Y.Scale, 0) 				
					gameBackground2.Position = UDim2.new(gameBackground2.Position.X.Scale - gameCharObj.PrevVelocity.X/10, 0, gameBackground2.Position.Y.Scale, 0) 	
					sunImage.Position = UDim2.new(sunImage.Position.X.Scale + gameCharObj.PrevVelocity.X/20, 0, sunImage.Position.Y.Scale, 0)
				end	
			end

			if gameFloorObj[1].Position.X.Scale < -1.0 or gameFloorObj2[1].Position.X.Scale > 1.0 then
				gameFloorObj[1].Position = UDim2.new(1, 0, 0.8, 0)
				gameFloorObj2[1].Position = UDim2.new(0, 0, 0.8, 0)
			elseif gameFloorObj2[1].Position.X.Scale < -1.0 or gameFloorObj[1].Position.X.Scale > 1.0 then 
				gameFloorObj[1].Position = UDim2.new(0, 0, 0.8, 0)
				gameFloorObj2[1].Position = UDim2.new(1, 0, 0.8, 0)
			else 					
				gameFloorObj[1].Position = UDim2.new(gameFloorObj[1].Position.X.Scale - gameCharObj.PrevVelocity.X, 0, gameFloorObj[1].Position.Y.Scale, 0) 				
				gameFloorObj2[1].Position = UDim2.new(gameFloorObj2[1].Position.X.Scale - gameCharObj.PrevVelocity.X, 0, gameFloorObj2[1].Position.Y.Scale, 0) 				
			end
			if World.LevelName == "Desert" then 
				if gameBackground.Position.X.Scale < -1.0 or gameBackground2.Position.X.Scale > 1.0 then 
					gameBackground.Position = UDim2.new(1, 0, 0.5, 0)				
					gameBackground2.Position = UDim2.new(0, 0, 0.5, 0)			
				elseif gameBackground2.Position.X.Scale < -1.0 or gameBackground.Position.X.Scale > 1.0 then 
					gameBackground.Position = UDim2.new(0, 0, 0.5, 0)
					gameBackground2.Position = UDim2.new(1, 0, 0.5, 0)
				else 		
					--print("X - ", gameCharObj.PrevVelocity.X)
					gameBackground.Position = UDim2.new(gameBackground.Position.X.Scale - gameCharObj.PrevVelocity.X/10, 0, gameBackground.Position.Y.Scale, 0) 				
					gameBackground2.Position = UDim2.new(gameBackground2.Position.X.Scale - gameCharObj.PrevVelocity.X/10, 0, gameBackground2.Position.Y.Scale, 0) 	
					sunImage.Position = UDim2.new(sunImage.Position.X.Scale + gameCharObj.PrevVelocity.X/20, 0, sunImage.Position.Y.Scale, 0)
				end	

				if gameBackground3 and gameBackground4 then
					if gameBackground3.Position.X.Scale < -1.0 or gameBackground4.Position.X.Scale > 1.0 then 
						gameBackground3.Position = UDim2.new(1, 0, 0.6, 0)				
						gameBackground4.Position = UDim2.new(0, 0, 0.6, 0)			
					elseif gameBackground4.Position.X.Scale < -1.0 or gameBackground3.Position.X.Scale > 1.0 then 
						gameBackground3.Position = UDim2.new(0, 0, 0.6, 0)
						gameBackground4.Position = UDim2.new(1, 0, 0.6, 0)
					else 							
						gameBackground3.Position = UDim2.new(gameBackground3.Position.X.Scale - gameCharObj.PrevVelocity.X/5, 0, gameBackground3.Position.Y.Scale, 0) 				
						gameBackground4.Position = UDim2.new(gameBackground4.Position.X.Scale - gameCharObj.PrevVelocity.X/5, 0, gameBackground4.Position.Y.Scale, 0) 						
					end
				end
			end 
		
			if World.LevelName == "Water" then				
				if waterLevelRocksClose.Position.X.Scale < -1.0 or waterLevelRocksClose2.Position.X.Scale > 1.0  then 
					waterLevelRocksClose.Position = UDim2.new(1, 0, 0.9, 0)
					waterLevelRocksClose2.Position = UDim2.new(0, 0, 0.9,0)
				elseif waterLevelRocksClose2.Position.X.Scale < -1.0 or waterLevelRocksClose.Position.X.Scale > 1.0 then 
					waterLevelRocksClose.Position = UDim2.new(0, 0, 0.9, 0)
					waterLevelRocksClose2.Position = UDim2.new(1, 0, 0.9, 0)
				else 
					waterLevelRocksClose.Position = UDim2.new(waterLevelRocksClose.Position.X.Scale - gameCharObj.PrevVelocity.X, 0, 0.9, 0)
					waterLevelRocksClose2.Position = UDim2.new(waterLevelRocksClose2.Position.X.Scale - gameCharObj.PrevVelocity.X, 0, 0.9, 0)
				end
	
				if waterLevelRocksMid.Position.X.Scale < -1.0 or waterLevelRocksMid2.Position.X.Scale > 1.0  then 
					waterLevelRocksMid.Position = UDim2.new(1, 0, 0.9, 0)
					waterLevelRocksMid2.Position = UDim2.new(0, 0, 0.9,0)
				elseif waterLevelRocksMid2.Position.X.Scale < -1.0 or waterLevelRocksMid.Position.X.Scale > 1.0 then 
					waterLevelRocksMid.Position = UDim2.new(0, 0, 0.9, 0)
					waterLevelRocksMid2.Position = UDim2.new(1, 0, 0.9, 0)
				else 
					waterLevelRocksMid.Position = UDim2.new(waterLevelRocksMid.Position.X.Scale - gameCharObj.PrevVelocity.X/2.5, 0, 0.9, 0)
					waterLevelRocksMid2.Position = UDim2.new(waterLevelRocksMid2.Position.X.Scale - gameCharObj.PrevVelocity.X/2.5, 0, 0.9, 0)
				end
	
				if waterLevelRocksFar.Position.X.Scale < -1.0 or waterLevelRocksFar2.Position.X.Scale > 1.0  then 
					waterLevelRocksFar.Position = UDim2.new(1, 0, 0.9, 0)
					waterLevelRocksFar2.Position = UDim2.new(0, 0, 0.9,0)
				elseif waterLevelRocksFar2.Position.X.Scale < -1.0 or waterLevelRocksFar.Position.X.Scale > 1.0 then 
					waterLevelRocksFar.Position = UDim2.new(0, 0, 0.9, 0)
					waterLevelRocksFar2.Position = UDim2.new(1, 0, 0.9, 0)
				else 
					waterLevelRocksFar.Position = UDim2.new(waterLevelRocksFar.Position.X.Scale - gameCharObj.PrevVelocity.X/5, 0, 0.9, 0)
					waterLevelRocksFar2.Position = UDim2.new(waterLevelRocksFar2.Position.X.Scale - gameCharObj.PrevVelocity.X/5, 0, 0.9, 0)
				end
		
				for i = 1, #World.Platforms do 
					if World.Platforms[i][1].Position.X.Scale < -0.25 then 
						World.Platforms[i][1].Position = UDim2.new(1 - 0.13, 0, 0.80, 0)
					else
						World.Platforms[i][1].Position = UDim2.new(World.Platforms[i][1].Position.X.Scale - gameCharObj.PrevVelocity.X, 0, 0.80, 0)
					end
				end					
			end 
		end
	end
end

function World:SpawnBoss(lvlName)
	print("Spawning Boss")
	World.BossActive = true 
	World.DistanceTravelled = 0.0
	wait(1.0)
	for i, enemy in pairs(enemies) do 
		if enemy ~= enemies.NumEnemies then
			for i = 1, #physicsObjects do 
				if physicsObjects[i] == enemy then 
					table.remove(physicsObjects, i)
				end
			end
			enemy[1]:Destroy()					
			enemies[enemy] = nil 
			enemy = nil 
		end
	end
	if lvlName == "Grass" and gameCharObj then		
		local cloneBoss = Instance.new("ImageLabel")
		cloneBoss.Parent = gameFrame
		cloneBoss.Size = UDim2.new(0.022, 0, 0.057, 0)
		cloneBoss.Name = "Clone Boss"
		cloneBoss.ZIndex = 5.0
		cloneBoss.BackgroundTransparency = 1.0
		cloneBoss.Position = UDim2.new((1 - gameCharObj[1].Position.X.Scale) + 0.1, 0, gameCharObj[1].Position.Y.Scale, 0)
		cloneBoss.Image = "http://www.roblox.com/asset/?id=66243554"		
		table.insert(World.CloneBossObj, cloneBoss)
		World.CloneBossObj.Velocity = Vector2.new(-gameCharObj.Velocity.X, gameCharObj.Velocity.Y)
		World.CloneBossObj.Mass = cloneBoss.Size.X.Scale * cloneBoss.Size.Y.Scale * 50.0
		World.CloneBossObj.CR = 0.3	
		World.CloneBossObj.CollidingObjects = {}
		World.CloneBossObj.ResolutionVectors = {}
		World.CloneBossObj.CollectiveResolutionVector = Vector2.new(0, 0)
		World.CloneBossObj.FreeFall = false 
		World.CloneBossObj.FreeFallCounter = 0.0
		World.CloneBossObj.Anchored = false
		World.CloneBossObj.Moving = false -- For character Movement
		World.CloneBossObj.Forwards = false 
		World.CloneBossObj.Backwards = false 
		World.CloneBossObj.Jumping = false
		World.CloneBossObj.HitEnd = false 
		World.CloneBossObj.ForceField = false 
		World.CloneBossObj.Dead = false 
		World.CloneBossObj.Firing = false				
		World.CloneBossObj.Health = 120	
		World.CloneBossObj.Damage = 17
		World.CloneBossObj.Type = "Boss"
		World.CloneBossObj.Sprites = cloneBossSprites

		table.insert(physicsObjects, World.CloneBossObj)
		World.CloneBossObj.PositionInArray = #physicsObjects
		coroutine.resume(coroutine.create(cloneAnimation))
		print(gameCharObj.Anchored)
		coroutine.resume(coroutine.create(function () 
			while World.CloneBossObj and World.CloneBossObj.Health > 0 do
				if gameCharObj and gameCharObj.Anchored == false then
					World.CloneBossObj.Velocity = Vector2.new(-gameCharObj.PrevVelocity.X, gameCharObj.Velocity.Y * 1.1) 					
					if gameCharObj.Velocity.Y > 0.001 then World.CloneBossObj.Velocity = Vector2.new(-gameCharObj.PrevVelocity.X, gameCharObj.Velocity.Y * 1.1) end
					if gameCharObj.Firing == true then 												
						if World.CloneBossObj.Firing == false then 
							for i = 1, #physicsObjects do 
								if physicsObjects[i][1] then print(physicsObjects[i][1]) end
								print("Physics" .. i) 
							end 
							World.CloneBossObj.Firing = true 
							local projectile = Instance.new("ImageLabel")
							projectile.Size = UDim2.new(0.02, 0, 0.02, 0)
							projectile.Image = "http://www.roblox.com/asset/?id=" .. World.CloneBossObj.Sprites["Attack"]
							projectile.Name = "Attack"
							projectile.Parent = gameFrame 
							print(projectile.Parent, projectile.Name)
							projectile.BackgroundTransparency = 1.0
							projectile.ZIndex = 5.0
							projectile.Position = World.CloneBossObj[1].Position + UDim2.new(World.CloneBossObj.Velocity.X, 0, World.CloneBossObj.Velocity.Y, 0)	
							direction = Vector2.new(gameCharObj[1].Position.X.Scale - projectile.Position.X.Scale, gameCharObj[1].Position.Y.Scale - projectile.Position.Y.Scale).unit 
							projectile.BackgroundTransparency = 1.0 
							table.insert(enemyProjectiles, projectile)					
							coroutine.resume(coroutine.create(function() 								 
								shootCharacter(direction, projectile, World.CloneBossObj, World.CloneBossObj.Damage) 								
							end))
							coroutine.resume(coroutine.create(function() wait(0.65) if World.CloneBossObj then World.CloneBossObj.Firing = false end end))
						end
					end
				end
				wait()
			end		
			wait(1.5)
			World:InitiateWaterAssets()			
			World.BossActive = false 			
		end))		
	elseif lvlName == "Water" and gameCharObj then
		print("Spawning Medusa")
		World.BossActive = true 
		-- spawn Medusa		
		gameCharObj.Anchored = true 
		for i = 1, #World.Platforms do 
			if World.Platforms[i] and World.Platforms[i][1] and World.Platforms[i][1].Position.X.Scale > 0.45 then 			
				for j = 1, #physicsObjects do 	
					if physicsObjects[j] == World.Platforms[i] then 
						table.remove(physicsObjects, j)
					end 
				end 
				World.Platforms[i][1]:Destroy()
				table.remove(World.Platforms, i)  
			end 
		end

		local medusaPlatformObj = {}

		local medusaPlatform = Instance.new("ImageLabel")		
		medusaPlatform.Parent = gameFrame 
		medusaPlatform.Size = UDim2.new(0.35, 0, 0.25, 0)
		medusaPlatform.ZIndex = 5.0 
		medusaPlatform.Name = "Medusa Platform"
		medusaPlatform.Position = UDim2.new(0.65, 0, 0.75, 0)
		medusaPlatform.Image = "http://www.roblox.com/asset/?id=66352383" 
		medusaPlatform.BackgroundTransparency = 1.0

		table.insert(medusaPlatformObj, medusaPlatform)
		medusaPlatformObj.Anchored = true 
		medusaPlatformObj.Mass = 1.0 
		medusaPlatformObj.Velocity = Vector2.new(0, 0, 0)
		medusaPlatformObj.CR = 0.0

		local medusaBoss = Instance.new("ImageLabel")
		medusaBoss.Parent = gameFrame
		medusaBoss.Size = UDim2.new(0.075, 0, 0.15, 0)
		medusaBoss.Name = "Medusa"
		medusaBoss.ZIndex = 5.0
		medusaBoss.BackgroundTransparency = 1.0
		medusaBoss.Position = UDim2.new(0.75, 0, 0.45, 0)
		medusaBoss.Image = "http://www.roblox.com/asset/?id=66352213"		
		table.insert(World.MedusaBossObj, medusaBoss)
		World.MedusaBossObj.Velocity = Vector2.new(0, 0)
		World.MedusaBossObj.Mass = medusaBoss.Size.X.Scale * medusaBoss.Size.Y.Scale * 50.0
		World.MedusaBossObj.CR = 0.3	
		World.MedusaBossObj.CollidingObjects = {}
		World.MedusaBossObj.ResolutionVectors = {}
		World.MedusaBossObj.CollectiveResolutionVector = Vector2.new(0, 0)
		World.MedusaBossObj.FreeFall = false 
		World.MedusaBossObj.FreeFallCounter = 0.0
		World.MedusaBossObj.Anchored = false  
		World.MedusaBossObj.Moving = false -- For character Movement
		World.MedusaBossObj.Forwards = false 
		World.MedusaBossObj.Backwards = false 
		World.MedusaBossObj.Jumping = false
		World.MedusaBossObj.HitEnd = false 
		World.MedusaBossObj.ForceField = false 
		World.MedusaBossObj.Dead = false 
		World.MedusaBossObj.Firing = false				
		World.MedusaBossObj.Health = 200	
		World.MedusaBossObj.Damage = 19
		World.MedusaBossObj.Type = "Boss"
		World.MedusaBossObj.Platform = medusaPlatformObj
		table.insert(physicsObjects, World.MedusaBossObj)
		table.insert(physicsObjects, World.MedusaBossObj.Platform)					 

		for i = 1, #World.Platforms do 
			local minXPlatform 
			local minX = 2.0 
			if World.Platforms[i] and World.Platforms[i][1] and World.Platforms[i][1].Position.X.Scale < minX then 
				minX = World.Platforms[i][1].Position.X.Scale 
				gameCharObj[1].Position = UDim2.new(minX + 0.05, 0, 0.65, 0)
			end 
		end 
		gameCharObj.Anchored = false 
		coroutine.resume(coroutine.create(function() 
			while World.MedusaBossObj and World.MedusaBossObj.Health > 0 do 
				if World.MedusaBossObj.Firing == false then 
					World.MedusaBossObj.Firing = true
					local randFire = math.random() 
					local numProjectiles = 2
					if randFire < 0.5 then numProjectiles = 2 
					elseif randFire > 0.5 and randFire < 0.8 then numProjectiles = 3 	
					elseif randFire > 0.8 and randFire < 0.8 then numProjectiles = 4 
					else 
						numProjectiles = 7
					end 
					for i = 0, numProjectiles - 1 do 
						local projectile = Instance.new("ImageLabel")
						projectile.Size = UDim2.new(0.04, 0, 0.02, 0)
						projectile.Image = "http://www.roblox.com/asset/?id=" .. 66352726
						projectile.Name = "Attack"
						projectile.Parent = gameFrame 						
						projectile.BackgroundTransparency = 1.0
						projectile.ZIndex = 5.0
						projectile.Position = World.MedusaBossObj[1].Position + UDim2.new(World.MedusaBossObj.Velocity.X, 0, World.MedusaBossObj.Velocity.Y, 0)	
						direction = Vector2.new(gameCharObj[1].Position.X.Scale - projectile.Position.X.Scale, (gameCharObj[1].Position.Y.Scale - projectile.Position.Y.Scale) + math.random(-0.5, 0.5)/40).unit 
						projectile.BackgroundTransparency = 1.0 
						table.insert(enemyProjectiles, projectile)					
						coroutine.resume(coroutine.create(function() 								 
							shootCharacter(direction, projectile, World.MedusaBossObj, World.MedusaBossObj.Damage) 								
						end))
						wait()
					end 
					coroutine.resume(coroutine.create(function() wait(0.79) if World.MedusaBossObj then World.MedusaBossObj.Firing = false end end))
				end
				wait()
			end
			wait(1.5)
			World:InitiateDesertAssets()
			World.BossActive = false 	
		end))
	else 
		-- spawn da Sun
		if sunImage then sunImage.Visible = false end 
		gameCharObj.Anchored = true 
		local sunBoss = Instance.new("ImageLabel")
		sunBoss.Parent = gameFrame
		sunBoss.Size = UDim2.new(0.25, 0, 0.3, 0)
		sunBoss.Name = "Teh Sun"
		sunBoss.ZIndex = 5.0
		sunBoss.BackgroundTransparency = 1.0
		sunBoss.Position = UDim2.new(0.75, 0, 0.45, 0)
		sunBoss.Image = "http://www.roblox.com/asset/?id=66360822"		
		table.insert(World.SunBossObj, sunBoss)
		World.SunBossObj.Velocity = Vector2.new(0, 0)
		World.SunBossObj.Mass = sunBoss.Size.X.Scale * sunBoss.Size.Y.Scale * 50.0
		World.SunBossObj.CR = 0.3	
		World.SunBossObj.CollidingObjects = {}
		World.SunBossObj.ResolutionVectors = {}
		World.SunBossObj.CollectiveResolutionVector = Vector2.new(0, 0)
		World.SunBossObj.FreeFall = false 
		World.SunBossObj.FreeFallCounter = 0.0
		World.SunBossObj.Anchored = true  
		World.SunBossObj.Moving = false -- For character Movement
		World.SunBossObj.Forwards = false 
		World.SunBossObj.Backwards = false 
		World.SunBossObj.Jumping = false
		World.SunBossObj.HitEnd = false 
		World.SunBossObj.ForceField = false 
		World.SunBossObj.Dead = false 
		World.SunBossObj.Firing = false				
		World.SunBossObj.Health = 550	
		World.SunBossObj.Damage = 45
		World.SunBossObj.Type = "Boss"		
		table.insert(physicsObjects, World.SunBossObj)
		coroutine.resume(coroutine.create(function() 			
			while World.SunBossObj and World.SunBossObj[1] do 
				local numSteps = 5
				if World.SunBossObj[1].Position.Y.Scale > 0.55 then	
					while numSteps > 0 and World.SunBossObj do 
						World.SunBossObj[1].Position = UDim2.new(0.75, 0, World.SunBossObj[1].Position.Y.Scale - 0.03, 0)
						numSteps = numSteps - 1
						wait(0.5)
					end 
				else 
					while numSteps > 0 and World.SunBossObj do 
						World.SunBossObj[1].Position = UDim2.new(0.75, 0, World.SunBossObj[1].Position.Y.Scale + 0.03, 0)
						numSteps = numSteps - 1
						wait(0.5)
					end
				end 
				wait()
			end 
		end)) 
		wait(1.5) 
		gameCharObj.Anchored = false
		coroutine.resume(coroutine.create(function() 
			while World.SunBossObj and World.SunBossObj.Health > 0 do 		
				if World.SunBossObj.Health < 425 and World.SunBossObj.Firing == false then 
					print("Firing my laser")
					World.SunBossObj.Firing = true 
					-- Make him angry 	
					World.SunBossObj[1].Image = "http://www.roblox.com/asset/?id=66361175"					
					local projectile = Instance.new("ImageLabel")
					projectile.Size = UDim2.new(0.03, 0, 0.03, 0)
					projectile.Image = "http://www.roblox.com/asset/?id=" .. 66361308
					projectile.Name = "Attack"
					projectile.Parent = gameFrame 						
					projectile.BackgroundTransparency = 1.0
					projectile.ZIndex = 5.0					
					projectile.Position = World.SunBossObj[1].Position + UDim2.new(World.SunBossObj.Velocity.X, 0, World.SunBossObj.Velocity.Y, 0)	
					local direction = Vector2.new(gameCharObj[1].Position.X.Scale - projectile.Position.X.Scale, (gameCharObj[1].Position.Y.Scale - projectile.Position.Y.Scale)).unit 				
					projectile.BackgroundTransparency = 1.0 
					table.insert(enemyProjectiles, projectile)	
					coroutine.resume(coroutine.create(function() 
						shootCharacter(direction, projectile, World.SunBossObj, World.SunBossObj.Damage) 
					end))
					coroutine.resume(coroutine.create(function()
						wait(0.3)
						if World.SunBossObj then World.SunBossObj.Firing = false end 
					end)) 
				end
				wait()				
			end 
			World:EndScreen("Win")
		end))
	end	
end

function fireBeam(direction, projectile, damage)
	if World.SunBossObj then 
		if direction == "Horizontal" then 
			projectile.Position = World.SunBossObj[1].Position
			while projectile and projectile.Size.X.Scale < 0.75 do 
				print("Resizing laser")
				projectile.Size = UDim2.new(projectile.Size.X.Scale * 2, 0, 0.04, 0) 
				projectile.Position = UDm2.new(projectile.Position.X.Scale - projectile.Size.X.Scale, 0, projectile.Position.Y.Scale, 0)
				if projectile and gameCharObj then 
					print(1)
					local collision = checkForCollision(projectile, gameCharObj[1], Vector2.new(0, 0)) 
					if collision then 
						print(2)
						if projectile and gameCharObj and gameCharObj.ForceField == false then 						
							gameCharObj.Health = gameCharObj.Health - damage 
							projectile:Destroy()
							projectile = nil 
							if gameCharObj.Health < 0.0 then 
								gameCharObj.Dead = true 
							end
						end
					end
				end
				wait() 
			end 
		else 
			projectile.Position = UDim2.new(gameCharObj[1].Position.X.Scale, 0, 0, 0)
			while projectile and projectile.Size.X.Scale < 0.80 do 
				projectile.Size = UDim2.new(0.04, 0, projectile.Size.X.Scale * 2, 0) 
				projectile.Position = UDm2.new(projectile.Position.X.Scale, 0, projectile.Position.Y.Scale - projectile.Size.Y.Scale, 0)
				if projectile and gameCharObj then 
					local collision = checkForCollision(projectile, gameCharObj[1], Vector2.new(0, 0)) 
					if collision then 
						if projectile and gameCharObj and gameCharObj.ForceField == false then 						
							gameCharObj.Health = gameCharObj.Health - damage 
							projectile:Destroy()
							projectile = nil 
							if gameCharObj.Health < 0.0 then 
								gameCharObj.Dead = true 
							end
						end
					end
				end
				wait() 
			end 
		end 
		if projectile then 
			projectile:Destroy()
			projectile = nil 
		end 
	end 
end 

function World:EndScreen(message)
	print("GAME OGRE")
	if gameCharObj then  
		gameCharObj.Anchored = true
		gameCharObj[1].Visible = false 
	end 
	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1.0
	img.Size = UDim2.new(0.4, 0, 0.25, 0)
	img.Position = UDim2.new(0.3, 0, 0.375, 0)
	img.Parent = gameFrame 
	img.ZIndex = 10.0
	if message == "loser" then 		
		img.Image = "http://www.roblox.com/asset/?id=66365830"
	else 
		img.Image = "http://www.roblox.com/asset/?id=66365883"
	end 
	wait(4.0) -- Need to add the YOU LOSE 
	if gameScreen then gameScreen:Destroy() end 
end

function World:SpawnEnemy()
	tick()
	if gameCharObj and World.DistanceTravelled > 1.0 and not World.BossActive and World.SpawnAllowed then		
		if math.random() < 0.05 and enemies.NumEnemies < 5 and World.LevelName == "Desert" then
			World.SpawnAllowed = false 
			print("Spawning Melee Enemy")
			-- Spawn Melee Enemy 
			local meleeEnemyObj = {}
			local meleeEnemy = Instance.new("ImageLabel")
			meleeEnemy.Parent = gameFrame 
			meleeEnemy.Name = "MeleeEnemy"
			meleeEnemy.ZIndex = 5.0
			meleeEnemy.BackgroundTransparency = 1.0
			meleeEnemy.Position = UDim2.new(0.9, 0, 0.75, 0)
			meleeEnemy.Image = "http://www.roblox.com/asset/?id=66197277"
			meleeEnemy.Size = UDim2.new(0.070, 0, 0.0931, 0)
			table.insert(meleeEnemyObj, meleeEnemy)
		
			meleeEnemyObj.Velocity = Vector2.new(0, 0)
			meleeEnemyObj.Type = "Melee" 
			meleeEnemyObj.Mass = meleeEnemy.Size.X.Scale * meleeEnemy.Size.Y.Scale * 50.0
			meleeEnemyObj.CR = 0.2
			meleeEnemyObj.Jumping = false 
			meleeEnemyObj.Anchored = false 
			meleeEnemyObj.Moving = false 
			meleeEnemyObj.Forwards = false 
			meleeEnemyObj.Backwards = false 
			meleeEnemyObj.CollidingObjects = {}
			meleeEnemyObj.ResolutionVectors = {}
			meleeEnemyObj.CollectiveResolutionVector = {}
			meleeEnemyObj.Sprites = meleeEnemySprites 
			meleeEnemyObj.Health = 40
			meleeEnemyObj.Damage = 15
			meleeEnemyObj.ClassName = "Bot"
			table.insert(physicsObjects, meleeEnemyObj)
			meleeEnemyObj.PositionInArray = #physicsObjects 
			enemies[meleeEnemyObj] = meleeEnemyObj
			enemies.NumEnemies = enemies.NumEnemies + 1
			coroutine.resume(coroutine.create(function() animateSprites(meleeEnemyObj) end)) 
		end 
		
		if math.random() < 1.0 and enemies.NumEnemies < 3 then 
			-- Spawn ranged enemy 
			World.SpawnAllowed = false 
			local rangedEnemyObj = {}
			local rangedEnemy = Instance.new("ImageLabel")
			rangedEnemy.Parent = gameFrame 
			rangedEnemy.Name = "rangedEnemy"
			rangedEnemy.ZIndex = 5.0
			rangedEnemy.BackgroundTransparency = 1.0
			rangedEnemy.BorderSizePixel = 0.0
			rangedEnemy.Position = UDim2.new(0.9, 0, 0.75, 0)
			rangedEnemy.Image = "http://www.roblox.com/asset/?id=66189603" 
			rangedEnemy.Size = UDim2.new(0.070, 0, 0.0931, 0)
			table.insert(rangedEnemyObj, rangedEnemy)

			enemies.NumEnemies = enemies.NumEnemies + 1
		
			rangedEnemyObj.Velocity = Vector2.new(0, 0)
			rangedEnemyObj.Type = "Ranged" 
			rangedEnemyObj.Mass = rangedEnemy.Size.X.Scale * rangedEnemy.Size.Y.Scale * 50.0
			rangedEnemyObj.CR = 0.2
			rangedEnemyObj.Jumping = false 
			rangedEnemyObj.Anchored = false 
			rangedEnemyObj.Moving = false 
			rangedEnemyObj.Forwards = false 
			rangedEnemyObj.Backwards = false 	
			rangedEnemyObj.CanFire = true
			rangedEnemyObj.CollidingObjects = {}
			rangedEnemyObj.ResolutionVectors = {}
			rangedEnemyObj.CollectiveResolutionVector = {}
			rangedEnemyObj.Sprites = rangedEnemySprites 
			rangedEnemyObj.Health = 50
			rangedEnemyObj.Damage = 17
			rangedEnemyObj.ClassName = "Bot"
			table.insert(physicsObjects, rangedEnemyObj)
			rangedEnemyObj.PositionInArray = #physicsObjects
			enemies[rangedEnemyObj] = rangedEnemyObj
			coroutine.resume(coroutine.create(function() animateSprites(rangedEnemyObj) end))			
			coroutine.resume(coroutine.create(function() wait(enemies.NumEnemies * 3.0) World.SpawnAllowed = true end))
		end
	end
end

function createGameCharacter()	
	print("Character created")
	-- Spawn Character 
	if not gameChar then
		gameCharObj = {}
		gameChar = 	Instance.new("ImageLabel")
		gameChar.Parent = gameFrame
		gameChar.Size = UDim2.new(0.027, 0, 0.056, 0)
		gameChar.Name = "Hero"
		gameChar.ZIndex = 5.0
		gameChar.BackgroundTransparency = 1.0
		gameChar.Position = UDim2.new(0.0, 0, 0.7, 0)
		gameChar.Image = "http://www.roblox.com/asset/?id=65912145"		
		table.insert(gameCharObj, gameChar)
		gameCharObj.Velocity = Vector2.new(0, 0)
		gameCharObj.Mass = gameChar.Size.X.Scale * gameChar.Size.Y.Scale * 50.0
		gameCharObj.CR = 0.3	
		gameCharObj.CollidingObjects = {}
		gameCharObj.ResolutionVectors = {}
		gameCharObj.CollectiveResolutionVector = Vector2.new(0, 0)
		gameCharObj.FreeFall = false 
		gameCharObj.FreeFallCounter = 0.0
		gameCharObj.Anchored = false
		gameCharObj.Moving = false -- For character Movement
		gameCharObj.Forwards = false 
		gameCharObj.Backwards = false 
		gameCharObj.Jumping = false
		gameCharObj.HitEnd = false 
		gameCharObj.ForceField = false 
		gameCharObj.Dead = false 
		gameCharObj.Firing = false
		gameCharObj.PrevVelocity = Vector2.new(0, 0)
		gameCharObj.SpawnPos = Vector2.new(0.0, 0.7)	
		gameCharObj.Health = 102

		gameCharObj.Healthbar = Instance.new("ImageLabel")
		gameCharObj.Healthbar.Parent = gameFrame 
		gameCharObj.Healthbar.Size = UDim2.new(0.15, 0, 0.025, 0)
		gameCharObj.Healthbar.Image = "http://www.roblox.com/asset/?id=" .. gameCharHealthbarAssets[6] 
		gameCharObj.Healthbar.ZIndex = 5.0 
		gameCharObj.Healthbar.Position = UDim2.new(0.03, 0, 0.010, 0)
		gameCharObj.Healthbar.BackgroundTransparency = 1.0	
		gameCharObj.Healthbar.Name = "Healthbar"
	
		gameCharObj.LivesText = Instance.new("TextLabel")
		gameCharObj.LivesText.Parent = gameFrame 
		gameCharObj.LivesText.Size = UDim2.new(0.15, 0, 0.025, 0)
		gameCharObj.LivesText.ZIndex = 5.0 
		gameCharObj.LivesText.TextColor3 = Color3.new(204/255, 0, 204/255)
		gameCharObj.LivesText.Position = UDim2.new(-0.03, 0, 0.039, 0)
		gameCharObj.LivesText.BackgroundTransparency = 1.0	
		gameCharObj.LivesText.Name = "Lives"
		gameCharObj.LivesText.Text = "x" .. World.LivesRemaining

		gameCharObj.Icon = Instance.new("ImageLabel")
		gameCharObj.Icon.Parent = gameFrame 
		gameCharObj.Icon.Size = UDim2.new(0.027, 0, 0.056, 0)
		gameCharObj.Icon.Position = UDim2.new(0, 0, 0.010, 0)
		gameCharObj.Icon.ZIndex = 5.0 
		gameCharObj.Icon.BackgroundTransparency = 1.0		
		gameCharObj.Icon.Image= "http://www.roblox.com/asset/?id=65912145"		
		gameCharObj.Icon.Name = "Character Icon" 
		
		table.insert(physicsObjects, gameCharObj)
		gameCharObj.PositionInArray = #physicsObjects
		coroutine.resume(coroutine.create(characterAnimation))
	end
end

function World:InitiateWaterAssets()
	print("Initiating Water Level")
	World.DistanceTravelled = 0
	if gameCharObj then 
		gameCharObj.Anchored = true 
		gameCharObj[1].Visible = false 
	end 

	wait(1.0)

	World.LevelName = "Water" 

	sunImage.Image = "http://www.roblox.com/asset/?id=66225675" -- Water level Sun 
	sunImage.Size = UDim2.new(0.167, 0, 0.213, 0)
	skyImage.Image = "http://www.roblox.com/asset/?id=66225731" -- Water level Sky 

	for i = 1, #physicsObjects do 
		if physicsObjects[i] == gameFloorObj or physicsObjects[i] == gameFloorObj2  then 
			table.remove(physicsObjects, i)
		end
	end

	gameFloorObj[1].Visible = false
	gameFloorObj2[1].Visible = false 

	gameBackground.Visible = false 
	gameBackground2.Visible = false 

	waterLevelRocksClose = Instance.new("ImageLabel") 
	waterLevelRocksClose.Image = "http://www.roblox.com/asset/?id=66225756"
	waterLevelRocksClose.Size = UDim2.new(1, 0, 0.1, 0)
	waterLevelRocksClose.Position = UDim2.new(0, 0, 0.9, 0)
	waterLevelRocksClose.ZIndex = 5.0
	waterLevelRocksClose.BackgroundTransparency = 1.0
	waterLevelRocksClose.Name = "Rocks Close"
	waterLevelRocksClose.Parent = gameFrame

	waterLevelRocksClose2 = Instance.new("ImageLabel") 
	waterLevelRocksClose2.Image = "http://www.roblox.com/asset/?id=66225756"
	waterLevelRocksClose2.Size = UDim2.new(1, 0, 0.1, 0)
	waterLevelRocksClose2.Position = UDim2.new(1, 0, 0.9, 0)
	waterLevelRocksClose2.ZIndex = 5.0
	waterLevelRocksClose2.BackgroundTransparency = 1.0
	waterLevelRocksClose2.Name = "Rocks Close"
	waterLevelRocksClose2.Parent = gameFrame

	waterLevelRocksMid = Instance.new("ImageLabel") 
	waterLevelRocksMid.Image = "http://www.roblox.com/asset/?id=66225756"
	waterLevelRocksMid.Size = UDim2.new(1, 0, 0.1, 0)
	waterLevelRocksMid.Position = UDim2.new(0, 0, 0.9, 0)
	waterLevelRocksMid.ZIndex = 4.0
	waterLevelRocksMid.BackgroundTransparency = 1.0
	waterLevelRocksMid.Name = "Rocks Close"
	waterLevelRocksMid.Parent = gameFrame

	waterLevelRocksMid2 = Instance.new("ImageLabel") 
	waterLevelRocksMid2.Image = "http://www.roblox.com/asset/?id=66225756"
	waterLevelRocksMid2.Size = UDim2.new(1, 0, 0.1, 0)
	waterLevelRocksMid2.Position = UDim2.new(1, 0, 0.9, 0)
	waterLevelRocksMid2.ZIndex = 4.0
	waterLevelRocksMid2.BackgroundTransparency = 1.0
	waterLevelRocksMid2.Name = "Rocks Close"
	waterLevelRocksMid2.Parent = gameFrame

	waterLevelRocksFar = Instance.new("ImageLabel") 
	waterLevelRocksFar.Image = "http://www.roblox.com/asset/?id=66225756"
	waterLevelRocksFar.Size = UDim2.new(1, 0, 0.1, 0)
	waterLevelRocksFar.Position = UDim2.new(0, 0, 0.9, 0)
	waterLevelRocksFar.ZIndex = 3.0
	waterLevelRocksFar.BackgroundTransparency = 1.0
	waterLevelRocksFar.Name = "Rocks Close"
	waterLevelRocksFar.Parent = gameFrame

	waterLevelRocksFar2 = Instance.new("ImageLabel") 
	waterLevelRocksFar2.Image = "http://www.roblox.com/asset/?id=66225756"
	waterLevelRocksFar2.Size = UDim2.new(1, 0, 0.1, 0)
	waterLevelRocksFar2.Position = UDim2.new(1, 0, 0.9, 0)
	waterLevelRocksFar2.ZIndex = 5.0
	waterLevelRocksFar2.BackgroundTransparency = 1.0
	waterLevelRocksFar2.Name = "Rocks Close"
	waterLevelRocksFar2.Parent = gameFrame

	for i = 0, 3 do 
		local platformObj = {}
		platform = Instance.new("ImageLabel") 
		platform.Name = "SpawnPlatform" 
		platform.Image = "http://www.roblox.com/asset/?id=58344744" 
		platform.Size = UDim2.new(0.15, 0, 0.025, 0)      
		platform.Position = UDim2.new(i * 0.28, 0, 0.80, 0) 
		platform.Parent = gameFrame 	
		table.insert(platformObj, platform)
		platformObj.Anchored = true 	
		platformObj.Mass = 1.0
		platformObj.Velocity = Vector2.new(0, 0)
		table.insert(physicsObjects, platformObj) 
		table.insert(World.Platforms, platformObj)
	end

	if gameCharObj and gameCharObj[1] then 
		local minXPlatform = 2.0		
		for i = 1, #World.Platforms do 
			if World.Platforms[i][1].Position.X.Scale <  minXPlatform then 
				minXPlatform = World.Platforms[i][1].Position.X.Scale  
			end 
		end
		gameCharObj[1].Position = UDim2.new(minXPlatform, 0, 0.70, 0) 
		gameCharObj.Anchored = false 
		gameCharObj[1].Visible = true 
	end
end

function World:InitiateDesertAssets()
	if gameCharObj then 
		gameCharObj.Anchored = true 
		gameCharObj[1].Visible = false 
	end 
	for i = 1, #World.Platforms do 
		for j = 1, #physicsObjects do 
			if physicsObjects[j] == World.Platforms[i] then
				table.remove(physicsObjects, j)
			end 
		end 
		if World.Platforms[i] and World.Platforms[i][1] then World.Platforms[i][1]:Destroy() end
		table.remove(World.Platforms, i)
	end 
	print("Initiating Desert Level")
	World.LevelName = "Desert"
	if waterLevelRocksClose then waterLevelRocksClose:Destroy() end 
	if waterLevelRocksClose2 then waterLevelRocksClose2:Destroy() end 
	if waterLevelRocksMid then waterLevelRocksMid:Destroy() end 
	if waterLevelRocksMid2 then waterLevelRocksMid2:Destroy() end 
	if waterLevelRocksFar then waterLevelRocksFar:Destroy() end 
	if waterLevelRocksFar2 then waterLevelRocksFar2:Destroy() end 
	wait(3.0)
	sunImage.Image = "http://www.roblox.com/asset/?id=66356580" -- Sun 
	sunImage.Size = UDim2.new(0.33, 0, 0.45, 0)
	skyImage.Image = "http://www.roblox.com/asset/?id=66226104" -- Sky 

	gameFloorObj[1].Image = "http://www.roblox.com/asset/?id=66226069" 
	gameFloorObj[1].Visible = true
	gameFloorObj[1].Position = UDim2.new(0, 0, 0.8, 0)
	gameFloorObj[1].ZIndex = 5.0
	gameFloorObj[1].Name = "Floor"
	gameFloorObj.Anchored = true
	table.insert(physicsObjects, gameFloorObj)
	gameFloorObj2[1].Image = "http://www.roblox.com/asset/?id=66226069"
	gameFloorObj2[1].Visible = true 
	gameFloorObj2[1].ZIndex = 5.0
	gameFloorObj2[1].Position = UDim2.new(1, 0, 0.8, 0)
	gameFloorObj[1].Name = "Floor2"	
	gameFloorObj2.Anchored = true
	table.insert(physicsObjects, gameFloorObj2)

	gameBackground.Image = "http://www.roblox.com/asset/?id=66226129"
	gameBackground.Size = UDim2.new(1, 0, 0.3, 0)
	gameBackground.Position = UDim2.new(0, 0, 0.5, 0)
	gameBackground.ZIndex = 2.0
	gameBackground.Visible = true 
	gameBackground2.Image = "http://www.roblox.com/asset/?id=66226129"
	gameBackground.Visible = true 
	gameBackground2.Size = UDim2.new(1, 0, 0.3, 0)
	gameBackground2.Position = UDim2.new(1, 0, 0.5, 0)
	gameBackground2.ZIndex = 2.0
	
	gameBackground3 = Instance.new("ImageLabel")
	gameBackground3.Parent = gameFrame
	gameBackground3.Position = UDim2.new(0, 0, 0.6, 0)
	gameBackground3.Size = UDim2.new(1, 0, 0.3, 0)
	gameBackground3.Name = "Background"
	gameBackground3.Image = "http://www.roblox.com/asset/?id=66226112"
	gameBackground3.BorderSizePixel = 0.0
	gameBackground3.ZIndex = 3.0
	gameBackground3.Visible = true
	gameBackground3.BackgroundTransparency = 1.0
	
	gameBackground4 = Instance.new("ImageLabel")
	gameBackground4.Parent = gameFrame
	gameBackground4.Position = UDim2.new(1, 0, 0.6, 0)
	gameBackground4.Size = UDim2.new(1, 0, 0.3, 0)
	gameBackground4.Name = "Background"
	gameBackground4.Image = "http://www.roblox.com/asset/?id=66226112"
	gameBackground4.BorderSizePixel = 0.0
	gameBackground4.ZIndex = 3.0
	gameBackground4.BackgroundTransparency = 1.0
	gameBackground4.Visible = true
	
	wait(1.0)
	
	gameCharObj[1].Position = UDim2.new(0.1, 0, 0.7, 0)
	gameCharObj.Anchored = false
	gameCharObj[1].Visible = true 

	World.BossActive = false 
end

function World:CheckEvents()
	if gameCharObj then 
		if gameCharObj[1] and gameCharObj[1].Position.Y.Scale > 1.0 then 
			print("Resetting character")
			gameCharObj.Health = 0
		end 
		gameCharObj.LivesText.Text = "x" .. World.LivesRemaining
		if gameCharObj.Health/17 > 0 then 
			local ratio = math.floor(gameCharObj.Health/17 + 0.5) 
			if ratio == 0 then ratio = 1 end 
			gameCharObj.Healthbar.Image = "http://www.roblox.com/asset/?id=" .. gameCharHealthbarAssets[ratio] 
			gameCharObj.Healthbar.Size = UDim2.new(0.025 * ratio, 0, 0.025, 0)			
		end
		if gameCharObj.Health <= 0 then 
			if World.LivesRemaining > 0 then 				
				-- do respawn stuff here 	
				gameCharObj[1].Visible = false 
				gameCharObj.Anchored = true
				gameCharObj.ForceField = true
				gameCharObj.Health = 102 		
		
				if World.LevelName == "Water" then 
					local minX = 2.0 
					for i = 1, #World.Platforms do 
						if World.Platforms[i] and World.Platforms[i][1] and World.Platforms[i][1].Position.X.Scale > 0 and World.Platforms[i][1].Position.X.Scale < minX then 
							minX = World.Platforms[i][1].Position.X.Scale
						end 
					end 
					gameCharObj[1].Position = UDim2.new(minX + 0.05, 0, 0.65, 0)
				else 
					gameCharObj[1].Position = UDim2.new(0.15, 0, 0.65, 0)
				end 
							
				coroutine.resume(coroutine.create(function() 
					wait(2.0)
					gameCharObj.Anchored = false
					local duration = 2.25 
					while duration > 0 do 
						gameCharObj[1].Visible = not gameCharObj[1].Visible 
						wait(0.25)	
						duration = duration - wait(0.5)
					end
					gameCharObj[1].Visible = true 
					World.LivesRemaining = World.LivesRemaining - 1
					gameCharObj.LivesText.Text = "x" .. World.LivesRemaining
					gameCharObj.ForceField = false 
				end))
			else 
				World:EndScreen("loser")
			end
		end 
	end
end

function World:InitiateGameAssets()	
	gameBackground = Instance.new("ImageLabel")
	gameBackground.Parent = gameFrame
	gameBackground.Position = UDim2.new(0, 0, 0, 0)
	gameBackground.Size = UDim2.new(1, 0, 1, 0)
	gameBackground.Name = "Background"
	gameBackground.Image = "http://www.roblox.com/asset/?id=65908682"
	gameBackground.BorderSizePixel = 0.0
	gameBackground.ZIndex = 2.0
	gameBackground.BackgroundTransparency = 1.0

	gameBackground2 = Instance.new("ImageLabel")
	gameBackground2.Parent = gameFrame
	gameBackground2.Position = UDim2.new(1, 0, 0, 0)
	gameBackground2.Size = UDim2.new(1, 0, 1, 0)
	gameBackground2.Name = "Background2"
	gameBackground2.Image = "http://www.roblox.com/asset/?id=65908682"
	gameBackground2.BorderSizePixel = 0.0
	gameBackground2.ZIndex = 2.0
	gameBackground2.BackgroundTransparency = 1.0

	skyImage = Instance.new("ImageLabel")
	skyImage.Parent = gameFrame
	skyImage.Position = UDim2.new(0, 0, 0, 0)
	skyImage.Size = UDim2.new(1, 0, 1, 0)
	skyImage.Name = "Sky"
	skyImage.Image = "http://www.roblox.com/asset/?id=65909301"
	skyImage.BorderSizePixel = 0.0
	skyImage.ZIndex = 1.0
	skyImage.BackgroundTransparency = 1.0

	sunImage = Instance.new("ImageLabel")
	sunImage.Parent = gameFrame
	sunImage.Position = UDim2.new(0.12, 0, 0.12, 0)
	sunImage.Size = UDim2.new(0.12, 0, 0.12, 0)
	sunImage.Name = "Sun"
	sunImage.Image = "http://www.roblox.com/asset/?id=65910153"
	sunImage.BorderSizePixel = 0.0
	sunImage.ZIndex = 5.0
	sunImage.BackgroundTransparency = 1.0

	QuadTree.RootNode = QuadTree:CreateTree(gameBackground)
	QuadTree:PrintTree(QuadTree.RootNode) 

	-- Game Floor	
	gameFloor = Instance.new("ImageLabel")
	gameFloor.Name = "Floor"
	gameFloor.Parent = gameFrame
	gameFloor.Position = UDim2.new(0, 0, 0.8, 0)
	gameFloor.Size = UDim2.new(1, 0, 0.2, 0)
	gameFloor.Image = "http://www.roblox.com/asset/?id=65911902"
	gameFloor.BackgroundTransparency = 1.0
	gameFloor.ZIndex = 3.0
	table.insert(gameFloorObj, gameFloor)
	gameFloorObj.Velocity = Vector2.new(0, 0)
	gameFloorObj.Anchored = true 
	gameFloorObj.FreeFall = false 
	gameFloorObj.FreeFallCounter = 0.0
	gameFloorObj.ResolutionVectors = {}
	gameFloorObj.Mass = gameFloor.Size.X.Scale * gameFloor.Size.Y.Scale * 50.0
	gameFloorObj.CR = 0.0
	table.insert(physicsObjects, gameFloorObj)

	
	gameFloor2 = Instance.new("ImageLabel")
	gameFloor2.Name = "Floor"
	gameFloor2.Parent = gameFrame
	gameFloor2.Position = UDim2.new(1, 0, 0.8, 0)
	gameFloor2.Size = UDim2.new(1, 0, 0.2, 0)
	gameFloor2.Image = "http://www.roblox.com/asset/?id=65911902"
	gameFloor2.BackgroundTransparency = 1.0
	gameFloor2.ZIndex = 3.0
	table.insert(gameFloorObj2, gameFloor2)
	gameFloorObj2.Velocity = Vector2.new(0, 0)
	gameFloorObj2.Anchored = true 
	gameFloorObj2.FreeFall = false 
	gameFloorObj2.FreeFallCounter = 0.0
	gameFloorObj2.ResolutionVectors = {}
	gameFloorObj2.Mass = gameFloor.Size.X.Scale * gameFloor2.Size.Y.Scale * 50.0
	gameFloorObj2.CR = 0.0
	table.insert(physicsObjects, gameFloorObj2)	
	createGameCharacter()	

	-- Create the default projectile, can't think of a better place to put this 
	gameProjectile = Instance.new("ImageLabel") 
	gameProjectile.Image = "http://www.roblox.com/asset/?id=66202637" 
	gameProjectile.Size = UDim2.new(0.020, 0, 0.019, 0) 
	gameProjectile.BackgroundTransparency = 1.0 
	gameProjectile.Name = "CharProjectile"
	gameProjectile.ZIndex = 5.0
	
	World.DistanceTravelled = 0.0
end

function createGameInterface()
	gameScreen = Instance.new("ScreenGui")
	gameScreen.Parent = vPlayer.PlayerGui
	gameScreen.Name = "Game Screen"

	while gameScreen.AbsoluteSize.X == 0 do wait() end -- Patience is a virtue	

	local screenMidPoint = Vector2.new(gameScreen.AbsoluteSize.X/2.0, gameScreen.AbsoluteSize.Y/2.0) 	

	gameFrame = Instance.new("Frame")
	gameFrame.Parent = gameScreen
	gameFrame.Size = UDim2.new(0, 800, 0, 600)
	gameFrame.Position = UDim2.new(0, screenMidPoint.X - 400, 0, screenMidPoint.Y - 300)
	gameFrame.Name = "Game Frame"
	gameFrame.BackgroundTransparency = 1.0	
	gameFrame.ClipsDescendants = true 

	gameIntroImage = Instance.new("ImageLabel")
	gameIntroImage.Parent = gameFrame 
	gameIntroImage.Position = UDim2.new(0, 0, 0, 0)
	gameIntroImage.Size = UDim2.new(1, 0, 1, 0)
	gameIntroImage.Name = "IntroScreen"
	gameIntroImage.Image = "http://www.roblox.com/asset/?id=65978066"
	gameIntroImage.ZIndex = 7.0 
	gameIntroImage.BackgroundTransparency = 1.0 

	gameStartButton = Instance.new("ImageButton")
	gameStartButton.Parent = gameFrame 
	gameStartButton.Position = UDim2.new(0.5, -75, 0.6, -25)
	gameStartButton.Size = UDim2.new(0, 150, 0, 50)
	gameStartButton.Name = "Start"
	gameStartButton.Image = "http://www.roblox.com/asset/?id=65978165"
	gameStartButton.ZIndex = 8.0
	gameStartButton.BackgroundTransparency = 1.0

	gameStartButton.MouseButton1Click:connect(function()
		gameStartButton.Image = "http://www.roblox.com/asset/?id=65978517"
		wait(1.2)
		World:InitiateGameAssets()		
		if gameIntroImage then gameIntroImage:Destroy() end 
		if gameStartButton then gameStartButton:Destroy() end
	end)	
	
	gameStartButton.MouseEnter:connect(function()
		gameStartButton.Image = "http://www.roblox.com/asset/?id=65978204"
	end)
	
	gameStartButton.MouseLeave:connect(function() 
		gameStartButton.Image = "http://www.roblox.com/asset/?id=65978165"
	end)
end

function World:SetCharacterVelocity()
	if gameCharObj and gameCharObj.Moving then 		
		if gameCharObj.Backwards then 
			gameCharObj.Velocity = Vector2.new(-0.003, gameCharObj.Velocity.Y) -- gameCharObj.Velocity + Vector2.new(-0.002, 0)
		elseif gameCharObj.Forwards then 
			gameCharObj.Velocity = Vector2.new(0.003, gameCharObj.Velocity.Y) -- gameCharObj.Velocity + Vector2.new(0.002, 0)
		end		
	end
	if gameCharObj and gameCharObj.Jumping and not gameCharObj.FreeFall then 
		gameCharObj.Velocity = Vector2.new(gameCharObj.Velocity.X, -0.012)
	end
end

function charMovementStop(key)
	if key and gameCharObj then
		key = key:lower()
		if key == "a" or key == "d" then 
			gameCharObj.Moving = false 
		end 
		if key == "a" then 
			gameCharObj.Backwards = false 
		elseif key == "d" then 
			gameCharObj.Forwards = false 	
		end		
	end
end

function charMovementStart(key)
	if key and gameCharObj then
		key = key:lower()
		if key == "a" or key == "d" then 
			gameCharObj.Moving = true		
		end
		if key == "a" then 
			gameCharObj.Backwards = true			
		elseif key == "d" then
			gameCharObj.Forwards = true			
		elseif key == "w" then 
			if jumpCo == nil or coroutine.status(jumpCo) == "dead" then 				
				gameCharObj.Jumping = true
				jumpCo = coroutine.create(function() if gameCharObj then wait(0.2) gameCharObj.Jumping = false gameCharObj.FreeFall = true end wait(1.0) end) 
				coroutine.resume(jumpCo)
			end
		end
	end
end

function transformToWorldCoordinates(mouse) 
	if gameFrame then 
		local xPos = mouse.X - gameFrame.Position.X.Offset 
		local yPos = mouse.Y - gameFrame.Position.Y.Offset 
		return Vector2.new(xPos, yPos) 
	end 
end 

function fire(projectileClone, direction)  	
	local collision = false
	-- Lets set the velocity to be 2 units 
	while projectileClone do            		
		projectileClone.Position = projectileClone.Position + UDim2.new((direction.X * 0.02), 0, (direction.Y * 0.02), 0)           
		if projectileClone.Position.X.Scale >= 1 or projectileClone.Position.X.Scale <= 0 or projectileClone.Position.Y.Scale >= 1 or projectileClone.Position.Y.Scale <= 0 then 			
			projectileClone:Destroy() 
			projectileClone = nil 
		end 						
		for i, enemy in pairs(enemies) do                 
			if projectileClone and enemy and enemy ~= enemies.NumEnemies then collision = checkForCollision(enemy[1], projectileClone, Vector2.new(0, 0)) end 
			if enemy ~= enemies.NumEnemies and collision and projectileClone then 				
				projectileClone:Destroy() 
				projectileClone = nil 				                     
				if enemy and enemy.Health and enemy.Health > 0 then                            
					enemy.Health = enemy.Health - 17
				elseif enemy then										
					for i = 1, #physicsObjects do 
						if physicsObjects[i] == enemy then 
							table.remove(physicsObjects, i) 
							physicsObjects[i] = nil 
						end
					end
					enemy[1]:Destroy() 
					enemies[enemy] = nil 
					enemy = nil 
					enemies.NumEnemies = enemies.NumEnemies - 1 						
				end  
			end
		end 
		if World.CloneBossObj and World.CloneBossObj[1] and projectileClone then 			
			collision = checkForCollision(World.CloneBossObj[1], projectileClone, Vector2.new(0, 0)) 			
			if collision and projectileClone then
				if World.CloneBossObj.Health and World.CloneBossObj.Health > 0 then 
					World.CloneBossObj.Health = World.CloneBossObj.Health - 17 
					projectileClone:Destroy() 
					projectileClone = nil 
					if World.CloneBossObj.Health <= 0 then
						print("Removing boss")
						for i = 1, #physicsObjects do 
							if physicsObjects[i] == World.CloneBossObj then table.remove(physicsObjects, i) end
						end					
						World.CloneBossObj[1]:Destroy()
						World.CloneBossObj = nil 
					end 
				end
			end
		end
		if World.MedusaBossObj and World.MedusaBossObj[1] and projectileClone then 			
			collision = checkForCollision(World.MedusaBossObj[1], projectileClone, Vector2.new(0, 0)) 			
			if collision and projectileClone then
				if World.MedusaBossObj.Health and World.MedusaBossObj.Health > 0 then 
					World.MedusaBossObj.Health = World.MedusaBossObj.Health - 17 
					projectileClone:Destroy() 
					projectileClone = nil 
					if World.MedusaBossObj.Health <= 0 then
						print("Removing boss")
						for i = 1, #physicsObjects do 
							if physicsObjects[i] == World.MedusaBossObj or physicsObjects[i] == World.MedusaBossObj.Platform then table.remove(physicsObjects, i) end
						end					
						World.MedusaBossObj.Platform[1]:Destroy() 
						World.MedusaBossObj[1]:Destroy()
						World.MedusaBossObj = nil 
					end 
				end
			end
		end
		if World.SunBossObj and World.SunBossObj[1] and projectileClone then 			
			collision = checkForCollision(World.SunBossObj[1], projectileClone, Vector2.new(0, 0)) 			
			if collision and projectileClone then
				if World.SunBossObj.Health and World.SunBossObj.Health > 0 then 
					World.SunBossObj.Health = World.SunBossObj.Health - 17 
					projectileClone:Destroy() 
					projectileClone = nil 
					if World.SunBossObj.Health <= 0 then
						print("Removing boss")
						for i = 1, #physicsObjects do 
							if physicsObjects[i] == World.SunBossObj then table.remove(physicsObjects, i) end
						end					
						World.SunBossObj[1]:Destroy()
						World.SunBossObj = nil 
					end 
				end
			end
		end
		wait()		
	end
end 

function gameCharFire(mouse) 	
	if mouse and gameProjectile and gameCharObj and gameCharObj.Firing == false and gameCharObj.Anchored == false then 		
		gameCharObj.Firing = true 
		local projectileClone = gameProjectile:Clone() 		
		local mouseInWorld = transformToWorldCoordinates(mouse) 
		local gameCharPos = transformToWorldCoordinates(gameCharObj[1].AbsolutePosition) 
		if mouseInWorld and mouseInWorld.X > gameCharObj[1].Position.X.Scale then 
			--gameCharObj[1].Image = "http://www.roblox.com/asset/?id=58461425" 
			projectileClone.Position = gameCharObj[1].Position + UDim2.new(0.01, 0, 0.025, 0) 
		else 
			--gameCharObj[1].Image = "http://www.roblox.com/asset/?id=58462272" 
			projectileClone.Position = gameCharObj[1].Position + UDim2.new(-0.01, 0, 0.025, 0) 
		end 
		projectileClone.Parent = gameFrame 
		table.insert(gameProjectileClones, projectileClone) 		
		local direction = (mouseInWorld - gameCharPos).unit 
		if projectileSound then projectileSound:Play() end 
		coroutine.resume(coroutine.create(function() fire(projectileClone, direction) end))                
		wait(0.75) 
		gameCharObj.Firing = false 
	end 
end 

function onActivated()
	if Tool.Enabled == false then 
		return
	end
	
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	if myTorso == nil or myHumanoid == nil then 
		return  
	end

	myTorso.Anchored = true 
	myHumanoid.WalkSpeed = 0.0	

	if vPlayer then 
		createGameInterface() 
	end

	while gameCharObj == nil do wait() end

	World:Update()

	wait(200.0)
	myTorso.Anchored = true 
	myHumanoid.WalkSpeed = 0.0
	Tool.Enabled = true 
end

function onEquipped(mouse)
	if mouse then 
		mouse.KeyDown:connect(charMovementStart)
		mouse.KeyUp:connect(charMovementStop)
		mouse.Button1Down:connect(function() gameCharFire(mouse) end) 
		mouse.Icon = "http://www.roblox.com/asset/?id=66229629"
	end
end

function onUnequipped()
	if myTorso then 
		myTorso.Anchored = false
	end
	if myHumanoid then 
		myHumanoid.WalkSpeed = 16.0
	end
	if gameScreen then gameScreen:Destroy() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

function World:Update()
	while true do				
		World:SetCharacterVelocity()
		World:SimulatePhysics()		
		World:SimulateMovement()	
		World:ScrollWorld()
		World:SpawnEnemy()
		World:AIUpdate()
		World:CheckEvents()
		wait() -- 30 FPS
	end
end
