while script:FindFirstChild("CloneVal") == nil do 
	wait()
end

local clone = script.CloneVal

while clone.Value == nil do 
	wait()
end 

clone = clone.Value

--local clone = script.Parent 

while clone:FindFirstChild("Target") == nil do 
	wait()
end

local target = clone.Target

if target.Value == nil then 
	clone:Remove()
end 

local cloneHumanoid = clone:FindFirstChild("Humanoid")
local cloneTorso = clone:FindFirstChild("Torso")

local enemyHumanoid = target.Value 

if cloneHumanoid then 	
	cloneHumanoid.WalkSpeed = 24.0
end 

function slash(hit)
	if hit and hit.Parent then           
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and humanoid ~= cloneHumanoid and humanoid == enemyHumanoid then                
			humanoid:TakeDamage(15)      
			if humanoid.Health == 0 then 
				wait(2.0)
				if clone then clone:Remove()  end
				if script then script:Remove() end 
			end 
		end
	end
end 

cloneTorso.Touched:connect(slash)

local children = clone:GetChildren()
for i = 1, #children do 
	if children[i].ClassName == "Tool" then 
		if children[i]:FindFirstChild("Handle") then 
			children[i].Handle.Touched:connect(slash) 
		end 
	end 
end 

local targetEnemy = enemyHumanoid.Parent 
local targetEnemyTorso 

if targetEnemy then 
	targetEnemyTorso = targetEnemy:FindFirstChild("Torso")
	if targetEnemyTorso == nil then
		clone:Remove()
	end 
else 
	clone:Remove() 
end 

local animating = false

local checkAOE = Vector3.new(15, 15, 15)

while true do     
	local ray = game.Workspace:FindPartOnRay(Ray.new(cloneTorso.Position + Vector3.new(0, -2, 0), cloneTorso.CFrame.lookVector * 5.0), nil)
	if ray and cloneHumanoid and ray.Parent ~= targetEnemy then
		cloneHumanoid.Jump = true
	end     
	if targetEnemyTorso then           
		local distance = (targetEnemyTorso.Position - cloneTorso.Position).magnitude
		local targetEnemy = targetEnemyTorso.Parent
		local targetEnemyHumanoid = targetEnemy:FindFirstChild("Humanoid")		
		cloneHumanoid:MoveTo(targetEnemyTorso.Position, targetEnemyTorso)     
		if distance < 4 and not animating then 
			animating = true
			local slashAnim = cloneHumanoid:LoadAnimation(script:FindFirstChild("SlashAnim"))
			if slashAnim then slashAnim:Play() end 
			coroutine.resume(coroutine.create(function() wait(1.25) animating = false end))
		end 
	else
		clone:Remove()         
	end
	wait()
end 
