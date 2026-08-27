--by QuantumSama
--egg models being spawned can have problems if scripts are disabled.  (my scripts depend on getting
--  the initial welds.  if those welds are broken the egg won't work)
--Must test each egg to be spawned from this
--Notes: egg buttons are 40 x 40 and take up 41 pixels across

--Variables
local eggModel = game.Workspace.Eggs --TODO: add .NameOfModelStoringAllTheEggs
local eggs = {
					"AntiGravityEgg", 
					"VampireEgg", 
					"LockedEgg", 
					"LastEgg", 
					"HyperactiveEgg", 
					"Eggcognito"
					}
local cooldown = 20  --Should be at least 20
local crown1, crown2 = 76695524, 76695554

--End Variables
r = game:service("RunService")

local Tool = script.Parent
local cannon = Tool.Handle 
local player

local debris = game:GetService("Debris")

local eggSelected = 1

local playerGui = nil
local eggButtons

function spawnEgg(velocity)
	local spawnPoint = cannon.Position + velocity * .07
	local newEgg
	if eggSelected == 1 then 
		newEgg = game.Lighting:FindFirstChild(egg1):Clone()
	elseif eggSelected == 2 then 
		newEgg = game.Lighting:FindFirstChild(egg2):Clone()
	elseif eggSelected == 3 then 
		newEgg = game.Lighting:FindFirstChild(egg3):Clone()
	elseif eggSelected == 4 then 
		newEgg = game.Lighting:FindFirstChild(egg4):Clone()
	elseif eggSelected == 5 then 
		newEgg = game.Lighting:FindFirstChild(egg5):Clone()
	elseif eggSelected == 6 then 
		newEgg = game.Lighting:FindFirstChild(egg6):Clone()
	end


	if newEgg:IsA("Model") then 
		local trans = spawnPoint - newEgg:GetModelCFrame().p
		newEgg:TranslateBy(trans)
		local modelChildren = newEgg:GetChildren()
		for i=1, #modelChildren do 
			if modelChildren[i]:IsA("Part") then modelChildren[i].Velocity = velocity end
		end
	elseif newEgg:IsA("Part") then
		newEgg.Position = spawnPoint
		newEgg.Velocity = velocity
	end

	local eggChildren = newEgg:GetChildren()
	for i=1, #eggChildren do 
		if eggChildren[i]:IsA("Script") then eggChildren[i].Disabled = true end
	end
	newEgg.Parent = eggModel
	wait(5)
	for i=1, #eggChildren do 
		if eggChildren[i]:IsA("Script") then eggChildren[i].Disabled = false end
	end
end

Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then
		print("Tool not Enabled")
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end
	
	local targetPos = humanoid.TargetPoint
	local direction = targetPos - cannon.Position
	local velocity = direction + Vector3.new(0,40,0)
	velocity = velocity.unit *60
	
	print("Setting _G stuff") 
	_G["EggCannon"][math.random(1, 10000000)] = {
		["EggName"] = eggs[eggSelected],
		["Position"] = cannon.Position + (character.Torso.CFrame.lookVector * 7.0),
		["Direction"] = direction 
	}
	--spawnEgg(velocity)

	local reloadTime = cooldown
	player = game.Players:playerFromCharacter(character)
	if game:GetService("BadgeService"):UserHasBadge(player.userId, crown1) then reloadTime = reloadTime/2 end
	if game:GetService("BadgeService"):UserHasBadge(player.userId, crown2) then reloadTime = reloadTime/2 end
	Tool.Reload.Value = reloadTime
	wait(reloadTime)

	Tool.Enabled = true
end

function selectEgg(selected)
	eggSelected = selected
	for i = 1, #eggButtons do
		eggButtons[i].Selected = (i == selected)
	end
end

function onEquipped()
	playerGui = Tool.EggsGui:Clone()
	player = game.Players:playerFromCharacter(script.Parent.Parent)
	playerGui.Parent = player.PlayerGui
	local eggFrame = playerGui.EggFrame
	eggButtons = {eggFrame.Egg1, eggFrame.Egg2, eggFrame.Egg3, eggFrame.Egg4, eggFrame.Egg5, eggFrame.Egg6}
	for i = 1, #eggButtons do
		eggButtons[i].Selected = (i == eggSelected)
	end
	eggFrame.Egg1.MouseButton1Click:connect(function() selectEgg(1) end)
	eggFrame.Egg2.MouseButton1Click:connect(function() selectEgg(2) end)
	eggFrame.Egg3.MouseButton1Click:connect(function() selectEgg(3) end)
	eggFrame.Egg4.MouseButton1Click:connect(function() selectEgg(4) end)
	eggFrame.Egg5.MouseButton1Click:connect(function() selectEgg(5) end)
	eggFrame.Egg6.MouseButton1Click:connect(function() selectEgg(6) end)
end

function onUnequipped()
	print("Tool unequipped, clean up...")
	if playerGui ~= nil then playerGui:Destroy() end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)


