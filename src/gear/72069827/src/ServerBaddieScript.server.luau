local Tool = script.Parent
local Board = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local vPlayer

local damage = 16

local bg

local slowCo = nil

local torsoFrame = {}

local debris = game:GetService("Debris")

local spin = Tool:FindFirstChild("Spin")
while spin ==  nil do 	
	wait()	
	spin = Tool:FindFirstChild("Spin")
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

function slow(humanoid)
	if humanoid then  
		humanoid.WalkSpeed = 12.0 
		wait(3.0) 
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
		if humanoid and humanoid ~= myHumanoid and myHumanoid ~= nil and not hit.Parent:FindFirstChild("ForceField") then
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
			if slowCo == nil or coroutine.status(slowCo) == "dead" then 
				slowCo = coroutine.create(function() slow(humanoid) end)
				coroutine.resume(slowCo)
			end	
			if math.random() < 0.11 then 
				if hit then hit:BreakJoints() end 
			end 
		end
	end
end

function boardUp()
	Tool.GripForward = Vector3.new(-1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
	Tool.GripRight = Vector3.new(0, 1, 0)	
	Tool.GripUp = Vector3.new(0, 0, 1)
end

function boardDown()
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

	for i = 1, 150 do 
		local c = i%6 + 1 
		if bg and torsoFrame[c] then bg.cframe = torsoFrame[c] end 
		wait() 
	end     
	if bg then bg:Remove() end
end

function destroyEverything()
	local sign = 1 
	local missiles = {} 
	spin = Tool:FindFirstChild("Spin")
	if spin and spin.Value == 1 then 
		vCharacter = Tool.Parent 
		myHumanoid = vCharacter:FindFirstChild("Humanoid") 
		myTorso = vCharacter:FindFirstChild("Torso") 
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

		if myHumanoid == nil or myTorso == nil then            
			return 
		end 

		laughSound = Board:FindFirstChild("Laugh") 
		if laughSound then laughSound:Play() end 		

		local initDirection = myTorso.CFrame.lookVector

		coroutine.resume(coroutine.create(cyclone))

		boardDown()		
		-- 
		wait(5.0) 
		boardUp()		
		if bg then bg:Remove() end				
		wait(30.0)
		spin.Value = 0
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

spin.Changed:connect(destroyEverything)

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Board.Touched:connect(blow)