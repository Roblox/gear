local Tool = script.Parent 
local Hammer = Tool.Handle

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
local throwAnim

function throwHamma(key)
	key = key:lower()
	if key == "w" then 
		t = runService.Stepped:wait() 
		if (t - lastKeyDown < 0.2) then dashTime = t end 
		lastKeyDown = t 
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
			if hit:FindFirstChild("Fire") == nil then 
				local fire = Instance.new("Fire")
				fire.Parent = hit 
				fire.Color = Color3.new(0, 204/255, 1)
				fire.SecondaryColor = Color3.new(0, 0, 1)
	
				debris:AddItem(fire, 3)
			end 

			if hit.Parent:FindFirstChild("FreezingHammerSlowScript") == nil then 
				local freezeScript = Tool.FreezingHammerSlowScript:Clone()
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
	
	local throwHammer = Tool:FindFirstChild("ThrowHammer")
	--if throwHammer and throwHammer.Value == true then return end 

	Tool.Enabled = false 

	t = runService.Stepped:wait() 
	if t - dashTime < 0.2 then 	
		throwAnim = myHumanoid:LoadAnimation(Tool.ThrowAnim)
		if throwAnim then throwAnim:Play() end		
		if throwHammer and throwHammer.Value == false then throwHammer.Value = true end 
	else 
		slashAnim = myHumanoid:LoadAnimation(Tool.Slash)
		if slashAnim then slashAnim:Play() end 
		Tool.Enabled = true 
	end 
end

function onEquipped(mouse)
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if mouse then 
		mouse.KeyDown:connect(throwHamma)   
	end 
end  

function onUnequipped()
	if slashAnim then slashAnim:Stop() end 
	if throwAnim then throwAnim:Stop() end 
end 

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Hammer.Touched:connect(blow)
