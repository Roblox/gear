local Tool = script.Parent
local Staff = Tool.Handle 

local vCharacter 
local myTorso
local myHumanoid

local activeZombies
local summonZombies

local zombieAssetId = 64630774 

local zombies = {}

while Tool:FindFirstChild("SummonZombies") == nil do 
	wait()
end

while Tool:FindFirstChild("ActiveZombies") == nil do 
	wait()
end

activeZombies = Tool.ActiveZombies
summonZombies = Tool.SummonZombies 

function killZombies()
	wait(45.0) 
	if zombies then 
		for i = 1, #zombies  do 
			if zombies[i] then zombies[i]:Remove() end 
		end 
		zombies = {}
	end 

	wait(10.0)
	if activeZombies then activeZombies.Value = false end 
end

summonZombies.Changed:connect(function()
	if summonZombies and summonZombies.Value == true and myTorso then
		for i = 1, 4 do 
			local zombie = game:GetService("InsertService"):LoadAsset(zombieAssetId)
			if zombie then zombie = zombie:GetChildren()[1] end 
			if zombie then
				table.insert(zombies, zombie)
				local parentTag = zombie:FindFirstChild("ParentTag")
				if parentTag then 
					parentTag.Value = vCharacter
				end
				zombie.Parent = game.Workspace
				zombie:MoveTo(myTorso.Position + (CFrame.Angles(0, i * math.pi/2, 0) * myTorso.CFrame.lookVector * 4.0))
				local zombieScript = zombie:FindFirstChild("ZombieAIScript")
				if zombieScript then zombieScript.Disabled = false end 
			end
		end
		if summonZombies then summonZombies.Value = false end
		if activeZombies then activeZombies.Value = true end 
		coroutine.resume(coroutine.create(killZombies))
	end
end)


function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end

Tool.Equipped:connect(onEquipped)
