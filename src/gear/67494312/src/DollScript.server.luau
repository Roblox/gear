local Tool = script.Parent 
local Doll = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 
local vPlayer 

local activeSound

local equipped

local assetAwarded = false 

function returnToDefault()
	wait(4.0)
	Tool.GripPos = Vector3.new(0, 0, -1)    
end 

-- Randomly awards or removes assets from you
function annoy()
	while equipped and myTorso and myHumanoid do 
		tick()		
		local randomElement = math.random(1, 100)			
		if randomElement == 1 then
			--
			local AOE = Vector3.new(14, 14, 14)
			local players = game.Players:GetChildren() 
			for i = 1, #players do 
				if players[i] and players[i].Character and (players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso")) then 
					local torso = players[i].Character:FindFirstChild("Torso") or players[i].Character:FindFirstChild("UpperTorso") 
					local distance = (torso.Position - myTorso.Position).magnitude
					if distance < 12 and vPlayer:FindFirstChild("Backpack") then 
						activeSound = Doll:FindFirstChild("HereYouGo") 
						if activeSound then activeSound:Play() end
						local randomItem = vPlayer.Backpack:GetChildren()[math.random(1, #vPlayer.Backpack:GetChildren())]
						randomItem.Parent = game.Workspace
						if randomItem:FindFirstChild("Handle") then
							randomItem.Handle.Velocity = (torso.Position - myTorso.Position).unit * 30.0
						end 
					end 
				end
			end 
		elseif randomElement > 1 and randomElement < 4 and not assetAwarded then 
			-- Award asset 
				local asset = game:GetService("InsertService"):LoadAsset(19704172)
				asset = asset:GetChildren()[1] 
				asset.Parent = vPlayer.Backpack
				assetAwarded = true 
				activeSound = Doll:FindFirstChild("HereYouGo2") 
				if activeSound then activeSound:Play() end
		elseif randomElement > 4 and randomElement < 9 then 
			if myHumanoid then myHumanoid.Sit = true end 
			activeSound = Doll:FindFirstChild("TakeThisNoob") 
			if activeSound then activeSound:Play() end 
		elseif randomElement > 9 and randomElement < 18 then 
			if myHumanoid and myHumanoid.WalkSpeed == 16 then myHumanoid.WalkSpeed = 22.0 end 
			activeSound = Doll:FindFirstChild("HereYouGo2")
			if activeSound then activeSound:Play() end 
		end 
			
		wait(1.5)
	end 
end 

function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if myTorso == nil or myHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 

	tick()

	if math.random() < 0.33 then 
		Tool.GripPos = Vector3.new(1.5, 1.5, -2.75)
	elseif math.random() < 0.67 then 
		Tool.GripPos = Vector3.new(0, 1.8, -1.7)
	else 
		Tool.GripPos = Vector3.new(3, 1.8, -1.7)
	end 

	coroutine.resume(coroutine.create(returnToDefault))

	wait(6.0)
	Tool.Enabled = true 
end

function onEquipped()
	equipped = true
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	coroutine.resume(coroutine.create(annoy))
end

function onUnequipped()
	if activeSound then activeSound:Stop() end
	equipped = false 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)