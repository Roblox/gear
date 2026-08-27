wait(2.0)

local Brain = script.Parent

while script:FindFirstChild("Summoner") == nil do 
	wait()
end

local summoner = script.Summoner
summoner = script.Summoner.Value 

if summoner == nil then script:Remove() end 

local targetEnemyTorso = nil
local targetEnemyHumanoid = nil

local checkAOE = Vector3.new(14, 14, 14)

local zombie = game:GetService("InsertService"):LoadAsset(64630774)
if zombie then zombie = zombie:GetChildren()[1] end

if zombie == nil then Brain:Remove() end 

local zombieHumanoid = zombie:FindFirstChild("Humanoid")
local zombieTorso = zombie:FindFirstChild("Torso")

while zombieHumanoid.Health < 250 do 
	zombieHumanoid.Health = 250
	wait()
end

while targetEnemyTorso == nil do 
	local parts = game.Workspace:FindPartsInRegion3(Region3.new(Brain.Position - checkAOE, Brain.Position + checkAOE), summoner, 100)
	for i = 1, #parts do 
		if parts[i] and parts[i].Parent then 
			local character = parts[i].Parent
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if character ~= zombie and humanoid ~= nil and torso ~= nil then 
				targetEnemyTorso = torso
				targetEnemyHumanoid = humanoid
			end
		end
	end
	wait(1.0)
end

zombie.Parent = game.Workspace
zombie:MoveTo(Brain.Position)

function bite(hit)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then 
			humanoid:TakeDamage(15)
		end
	end
end


zombieTorso.Touched:connect(bite) 

local duration = 20.0 

while duration > 0 and targetEnemyHumanoid.Health > 0 and zombieHumanoid and zombieTorso do 
	local ray = game.Workspace:FindPartOnRay(Ray.new(zombieTorso.Position + Vector3.new(0, -2, 0), zombieTorso.CFrame.lookVector * 3.0), nil)
	if ray then 
		zombieHumanoid.Jump = true 
	end
	if targetEnemyTorso then 
		zombieHumanoid:MoveTo(targetEnemyTorso.Position, targetEnemyTorso)
	end
	duration = duration - wait(0.1)
	wait(0.1) 
end

wait(2.0)

if zombie then zombie:Remove() end
if Brain then Brain:Remove() end


