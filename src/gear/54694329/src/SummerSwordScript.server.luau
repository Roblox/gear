-- Can summon leaves to do massive amounts of damage and blast enemies away
-- slash has wider reach
-- 12% chance to heal yourself when doing damage
-- +2 hp regeneration per second

local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local myTorso

Tool.Enabled = true 

local slashSound

local damage = 24

local debris = game:GetService("Debris")

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then
		creator = Instance.new("ObjectValue")
		creator.Name = "creator"
		creator.Value = player
		creator.Parent = humanoid
		debris:addItem(creator, 1)
	end
end

function blow(hit)
	if hit.Parent then
		humanoid = hit.Parent:FindFirstChild("Humanoid")
	end
	vCharacter = Tool.Parent
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then		
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then 			
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then 
				print("Doing Damage")
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				local heal = math.random(1, 100)
				if heal <= 12 then
					if (myHumanoid.Health + 10) <= myHumanoid.MaxHealth then 
						myHumanoid.Health = myHumanoid.Health + 10
					else
						myHumanoid.Health = myHumanoid.MaxHealth
					end
				end
			end
		end
	end
end

function onActivated()
	if Tool.Enabled == false then 
		return
	end

	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then return end

	wait(1.0)
	Tool.Enabled = true
end

function onEquipped()	
	regenScript = Tool:FindFirstChild("RegenScript")
	if regenScript then
		regenScript.Disabled = false
	end
	checkScript = Tool:FindFirstChild("CheckForAllSeasons")
	if checkScript then 
		checkScript.Parent = Tool.Parent
	end
end

function onUnEquipped()
	if slashSound then slashSound:Stop() end
	regenScript = Tool:FindFirstChild("RegenScript")
	if regenScript then
		regenScript.Disabled = true
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)