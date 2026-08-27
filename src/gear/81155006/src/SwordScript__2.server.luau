--[[
	// Now, I arrange my gear with a handle and 2 hidden blades under it. 
]]

local function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		print(parent, " waiting for ", instance)
		wait()
	end 
	return parent[instance]
end 

local Tool = script.Parent 
local Saber = Tool.Handle
local GLib = require(206209239)

Tool.Enabled = true 

local vCharacter 
local vTorso
local vHumanoid 
local vRightArm 
local vLeftArm

local Slash_Anim
local Split_Anim
local DoubleSlash_Anim 
local Switch_Anim    
local SwordWalk_Anim

local RightGrip_Weld
local LeftGrip_Weld 

local UnsheathSound = waitForChild(Saber, "SaberSound")

local LeftSaber = Instance.new("Part")

local TopBlade = waitForChild(Saber, "TopBlade")
local BottomBlade = waitForChild(Saber, "BottomBlade")

local TopWeld = waitForChild(Saber, "TopWeld")
local BottomWeld = waitForChild(Saber, "BottomWeld")

local damage = 19  

local Mouse 

local function blow(blade, hit)
	if blade and blade.Transparency ~= 1.0 and hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") and hit.Parent.Parent then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and humanoid ~= vHumanoid and vHumanoid and GLib.IsTeammate(GLib.GetPlayerFromPart(humanoid), GLib.GetPlayerFromPart(vHumanoid))~=true then 
			humanoid:TakeDamage(damage)
		end 
	end 
end 

local function SlashIt(hum, torso)
	local lungeSlash = hum:LoadAnimation(Tool["LungeSlash"])	
	
	lungeSlash:Play()

	local target = hum.TargetPoint
	local direction = (target - torso.Position) * Vector3.new(1, 0, 1)
	local newBV = nil
	if direction.magnitude > .01 then 
		-- make 'em dash forwards too
		direction = direction.unit
		newBV = Instance.new("BodyVelocity")
		newBV.P = 100000
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P)
		newBV.velocity = direction * 50
		newBV.Parent = torso

		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0))
	end
	
	wait(.5)
	if dashSound then dashSound:Play() end 
	if newBV ~= nil then newBV:remove() end
	wait(.5)
end

local function Shred(key)
	key = key:lower() 
	if key == "q" then 
		-- Release the other part of the saber 
		if BottomBlade and not LeftSaber.Parent then
			if UnsheathSound then UnsheathSound:Play() end
			if BottomBlade.Transparency == 1.0 then 
				for i = 1, 10 do 
					BottomBlade.Transparency = 1 - (i/10)
					wait(0.15)
				end 
			else
				for i = 1, 10 do 
					BottomBlade.Transparency = 0 + (i/10)
					wait(0.15)
				end  
			end 
		end 
	elseif key == "x" then 
		-- Split the sabers
		if not LeftSaber.Parent and BottomBlade.Transparency == 0.0 then 			
			-- Now split them sabers 
			Split_Anim = vHumanoid:LoadAnimation(Tool.SplitAnim)
			if Split_Anim then Split_Anim:Play() end 
			wait(0.5)
			BottomBlade.Transparency = 1.0 		
			LeftSaber = Saber:Clone()
			LeftSaber.Parent = vCharacter 
			
			LeftGrip_Weld = RightGrip_Weld:Clone()
			LeftGrip_Weld.Part1 = LeftSaber
			LeftGrip_Weld.Part0 = vLeftArm
			LeftGrip_Weld.Parent = vLeftArm

			local topBlade = waitForChild(LeftSaber, "TopBlade")
			local topWeld = TopWeld:Clone()
			topWeld.Part1 = topBlade
			topWeld.Part0 = LeftSaber 
			topWeld.Parent = LeftSaber 

			wait(0.5)

			LeftSaber.Touched:connect(function(hit) blow(LeftSaber, hit) end)
			topBlade.Touched:connect(function(hit) blow(topBlade, hit) end)

			SwordWalk_Anim = vHumanoid:LoadAnimation(Tool.SwordWalk)
			--if SwordWalk_Anim then SwordWalk_Anim:Play() end 

			Spawn(function()
				if not LeftSaber.Parent and SwordWalk_Anim then 
					SwordWalk_Anim:Stop() 
				end 
			end)
		end 
	elseif key == "e" then 
		-- Combine the sabers if they are separated 
		if LeftSaber and LeftSaber.Parent then 
			LeftSaber.Parent = nil
			TopBlade.Transparency = 0.0
			BottomBlade.Transparency = 0.0
		end
	end 
