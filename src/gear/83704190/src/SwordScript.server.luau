local function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		print(instance) 
		wait() 
	end 
	return parent:FindFirstChild(instance)
end 

local Tool = script.Parent 
local Sword = Tool.Handle 

local vCharacter
local vPlayer
local vTorso
local vHumanoid 

Tool.Enabled = true 

local Wind_BoolValue = waitForChild(Tool, "Wind")
local Wind_Weld = waitForChild(Tool, "WindWeld")  
local Fire_Part = waitForChild(Sword, "FirePart")
local Wind_Fire = waitForChild(Fire_Part, "WindFire") 

local Damage = 24

local RBX_Debris = game:GetService("Debris")

local TimeOfDay 

function TagHumanoid(humanoid, player) --Fix implemented by Luckymaxer
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	RBX_Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function blow(hit)	
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and humanoid ~= vHumanoid and vHumanoid then
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(Damage)
			if Wind_Fire and Wind_Fire.Enabled == true then
				coroutine.resume(coroutine.create(function()
					if humanoid and humanoid.Parent and humanoid.Parent:FindFirstChild("Torso") and not humanoid.Parent.Torso:FindFirstChild("DarkFire") then
						local cFire = Wind_Fire:Clone()
						cFire.Parent = humanoid.Parent:FindFirstChild("Torso") 
						RBX_Debris:AddItem(cFire, 4) 
						local duration = 4
						while duration > 0 do
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, vPlayer)
							humanoid:TakeDamage(5)
							duration = duration - 1 
							wait(1.0) 
						end 
					end 
				end)) 
			end 
		end 
	end 
end

function onEquipped() 	
	if Wind_Weld then 
		Wind_Weld.Parent = Tool 
	end 
	if Wind_Fire then 
		Wind_Fire.Enabled = true
	end 
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vTorso = vCharacter:FindFirstChild("Torso")
end 

function onUnequipped()	
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Sword.Touched:connect(blow)





