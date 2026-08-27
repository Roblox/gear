-- // Fixed by StarWars for R15 avatars
while script:FindFirstChild("Anansi") == nil do 
	wait()
end

local petAnansi = script.Anansi

while petAnansi.Value == nil do 
	wait()
end 

petAnansi = petAnansi.Value

while petAnansi:FindFirstChild("Target") == nil do 
	wait()
end

print(0.1) 

local target = petAnansi.Target

local targetEnemyTorso 

if target.Value == nil then 
	--petAnansi:Remove()
end 

-- Best part about doing this from the character 
local vCharacter = script.Parent
local myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local petAnansiHumanoid = petAnansi:FindFirstChild("Humanoid")
local petAnansiTorso = petAnansi:FindFirstChild("Torso")

local debris = game:GetService("Debris")

local enemyHumanoid = target.Value 

if petAnansiHumanoid then 	
	petAnansiHumanoid.WalkSpeed = 18.0
	
	while petAnansiHumanoid.MaxHealth < 150 do 
		petAnansiHumanoid.MaxHealth = 150 
		wait()
	end

	while petAnansiHumanoid.Health < 150 do 
		petAnansiHumanoid.Health = 150 
		wait()
	end
	
	petAnansiHumanoid.Died:connect(function()
		petAnansi:Destroy() 
		script:Destroy() 
	end)
end 

print(0.2)

local healCount = 0

function slash(hit)	
	if hit and not hit:IsA('Terrain') and hit.Parent and hit.Parent.Name ~= 'Anansi' then           		
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= petAnansiHumanoid and humanoid ~= myHumanoid then                			
			humanoid:TakeDamage(15)     			
			if humanoid.Health == 0 then 					
				targetEnemyTorso = nil 				
				followCharacter = true 			
			else 				
			end 
		end
	end
end 

local petAnansiLeftArm  = petAnansi:FindFirstChild("Left Arm")
local petAnansiRightArm  = petAnansi:FindFirstChild("Right Arm")
--[[local petAnansiRightMidArm = petAnansi:FindFirstChild("Right MidArm")
local petAnansiLeftMidArm = petAnansi:FindFirstChild("Left MidArm")
local petAnansiLeftForeArm = petAnansi:FindFirstChild("Left ForeArm")
local petAnansiRightForeArm = petAnansi:FindFirstChild("Right ForeArm")]]


if petAnansiLeftArm  then
	petAnansiLeftArm.Touched:connect(slash)
end

if petAnansiRightArm  then 
	petAnansiRightArm.Touched:connect(slash)
end 

--[[if petAnansiLeftForeArm then
	petAnansiLeftForeArm.Touched:connect(slash)
end 

if petAnansiRightForeArm then 
	petAnansiRightForeArm.Touched:connect(slash)
end 

if petAnansiRightMidArm then 
	petAnansiRightMidArm.Touched:connect(slash)
end 

if petAnansiLeftMidArm then 
	petAnansiLeftMidArm.Touched:connect(slash)
end ]]

local petAnansiHead = petAnansi:FindFirstChild('Head')
if petAnansiHead then 
	petAnansiHead.Touched:connect(slash)
end 

print(0.4) 


petAnansiTorso.Touched:connect(slash)

local children = petAnansi:GetChildren()
for i = 1, #children do 
	if children[i].ClassName == "Tool" then 
		if children[i]:FindFirstChild("Handle") then 
			children[i].Handle.Touched:connect(slash) 
		end 
	end 
end 


local targetEnemy 
if enemyHumanoid then targetEnemy = enemyHumanoid.Parent end

if targetEnemy then 
	targetEnemyTorso = targetEnemy:FindFirstChild("Torso") or targetEnemy:FindFirstChild("UpperTorso")
	targetEnemyHumanoid = targetEnemy:FindFirstChild('Humanoid') 
	if targetEnemyTorso == nil then
		--petAnansi:Remove()
	end 
else 
	--petAnansi:Remove() 
end 

target.Changed:connect(function()
	if target.Value then 
		enemyHumanoid = target.Value 
		targetEnemy = enemyHumanoid.Parent 
		if targetEnemy then 
			targetEnemyTorso = targetEnemy:FindFirstChild("Torso") or targetEnemy:FindFirstChild("UpperTorso")
		end 
	end 
end) 

local animating = false

local checkAOE = Vector3.new(15, 15, 15)

local function FindNearestTorso()
	local parts = Game.Workspace:FindPartsInRegion3(Region3.new(petAnansiTorso.Position - checkAOE, petAnansiTorso.Position + checkAOE), vCharacter, 100)
	for _, part in pairs(parts) do 
		local Torso = part.Parent:FindFirstChild('Torso') or part.Parent:FindFirstChild("UpperTorso")
		if part and part.Parent and Torso and part.Parent ~= "Anansi" then 
			return Torso, part.Parent:FindFirstChild('Humanoid')  	
		end 
	end 
end 

print(0.45) 

local duration = 30 

while duration > 0 do     
	local ray = game.Workspace:FindPartOnRay(Ray.new(petAnansiHead.Position, petAnansiHead.CFrame.lookVector * 5.0), petAnansi)
	if ray and petAnansiHumanoid and ray.Parent ~= petAnansi and ray.Parent ~= vCharacter and ray.Parent.Name == 'Anansi' then
		petAnansiHumanoid.Jump = true		
	end     
	if targetEnemyTorso and targetEnemyHumanoid and targetEnemyHumanoid.Health > 0 then       		
		local distance = (targetEnemyTorso.Position - petAnansiTorso.Position).magnitude
		local targetEnemy = targetEnemyTorso.Parent
		if distance < 60 then 			
			petAnansiHumanoid:MoveTo(targetEnemyTorso.Position, targetEnemyTorso)     
			if distance < 4 and not animating then 
				animating = true
				local biteAnim = petAnansiHumanoid:LoadAnimation(script:FindFirstChild("BiteAnim"))
				if biteAnim then biteAnim:Play() end 
				coroutine.resume(coroutine.create(function() wait(1.25) animating = false end))
			end 
		else 
			if myTorso then 
				petAnansiHumanoid:MoveTo(myTorso.Position + Vector3.new(4, 0, 4), myTorso)
			end 
		end 
	else
		targetEnemyTorso, targetEnemyHumanoid = FindNearestTorso() 
		if not targetEnemyHumanoid or targetEnemyHumanoid.Health == 0 then 
			targetEnemyTorso = nil
		end 
		if not targetEnemyTorso and myTorso then 
			petAnansiHumanoid:MoveTo(myTorso.Position + Vector3.new(4, 0, 4), myTorso)
		end 
	end
	wait(0.1)
	duration = duration - wait(0.1) 
end 

petAnansi:Destroy()
script:Destroy() 
