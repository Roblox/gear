wait()

local Egg = script.Parent

while script:FindFirstChild("Summoner") == nil do 
	wait()
end

local summoner = script.Summoner
summoner = script.Summoner.Value 

if summoner == nil then script:Destroy() end 

local targetEnemyTorso = nil
local targetEnemyHumanoid = nil

local checkAOE = Vector3.new(14, 14, 14)

local debris = game:GetService("Debris")

local alien = game:GetService("InsertService"):LoadAsset(69489068)
if alien then alien = alien:GetChildren()[1] end

if alien == nil then Egg:Destroy() end 

local alienHumanoid = alien:FindFirstChild("Humanoid")
local alienTorso = alien:FindFirstChild("Torso") or alien:FindFirstChild("UpperTorso")

while alienHumanoid.Health < 200 do 
	alienHumanoid.Health = 200
	wait()
end

debris:AddItem(alien, 21) 

while targetEnemyTorso == nil do 
	local parts = game.Workspace:FindPartsInRegion3(Region3.new(Egg.Position - checkAOE, Egg.Position + checkAOE), summoner, 100)
	for i = 1, #parts do 
		if parts[i] and parts[i].Parent then 
			local character = parts[i].Parent
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
			if character ~= alien and humanoid ~= nil and torso ~= nil and humanoid.Health > 0 then 
				targetEnemyTorso = torso
				targetEnemyHumanoid = humanoid
			end
		end
	end
	wait(1.0)
end

local screamSound = script:FindFirstChild("Scream")
if screamSound then screamSound:Play() end

alien.Parent = game.Workspace
alien:MoveTo(Egg.Position)

if Egg then Egg.Transparency = 1.0 end 

function bite(hit)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent.ClassName == "Hat" and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid then 
			humanoid:TakeDamage(15)
		end
	end
end

alienTorso.Touched:connect(bite) 

local duration = 20.0 

while duration > 0 and targetEnemyHumanoid.Health > 0 and alienHumanoid and alienTorso do 
	local ray = game.Workspace:FindPartOnRay(Ray.new(alienTorso.Position + Vector3.new(0, -2, 0), alienTorso.CFrame.lookVector * 3.0), nil)
	if ray then 
		alienHumanoid.Jump = true 
	end
	if targetEnemyTorso then 
		alienHumanoid:MoveTo(targetEnemyTorso.Position, targetEnemyTorso)
	end
	duration = duration - wait(0.1)
	wait(0.1) 
end

wait(2.0)

if alien then alien:Destroy() end
if Egg then Egg:Destroy() end


