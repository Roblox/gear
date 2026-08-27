local Debris = Game:GetService("Debris")

local Tool = script.Parent
local ToolHandle = Tool.Handle

local laugh1Sound = ToolHandle:FindFirstChild("Laugh1")
local laugh2Sound = ToolHandle:FindFirstChild("Laugh2")
local laugh3Sound = ToolHandle:FindFirstChild("Laugh3")
local summonSounds = {laugh1Sound, laugh2Sound, laugh3Sound}
local currentSound = nil

local cooldown = 4 -- Seconds until Tool can be used again
local timeToLive = 60 -- Seconds until the pet is destroyed
local respawnTime = 4 -- Seconds until pet can be re-summoned (only after death)
local aiScriptName = "TrollAi" -- Name of the script that will be cloned to the player

local myModel
local myTorso
local myHumanoid

local pet
local aiScript

local function summon()
	if not myTorso or not myHumanoid then return end

	pet = Game:GetService("InsertService"):LoadAsset(88117081):GetChildren()[1]
	Debris:AddItem(pet, timeToLive) -- Make sure it will get deleted

	if pet and pet:FindFirstChild("Humanoid") and pet.Humanoid.Health > 0 then
		pet.Parent = Workspace
		ToolHandle.Transparency = 1.0

		-- Play one of the summoning sounds
		if summonSounds and #summonSounds > 0 then
			currentSound = summonSounds[math.random(#summonSounds)]
			if currentSound then currentSound:Play() end
		end

		-- Clone original aiScript to myModel
		local aiScriptOriginal = Tool:FindFirstChild(aiScriptName)
		if aiScriptOriginal then
			aiScript = aiScriptOriginal:Clone()
			Debris:AddItem(aiScript, timeToLive)
			aiScript.Parent = myModel

			while not aiScript:FindFirstChild("Pet") do wait() end
			aiScript.Pet.Value = pet

			aiScript.Disabled = false
		end

		-- On pet death, clean up and show the handle
		pet.Humanoid.Died:connect(function()
			Debris:AddItem(aiScript, 0)
			Debris:AddItem(pet, respawnTime)
			wait(respawnTime)
			ToolHandle.Transparency = 0.0
		end)

		-- After timeToLive, show the handle
		coroutine.resume(coroutine.create(function()
			wait(timeToLive + 0.1)
			if not pet:FindFirstChild("Humanoid") then
				ToolHandle.Transparency = 0.0
			end
		end))

		-- Health has problems being set directly
		pet.Humanoid:TakeDamage(-250)
		while pet.Humanoid.Health < 350 do
			pet.Humanoid.Health = 350
			wait()
		end

		pet:MoveTo(myTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
	end
end

local function onActivated()
	if not Tool.Enabled or not myTorso or not myHumanoid then return end

	Tool.Enabled = false

	if not pet or not pet.Parent then
		summon()
	end

	-- Raycast to click location for ClickTarget setting
	local target = myHumanoid.TargetPoint
	local direction = (target - myTorso.Position).unit
	local hit = Game.Workspace:FindPartOnRay(Ray.new(myTorso.Position, direction * 150), myModel)
	if hit and pet and pet:FindFirstChild("ClickTarget") then
		local clickedHumanoid = hit.Parent:FindFirstChild("Humanoid")
		if clickedHumanoid and clickedHumanoid.Health > 0 then
			pet.ClickTarget.Value = clickedHumanoid
		else
			pet.ClickTarget.Value = nil
		end
	end

	wait(cooldown)

	Tool.Enabled = true
end

local function onEquipped()
	myModel = Tool.Parent
	myTorso = myModel:FindFirstChild("Torso") or myModel:FindFirstChild("UpperTorso")
	myHumanoid = myModel:FindFirstChild("Humanoid")
end

local function onUnequipped()
	if pet then pet:Destroy() end
	if aiScript then aiScript:Destroy() end
	if currentSound then currentSound:Stop() end
	ToolHandle.Transparency = 0.0
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
