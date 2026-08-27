local Tool = script.Parent
local Axe = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 

local equipped = false

function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		print("Waiting for ", instance)
		wait()
	end
end

local debris = game:GetService("Debris")

local fireCo

waitForChild(Axe, "DragonSound")
local dragonSound = Axe.DragonSound

waitForChild(Axe, "FirePart")
local firePart = Axe.FirePart

local cf = firePart.CFrame

waitForChild(firePart, "Fire")
local fire = firePart.Fire

local floatForce = Instance.new("BodyForce")
floatForce.force =  Vector3.new(0, firePart:GetMass() * 196.1, 0)

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		debris:AddItem(creatorTag, 1)
	end
end

function blow(hit, fireball)
	local humanoid
	local vPlayer
	if hit and hit.Parent and myHumanoid and fireball then 
		if hit.Parent.className == "Hat" then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		else
			humanoid = hit.Parent:FindFirstChild("Humanoid")
		end
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid ~= nil and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(25)
		end
	end
end

function cut(hit)
	local humanoid
	local vPlayer
	if hit and hit.Parent and myHumanoid then 
		if hit.Parent.className == "Hat" then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		else
			humanoid = hit.Parent:FindFirstChild("Humanoid")
		end
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
		if humanoid ~= nil and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(27)
		end
	end
end


function targetFire()
	wait(4.0)
	while equipped and myTorso do
		local players = game.Players:GetChildren()
		if #players > 1 then 			
			fire.Enabled = false
			for i = 1, #players do 
				if players[i] and players[i].Character and players[i].Character ~= vCharacter and players[i].Character:FindFirstChild("Torso") then 					
					local distance = (myTorso.Position - players[i].Character.Torso.Position).magnitude
					if distance < 40 then 		
						if dragonSound then dragonSound:Play() end 
						local fireball = firePart:Clone()							
						fireball.Name = "Fireball"												
						fireball.Parent = game.Workspace										
						fireball.CFrame = firePart.CFrame	

						waitForChild(fireball, "Fire")					
						
						fireball.Fire.Enabled = true
						fireball.Fire.Color = Color3.new(204/255, 51/255, 0)
						fireball.Fire.SecondaryColor = Color3.new(17/255, 17/255, 17/255)						
		
						local float = floatForce:Clone()
						float.Parent = fireball						

						fireball.Velocity = (players[i].Character.Torso.Position - fireball.Position).unit * 50.0						
						fireball.Touched:connect(function(hit) blow(hit, fireball) end)						
						debris:AddItem(fireball, 4)
					end
				end
			end
		end					
		wait(10.0)		
		fire.Enabled = true
	end
end

function onEquipped()
	if dragonSound then dragonSound:Play() end 
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")	
	equipped = true
	if fireCo == nil or coroutine.status(fireCo) == "dead" then 
		fireCo = coroutine.create(targetFire)
		coroutine.resume(fireCo)
	end
end

function onUnequipped()
	if dragonSound then dragonSound:Stop() end 
	equipped = false
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Axe.Touched:connect(cut)