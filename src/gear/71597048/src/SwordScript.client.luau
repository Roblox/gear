local Tool = script.Parent 
local Sword = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 
local vPlayer

Tool.Enabled = true

local runService = game:service("RunService") 

local damage = 17

local dashTime = 0 
local lastKeyDown = 0 

local debris = game:GetService("Debris")
local runService = game:service("RunService") 

local slashAnim
local swordWalkAnim
local shootAnim

function shootGun(key)
	key = key:lower()
	if key == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
	elseif key == "q" then 
		local fireGun = Tool:FindFirstChild("FireGun")
		if fireGun and fireGun.Value == false then 
			shootAnim = myHumanoid:LoadAnimation(Tool.ShootAnim)
			if shootAnim then shootAnim:Play() end 
			wait(0.1)
			fireGun.Value = true 
		end 
	end
end 

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player 
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1)
	end 
end 

function blow(hit)
	if hit and hit.Parent then
		local humanoid 	
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") and hit.Parent.Parent then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)			

			if hit.Parent:FindFirstChild("PoisonScript") == nil then 
				local freezeScript = Tool.PoisonScript:Clone()
				freezeScript.Parent = hit.Parent 
				freezeScript.Disabled = false
			end 
		end 
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

	t = runService.Stepped:wait() 
	
	slashAnim = myHumanoid:LoadAnimation(Tool.Slash)
	if slashAnim then slashAnim:Play() end 

	wait(0.2)

	local fireGun = Tool:FindFirstChild("FireGun")
	if fireGun and fireGun.Value == false then fireGun.Value = true end 

	wait(1.0)

	Tool.Enabled = true 
	
end

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)	

	if myHumanoid then 
		swordWalkAnim = myHumanoid:LoadAnimation(Tool.SwordWalkAnim)
		if swordWalkAnim then swordWalkAnim:Play() end 
	end 

	if mouse then 
		mouse.KeyDown:connect(shootGun)
	end 
end  

function onUnequipped()
	if slashAnim then slashAnim:Stop() end 
	if throwAnim then throwAnim:Stop() end 
	if swordWalkAnim then swordWalkAnim:Stop() end
	if shootAnim then shootAnim:Stop() end 
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)
