-----------------
--| Constants |--
-----------------

local COOLDOWN = 0.5 --TODO: 4 -- Seconds until Tool can be used again
local TIME_TO_LIVE = 300 -- Seconds until the pet is destroyed
local RESPAWN_TIME = 4 -- Seconds until pet can be re-summoned (only after death)

--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

-----------------
--| Variables |--
-----------------

local InsertService = Game:GetService('InsertService')
local DebrisService = Game:GetService('Debris')
local PlayersService = Game:GetService('Players')

local Tool = script.Parent
local ToolHandle = Tool.Handle

local AiScript = WaitForChild(script, 'CrashAi')
local OwnerTag = WaitForChild(AiScript, 'Owner')

local SummonSound --TODO: = WaitForChild(ToolHandle, 'Laugh1')

local AnimationScript = WaitForChild(Tool, 'PetAnimation')
local PetObject = WaitForChild(AnimationScript, 'Pet')

local MyModel = nil
local MyTorso = nil
local MyHumanoid = nil

local Pet = nil
local AnimationScriptClone = nil

-----------------
--| Functions |--
-----------------

local function OnEquipped()
	MyModel = Tool.Parent
	MyTorso = MyModel:FindFirstChild('Torso')
	MyHumanoid = MyModel:FindFirstChild('Humanoid')
	OwnerTag.Value = MyModel
end

local function Summon()
	if not MyTorso or not MyHumanoid then return end

	local superModel = InsertService:LoadAsset(93746797):GetChildren()[1]
	if not superModel then return end

	Pet = superModel:FindFirstChild('Crash')
	local pickleJar = superModel:FindFirstChild('PickleJar')
	local dynamite = superModel:FindFirstChild('Dynamite')

	if Pet and pickleJar and dynamite then
		DebrisService:AddItem(Pet, TIME_TO_LIVE) -- Make sure it will get deleted

		local humanoid = Instance.new('Humanoid')
		humanoid.MaxHealth = 1000
		humanoid.Health = 1000
		humanoid.WalkSpeed = 24
		humanoid.Parent = Pet

		Pet.Parent = Workspace
		ToolHandle.Transparency = 1.0

		local torso = WaitForChild(Pet, 'Torso')
		torso.Anchored = false

		-- Play the summoning sound
		if SummonSound then SummonSound:Play() end

		-- Send pet object to AnimationScript
		PetObject.Value = Pet

		-- Clone AnimationScript to MyModel
		local animationScriptClone = AnimationScript:Clone()
		AnimationScriptClone = animationScriptClone
		DebrisService:AddItem(animationScriptClone, TIME_TO_LIVE)
		animationScriptClone.Parent = MyModel
		animationScriptClone.Disabled = false

		-- Clone AiScript to Pet
		local aiScriptClone = AiScript:Clone()
		aiScriptClone.Parent = Pet
		do -- Send the attachments
			local pickleJarObject = Instance.new('ObjectValue', aiScriptClone)
			pickleJarObject.Name = 'PickleJar'
			pickleJarObject.Value = pickleJar
			local dynamiteObject = Instance.new('ObjectValue', aiScriptClone)
			dynamiteObject.Name = 'Dynamite'
			dynamiteObject.Value = dynamite
		end
		aiScriptClone.Disabled = false

		-- On Pet death, clean up and show the handle
		humanoid.Died:connect(function()
			if AnimationScriptClone then AnimationScriptClone:Destroy() end
			DebrisService:AddItem(Pet, RESPAWN_TIME)
			wait(RESPAWN_TIME)
			ToolHandle.Transparency = 0.0
		end)

		-- After TIME_TO_LIVE, show the handle
		coroutine.resume(coroutine.create(function()
			wait(TIME_TO_LIVE + 0.1)
			if not Pet:FindFirstChild('Humanoid') then
				ToolHandle.Transparency = 0.0
			end
		end))

		-- Health has problems being set directly
		Delay(5, function() if humanoid then humanoid:TakeDamage(-900) end end)
		--[[Spawn(function()
			while Pet and humanoid do
				humanoid.MaxHealth = 1000
				humanoid.Health = 1000
				wait(1)
			end
		end)]]

		Pet:MoveTo(MyTorso.Position + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
	end
end

local function OnActivated()
	if not Tool.Enabled or not MyTorso or not MyHumanoid then return end

	Tool.Enabled = false

	if not Pet or not Pet.Parent then
		Summon()
	end

	-- Raycast to click location for ClickTarget setting
	local target = MyHumanoid.TargetPoint
	local direction = (target - MyTorso.Position).unit
	local hit = Game.Workspace:FindPartOnRay(Ray.new(MyTorso.Position, direction * 150), MyModel)
	if hit and Pet and Pet:FindFirstChild('ClickTarget') then
		local clickedHumanoid = hit.Parent:FindFirstChild('Humanoid')
		if clickedHumanoid and clickedHumanoid.Health > 0 then
			if Pet.ClickTarget.Value == clickedHumanoid then
				Pet.ClickTarget.Value = nil -- Ensures a changed event
			end
			Pet.ClickTarget.Value = clickedHumanoid
			wait(COOLDOWN) -- Only wait if they clicked a valid target
		else
			Pet.ClickTarget.Value = nil
		end
	end

	Tool.Enabled = true
end

local function OnUnequipped()
	if Pet then Pet:Destroy() end
	if SummonSound then SummonSound:Stop() end
	if AnimationScriptClone then AnimationScriptClone:Destroy() end
	ToolHandle.Transparency = 0.0
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)
