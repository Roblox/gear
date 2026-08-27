local Tool = script.Parent 
local Blade = Tool.Handle

local vCharacter 
local myTorso 
local myHumanoid 
local vPlayer

Tool.Enabled = true 

local slashAnim

local throwRing
local terror

local damage = 22

local debris = game:GetService("Debris")

function terrorize(key, pos)
	key = key:lower()
	if vCharacter and myTorso and myHumanoid then 
		if key == "q" then 
			print("Throw ring")
			throwRing = Tool:FindFirstChild("ThrowRing")
			if throwRing and throwRing.Value == false then 
				print("Throwing")
				throwRing.Target.Value = pos
				throwRing.Value = true 
			end 
		elseif key == "r" then 
			print("Terrorize")
			terror = Tool:FindFirstChild("Terror")
			throwRing = Tool:FindFirstChild("ThrowRing")
			if terror and terror.Value == false then 				
				terror.Value = true 			
			end 
		end 
	end 
end 

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player 
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1.25)
	end 
end 

function blow(hit)
	if hit and hit.Parent and Blade.Transparency == 0 then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)		
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

	if throwRing and throwRing.Value == true then 
		return 
	end 

	Tool.Enabled = false 
	slashAnim = myHumanoid:LoadAnimation(Tool.SlashAnim)
	if slashAnim then slashAnim:Play() end 
	wait(1.25)
	Tool.Enabled = true 
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
end 

Tool.KeyDown.OnServerEvent:connect(function(client, ...)
	if client.Character == Tool.Parent then
		terrorize(...)
	end
end)

function onUnequipped()
	if slashAnim then slashAnim:Stop() end 
end

Tool.Mouse1Down.OnServerEvent:connect(function(client)
	if client.Character == Tool.Parent then
		onActivated()
	end
end)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Blade.Touched:connect(blow)

while Tool:FindFirstChild("Terror") == nil do 
	wait()
end

while Tool:FindFirstChild("ThrowRing") == nil do 
	wait()
end

throwRing = Tool.ThrowRing
terror = Tool.Terror