end 

local function onActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if vTorso == nil and vHumanoid == nil then 
		return 
	end 

	Tool.Enabled = false 

	if TopBlade and TopBlade.Transparency ~= 0.0 then 
		if UnsheathSound then UnsheathSound:Play() end
		for i = 1, 10 do
			TopBlade.Transparency = 1 - (i/10)
			wait(0.15)
		end 
	elseif BottomBlade.Transparency == 0.0 then 
		local theta = 0    
		Tool.GripUp = Vector3.new(1, 0, 0) 
		Tool.GripRight = Vector3.new(0, -1, 0) 
		Tool.GripForward = Vector3.new(0, 0, 1) 
		for i = 1, 120 do 
			theta = i%6 * math.pi/3 
			Tool.GripRight = Vector3.new(0, -math.sin(theta), math.cos(theta)) 
			Tool.GripUp = Vector3.new(0, math.cos(theta), math.sin(theta))								
			wait() 
		end   
		Tool.Grip =  CFrame.new(0, -0.75, 0, 0, 0, -0.99999994, -0.261768907, 0.965130627, 0, 0.965130568, 0.261768937, 0)	
		wait(5.0)   
	elseif LeftSaber.Parent then 
		SlashIt(vHumanoid, vTorso)
		wait(2.0)
	else 
		Tool.Grip = CFrame.new(0, 0, 0, 0, 1, -0, 0, -0, -1, -1, 0, -0)
		Slash_Anim = vHumanoid:LoadAnimation(Tool.SlashAnim)
		if Slash_Anim then Slash_Anim:Play() end 
		wait(1.0)
		Tool.Grip =  CFrame.new(0, -0.75, 0, 0, 0, -0.99999994, -0.261768907, 0.965130627, 0, 0.965130568, 0.261768937, 0)	
	end 		
	Tool.Enabled = true 
end

local function onEquipped()
	vCharacter = Tool.Parent 
	vTorso = vCharacter:FindFirstChild("Torso")
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vRightArm = vCharacter:FindFirstChild("Right Arm")
	vLeftArm = vCharacter:FindFirstChild("Left Arm")

	RightGrip_Weld = waitForChild(vRightArm, "RightGrip")

	if TopWeld then 
		TopWeld.Parent = Tool
	end 
	if BottomWeld then 
		BottomWeld.Parent = Tool 
	end 
	TopBlade.Transparency = 1.0
	BottomBlade.Transparency = 1.0	
end 

Tool.Input.OnServerEvent:connect(function(client, action, down, ...)
	if client.Character == Tool.Parent then
		if action == 'Key' and down then
			Shred(...)
		end
	end
end)

local function onUnequipped()
	if Slash_Anim then Slash_Anim:Stop() end 
	if Split_Anim then Split_Anim:Stop() end 
	if DoubleSlash_Anim then DoubleSlash_Anim:Stop() end 
	if Switch_Anim then Switch_Anim:Stop() end 
	if UnsheathSound then UnsheathSound:Stop() end
	if SwordWalk_Anim then SwordWalk_Anim:Stop() end	
	LeftSaber.Parent = nil 
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

TopBlade.Touched:connect(function(hit) blow(TopBlade, hit) end)
BottomBlade.Touched:connect(function(hit) blow(TopBlade, hit) end)