-- Handle to the tool 
local Tool = script.Parent 
print("IN SCRIPT") 

-- Culling Service 
local debris = game:GetService("Debris") 

local r = game:service("RunService") 
Tool.Enabled = true 

local starActive = Tool:FindFirstChild("StarActive")

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		creator = Instance.new("ObjectValue")
		creator.Value = player
		creator.Name = "creator"
		creator.Parent = humanoid
		debris:addItem(creator, 1)
	end	
end

function blow(hit, missile)
	if missile then missile:Remove() end
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then 
		tagHumanoid(humanoid, vPlayer)
		if hit.Name == "Head" then humanoid:TakeDamage(80) else humanoid:TakeDamage(35) end 
	end	
end

function shoot(pPos, missile) 

	print("IN SHOOT") 
	-- 
	local vCharacter = Tool.Parent 
	if vCharacter == nil or vCharacter:findFirstChild("Humanoid") == nil then 
		 print("HUMANOID NOT FOUND") 
		 return 
	end 
	local vPlayer = game.Players:playerFromCharacter(vCharacter) 
	if vPlayer == nil then print("PLAYER NOT FOUND") end 
	-- Spawning position of the clone potion 
	local sPos = vCharacter.PrimaryPart.Position 
	-- Have it spawn at a offset from the actual object position 
	sPos = sPos + pPos.unit * 5.0  
	 
	local xyz_rand = math.random(0.0, 0.1)      
	missile.CFrame = CFrame.new(sPos, sPos + pPos) * CFrame.Angles(math.pi/2, 0, 0) 
	missile.Velocity = pPos * 90 
	missile.RotVelocity = Vector3.new(0.0, 10.0, 0.0)      
	missile.Name = "ThrownStar" 
	missile.CanCollide = false
	-- Give it a body force so that it stays afloat 
	local missileFloat = Instance.new("BodyForce") 
	-- Give it enough force to stay afloat 
	missileFloat.force = Vector3.new(0.0, (missile:GetMass()) * 196.1 , 0.0)           
	-- To know who the creator of the missile was 
	local creator_tag = Instance.new("ObjectValue") 
	creator_tag.Value = vPlayer 
	creator_tag.Name = "creator" 
	creator_tag.Parent = missile 
	-- Add the missile to the Workspace 
	missile.Parent = game.Workspace 
	missileFloat.Parent = missile    

	missile.Touched:connect(function(hit) blow(hit, missile) end)
	-- The potion will now be removed from the world in 5 seconds 
	debris:AddItem(missile, 5) 

	--Sound! 
	ThrowSound = Tool.Handle:FindFirstChild("ThrowSound") 
	if ThrowSound ~= nil then 
		ThrowSound.Volume = 1.0 
		ThrowSound:Play() 
	end 
end 

function onActivated() 
	-- Tentative Lock 
	if not Tool.Enabled then      
		 return 
	end 
	Tool.Enabled = false   
	if starActive.Value == 0 then
		local character = Tool.Parent 
		if character == nil then print("OMG! CHARACTER?") end 
		local humanoid = character.Humanoid 
		if humanoid == nil then 
			 print("OMG! WHERE IS HUMANOID?") 
			 Tool.Enabled = true 
			 return 
		end 
		-- Clone the potion 
		local starClone = Tool.Handle:Clone()    		

		starClone.Transparency = 0      
		local targetPos = humanoid.TargetPoint 
		local lookAt = (targetPos - character.Head.Position).unit 

		wait(0.2)      
		shoot(lookAt, starClone)      
		Tool.Handle.Transparency = 1.0 
		wait(0.5) 
		Tool.Handle.Transparency = 0.0 
	end
	wait(1.5) 
	Tool.Enabled = true 
end 

function onEquipped()      
end 

function onUnequipped()      
end 

Tool.Activated:connect(onActivated) 
Tool.Equipped:connect(onEquipped) 
Tool.Unequipped:connect(onUnequipped) 