local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local vPlayer

local snake = Instance.new("Part") 
snake.FormFactor = 3 
snake.Shape = "Block" 
snake.Size = Vector3.new(0.4, 0.4, 0.4) 
snake.CanCollide = false 
snake.Transparency = 0.7

local snakeBullet = Instance.new("SpecialMesh") 
snakeBullet.MeshId = "http://www.roblox.com/asset/?id=57810032" 
snakeBullet.TextureId = "http://www.roblox.com/asset/?id=57809568" 
snakeBullet.Parent = snake 
snakeBullet.Scale = Vector3.new(2, 2, 2) 

local snakeFire = Instance.new("Fire") 
snakeFire.Color = Color3.new(0, 0, 1) 
snakeFire.SecondaryColor = Color3.new(0, 153/255, 1)
snakeFire.Parent = snake 
snakeFire.Size = 2.0 
snakeFire.Heat = 2.0 

local snakeDamage = 12
local damage = 24

local bg

local slowCo = nil

local torsoFrame = {}

local debris = game:GetService("Debris")

local storm = Tool:FindFirstChild("Storm")
while storm ==  nil do 	
	wait()
	storm = Tool:FindFirstChild("Storm")
end

function tagHumanoid(humanoid, player) 
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue") 
		creatorTag.Name = "creator" 
		creatorTag.Parent = humanoid 
		creatorTag.Value = player 
		debris:AddItem(creatorTag, 1.5) 
	end 
end 

function pierce(missile, hit) 
	local humanoid	
	if missile then 		
		if hit and hit.Parent then 			
			if hit.Parent.className == "Hat" then 
				humanoid = hit.Parent.Parent:FindFirstChild("Humanoid") 
			else 
				humanoid = hit.Parent:FindFirstChild("Humanoid") 
			end 			
			if humanoid ~= nil and myHumanoid ~= humanoid and myHumanoid ~= nil then 
				tagHumanoid(humanoid, vPlayer) 			
				humanoid:TakeDamage(snakeDamage)     			
			end 
		end 
	end 
end 

function slow(humanoid)
	if humanoid then  
		humanoid.WalkSpeed = 10.0 
		wait(4.0) 
		humanoid.WalkSpeed = 16.0
	end
end

function blow(hit)	
	local humanoid
	if hit and hit.Parent then 
		if hit.Parent.className == "Hat" then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid") 
		else 
			humanoid = hit.Parent:FindFirstChild("Humanoid") 
		end 			
		if humanoid and humanoid ~= myHumanoid and myHumanoid ~= nil then			
			tagHumanoid(humanoid, vPlayer)
			
			humanoid:TakeDamage(damage)
			if slowCo == nil or coroutine.status(slowCo) == "dead" then 
				slowCo = coroutine.create(function() slow(humanoid) end)
				coroutine.resume(slowCo)
			end
		end
	end
end

function swordUp()
	Tool.GripForward = Vector3.new(0, -1, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripRight = Vector3.new(-1, 0, 0)	
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function swordDown()
	Tool.GripUp = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripForward = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 1 , 0)
end

function cyclone()	
	if myTorso == nil then return end

	bg = Instance.new("BodyGyro") 
	bg.P = 100000 
	bg.maxTorque = Vector3.new(bg.P, bg.P, bg.P) 
	bg.Name = "BG" 

	torsoFrame[1] = myTorso.CFrame * CFrame.Angles(0, 1*math.pi/3, 0) 
	torsoFrame[2] = myTorso.CFrame * CFrame.Angles(0, 2*math.pi/3, 0) 
	torsoFrame[3] = myTorso.CFrame * CFrame.Angles(0, math.pi, 0) 
	torsoFrame[4] = myTorso.CFrame * CFrame.Angles(0, 4*math.pi/3, 0) 
	torsoFrame[5] = myTorso.CFrame * CFrame.Angles(0, 5*math.pi/3, 0) 
	torsoFrame[6] = myTorso.CFrame 

	bg.Parent = myTorso 

	for i = 1, 60 do 
		local c = i%6 + 1 
		if bg then bg.cframe = torsoFrame[c] end 
		wait() 
	end     
	if bg then bg:Remove() end
end

function destroyEverything()
	local sign = 1 
	local missiles = {} 
	storm = Tool:FindFirstChild("Storm")
	if storm and storm.Value == 1 then 
		vCharacter = Tool.Parent 
		myHumanoid = vCharacter:FindFirstChild("Humanoid") 
		myTorso = vCharacter:FindFirstChild("Torso") 
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

		if myHumanoid == nil or myTorso == nil then            
			return 
		end 

		laughSound = Sword:FindFirstChild("Laugh") 
		if laughSound then laughSound:Play() end 

		--myTorso.Anchored = true 
		myHumanoid.WalkSpeed = 0.0   

		local initDirection = myTorso.CFrame.lookVector

		coroutine.resume(coroutine.create(cyclone))

		swordDown()

		for i = 1, 150 do                 
			local direction 
			if (i)%30.0 == 0 then                           
				wait(0.25) 
			end 
			local num = i%30 
			if num == 0 then 
				direction = myTorso.CFrame.lookVector
			else 
				direction = CFrame.Angles(0, (num-1) * sign * math.pi/15, 0) * myTorso.CFrame.lookVector 
			end 
			local spawnPos = (Sword.Position - Vector3.new(0, 2, 0)) + direction * 4.0 
			sign = sign * -1 

			missiles[i] = snake:Clone() 
			missiles[i].CFrame = (CFrame.new(spawnPos, spawnPos + direction)) 
			missiles[i].Velocity = direction * 70.0 
			missiles[i].RotVelocity = Vector3.new(0, 10, 0) 

			local floatForce = Instance.new("BodyForce") 
			floatForce.force = Vector3.new(0, missiles[i]:GetMass() * 196.1, 0) 
			floatForce.Parent = missiles[i] 

			missiles[i].Parent = game.Workspace           

			missiles[i].Touched:connect(function(hit) pierce(missiles[i], hit) end) 
			debris:AddItem(missiles[i], 1.25)                
		end 
		-- 
		wait(0.75) 
		swordUp()
		--myTorso.Anchored = false 
		if bg then bg:Remove() end
		myHumanoid.WalkSpeed = 16.0 		
		wait(30.0)
		storm.Value = 0
	end
end

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end

function onUnequipped()
	torsoFrame = {}
	if bg then bg:Remove() end
end

storm.Changed:connect(destroyEverything)

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Sword.Touched:connect(blow)