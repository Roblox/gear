while script:FindFirstChild("Monkey") == nil do 
	wait()
end

local petMonkey = script.Monkey

while petMonkey.Value == nil do 
	wait()
end 

petMonkey = petMonkey.Value

while petMonkey:FindFirstChild("Target") == nil do 
	wait()
end

local target = petMonkey.Target

if target.Value == nil then 
	--petMonkey:Destroy()
end 

-- Best part about doing this from the character 
local vCharacter = script.Parent
local myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")

local petMonkeyHumanoid = petMonkey:FindFirstChild("Humanoid")
local petMonkeyTorso = petMonkey:FindFirstChild("Torso")

local debris = game:GetService("Debris")

local enemyHumanoid = target.Value 

if petMonkeyHumanoid then 	
	petMonkeyHumanoid.WalkSpeed = 24.0
	
	while petMonkeyHumanoid.MaxHealth < 350 do 
		petMonkeyHumanoid.MaxHealth = 350 
		wait()
	end

	while petMonkeyHumanoid.Health < 350 do 
		petMonkeyHumanoid.Health = 350 
		wait()
	end
end 

local healCount = 0

function slash(hit)
	if hit and hit.Parent then           
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= petMonkeyHumanoid and humanoid == enemyHumanoid and humanoid ~= myHumanoid then                
			humanoid:TakeDamage(15)      
			if myHumanoid then 
				if myHumanoid.Health + 4 < myHumanoid.MaxHealth then 
					myHumanoid.Health = myHumanoid.Health + 4 
					if myTorso  and myTorso:FindFirstChild("MonkeyFire") == nil then 
						local fire = Instance.new("Fire")
						fire.Parent = myTorso 
						fire.Name = "MonkeyFire"
						fire.Color = Color3.new(0, 0, 0)
						fire.SecondaryColor = Color3.new(1, 0, 0)
						fire.Size = 4
						debris:AddItem(fire, 1.5)
					end 
				end 
			end 
			if humanoid.Health == 0 then 			
				followCharacter = true 				
			end 
		end
	end
end 

local petMonkeyLeftArm = petMonkey:FindFirstChild("Left Arm")
local petMonkeyRightArm = petMonkey:FindFirstChild("Right Arm")
local petMonkeyLeftLeg = petMonkey:FindFirstChild("Left Leg")
local petMonkeyRightLeg = petMonkey:FindFirstChild("Right Leg")

if petMonkeyLeftArm then
	petMonkeyLeftArm.Touched:connect(slash)
end

if petMonkeyRightArm then 
	petMonkeyRightArm.Touched:connect(slash)
end 

if petMonkeyRightLeg then 
	petMonkeyRightLeg.Touched:connect(slash)
end 

if petMonkeyLeftLeg then 
	petMonkeyLeftLeg.Touched:connect(slash)
end

petMonkeyTorso.Touched:connect(slash)

local children = petMonkey:GetChildren()
for i = 1, #children do 
	if children[i]:IsA("Tool") then 
		if children[i]:FindFirstChild("Handle") then 
			children[i].Handle.Touched:connect(slash) 
		end 
	end 
end 


local targetEnemy 
if enemyHumanoid then targetEnemy = enemyHumanoid.Parent end
local targetEnemyTorso 

if targetEnemy then 
	targetEnemyTorso = targetEnemy:FindFirstChild("Torso") or targetEnemy:FindFirstChild("UpperTorso")
	if targetEnemyTorso == nil then
		--petMonkey:Destroy()
	end 
else 
	--petMonkey:Destroy() 
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

while true do     
	local ray = workspace:FindPartOnRay(Ray.new(petMonkeyTorso.Position, petMonkeyTorso.CFrame.lookVector * 5.0), nil)
	if ray and petMonkeyHumanoid and ray.Parent ~= targetEnemy and ray.Parent ~= vCharacter then
		petMonkeyHumanoid.Jump = true
	end     
	if targetEnemyTorso then           
		local distance = (targetEnemyTorso.Position - petMonkeyTorso.Position).magnitude
		local targetEnemy = targetEnemyTorso.Parent
		if distance < 30 then 
			local targetEnemyHumanoid = targetEnemy:FindFirstChildOfClass("Humanoid")		
			petMonkeyHumanoid:MoveTo(targetEnemyTorso.Position, targetEnemyTorso)     
			if distance < 4 and not animating then 
				animating = true
				local biteAnim = petMonkeyHumanoid:LoadAnimation(script:FindFirstChild("BiteAnim"))
				if biteAnim then biteAnim:Play() end 
				coroutine.resume(coroutine.create(function() wait(1.25) animating = false end))
			end 
		else 
			if myTorso then 
				petMonkeyHumanoid:MoveTo(myTorso.Position + Vector3.new(4, 0, 4), myTorso)
			end 
		end 
	else
		if myTorso then 
			petMonkeyHumanoid:MoveTo(myTorso.Position + Vector3.new(4, 0, 4), myTorso)
		end 
	end
	wait()
end 
