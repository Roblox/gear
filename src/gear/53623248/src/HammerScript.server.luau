-- Damage = 12, Swing Damage = 18 
-- 17% chance to destroy a part entirely. 
-- If the part is a torso, or head, i-i-i-insta-kill 

local Tool = script.Parent 
local Hammer = Tool.Handle 

Tool.Enabled = true 

local damage = 18


local HammerSound 

local vCharacter 

function blow(hit) 
	if hit.Parent then 
		 humanoid = hit.Parent:FindFirstChild("Humanoid") 
	end 
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
	if humanoid ~= nil and myHumanoid ~= nil and humanoid ~= myHumanoid then 		 
		rightArm = vCharacter:FindFirstChild("Right Arm") 
		if rightArm ~= nil then 
			rightGrip = rightArm:FindFirstChild("RightGrip") 
			if rightGrip ~= nil and (rightGrip.Part0 == Hammer or rightGrip.Part1 == Hammer) then 
				tagHumanoid(humanoid, vPlayer)                
				print(damage) 
				humanoid:TakeDamage(damage)           
				wait(1.5)                     
				untagHumanoid(humanoid)                
			end 
		end 
	end 
end 

function tagHumanoid(humanoid, player) 
	if humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue") 
		creatorTag.Name = "creator" 
		creatorTag.Value = player 
		creatorTag.Parent = humanoid 
	end 
end 

function untagHumanoid(humanoid) 
	if humanoid ~= nil then 
		tag = humanoid:FindFirstChild("creator") 
		if tag ~= nil then tag:Remove() end 
	end 
end 

function onActivated() 
	if Tool.Enabled == false then 
		return 
	end 

	Tool.Enabled = false 
		  
	vCharacter = Tool.Parent 
	myHumanoid = vCharacter:FindFirstChild("Humanoid")           
	if myHumanoid == nil then 
		return 
	end 
	HammerSound = Tool:FindFirstChild("HammerSound") 	 
	if HammerSound then HammerSound:Play() end 
	wait(2.0) 	
	Tool.Enabled = true 
end 

function onEquipped() 
end 

function onUnequipped() 
	if HammerSound then HammerSound:Stop() end 
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped) 

Hammer.Touched:connect(blow) 