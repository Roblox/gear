local Tool = script.Parent

local vCharacter
local myHumanoid
local myTorso

local leftSwordWeld

local UnsheathAnim
local holdAnim
local slamAnim
local thrustAnim
local attackAnim

local runService = game:service("RunService") 
local last_attack

local animating = false	

local justEquipped =  Tool:FindFirstChild('JustEquipped')

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\swordslash.wav"
SlashSound.Parent = myTorso
SlashSound.Volume = .7

local RBX_Debris = game:GetService("Debris")

local Wave_Part = Instance.new("Part")
Wave_Part.FormFactor = 3 
Wave_Part.Size = Vector3.new(10, 0.2, 4) 

local Top_Decal = Instance.new("Decal")
Top_Decal.Texture = "http://www.roblox.com/asset/?id=83658504"
Top_Decal.Parent = Wave_Part 
Top_Decal.Face = "Top"

local Bottom_Decal = Top_Decal:Clone()
Bottom_Decal.Face = "Bottom"
Bottom_Decal.Parent = Wave_Part

local onSpecialCooldown = false


local function waveHit(hit, wp)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and humanoid ~= myHumanoid then
			print('Hit something') 
			humanoid:TakeDamage(45)
			wp:Destroy()
		end
	end
end

local function releaseTheShockWave(position)	
	local wp = Wave_Part:Clone()
	wp.CFrame = CFrame.new(position, position + myTorso.CFrame.lookVector) * CFrame.Angles(0, 0, math.pi/2)
	wp.Transparency = 1.0 
	wp.CanCollide = false
	--wp.Anchored = true 

	local float_BodyForce = Instance.new("BodyForce")
	float_BodyForce.Name = "Float"
	float_BodyForce.force = Vector3.new(0, 196.1 * wp:GetMass(), 0)
	float_BodyForce.Parent = wp 

	wp.Parent = game.Workspace 

	wp.Velocity = wp.CFrame.lookVector * 40.0 
	wp.Touched:connect(function(hit) waveHit(hit, wp) end) 


	RBX_Debris:AddItem(wp, 2.5)	
end 

function swordUp()
	leftSwordWeld = vCharacter:FindFirstChild("Left Arm"):FindFirstChild("LeftGrip")
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
	if leftSwordWeld then
		--leftSwordWeld.C1 = leftSwordWeld.C1 * CFrame.Angles(180, 0, 0)
		-- CFrame for pointing the sword down
		leftSwordWeld.C1 = CFrame.new(0, 0, -2.1, 0, 0, 1, 1, 0, 0, 0, 1, 0)
	end
end

function bothSwordsDown()
	leftSwordWeld = vCharacter:FindFirstChild("Left Arm"):FindFirstChild("LeftGrip")
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,-1)
	if leftSwordWeld then
		--leftSwordWeld.C1 = leftSwordWeld.C1 * CFrame.Angles(180, 0, 0)
		-- CFrame for pointing the sword down
		leftSwordWeld.C1 = CFrame.new(0, 0, -2.1, 0, 0, 1, -1, 0, 0, 0, -1, 0)
	end
end

function slamDown(key)
	if not onSpecialCooldown and not Tool:FindFirstChild('JustEquipped').Value and key:lower() == "x" then
		onSpecialCooldown = true
		print("Preparing to Slam!")
		if thrustAnim then
			thrustAnim:Stop() 
		end
		if SlashSound then
			SlashSound:Play()
		end
		bothSwordsDown()
		wait()
		slamAnim = myHumanoid:LoadAnimation(Tool.SlamAnim)
		if slamAnim then slamAnim:Play() end
	
		wait(0.5)
		local rightarmPos = vCharacter:FindFirstChild('Right Arm').Position
		releaseTheShockWave(rightarmPos)
		local leftarmPos = vCharacter:FindFirstChild('Left Arm').Position
		releaseTheShockWave(leftarmPos)	
		wait(2.0)
		swordUp()
		-- weapon cooldown
		wait(15)
		onSpecialCooldown = false
	end
end


function blow(hit)
end

function lunge()
	if not thrustAnim then thrustAnim = myHumanoid:LoadAnimation(Tool.ThrustAnim) thrustAnim:AdjustSpeed(0.65) end
	if thrustAnim then thrustAnim:Play() end
	repeat
		wait()
	until not Tool:FindFirstChild('Lunging').Value
	if thrustAnim then thrustAnim:Stop() end
end

function attack()
	if not attackAnim then attackAnim = myHumanoid:LoadAnimation(Tool.AttackAnim) end
	if attackAnim then attackAnim:Play() end
end


local last_attack = 0
function onActivated()
	if Tool.Enabled == false then
		return 
	end
	Tool.Enabled = false
	if thrustAnim then thrustAnim:Stop() end
	if Tool:FindFirstChild('JustEquipped').Value then
		UnsheathAnim = myHumanoid:LoadAnimation(Tool.UnsheathAnim)
		if UnsheathAnim then UnsheathAnim:Play() end
		holdAnim = myHumanoid:LoadAnimation(Tool.HoldAnim)
		if holdAnim then holdAnim:Play() end
		wait(1.5)
		Tool:FindFirstChild('JustEquipped').Value = false
	else

		t = runService.Stepped:wait()
		if (t - last_attack < 0.2) then
			lunge()
		else
			attack()
		end

		last_attack = t
		--wait(1.0)
	end
	Tool.Enabled = true	
end

function onEquipped(mouse)
	Tool.Enabled = true	
	Tool:FindFirstChild('JustEquipped').Value = true
	if mouse then 
		vCharacter = Tool.Parent
		myHumanoid = vCharacter:FindFirstChild("Humanoid")
		myTorso = vCharacter:FindFirstChild("Torso")
		mouse.KeyDown:connect(slamDown)
		--[[wait(1.0)
		holdAnim = myHumanoid:LoadAnimation(Tool.HoldAnim)
		if holdAnim then holdAnim:Play() end ]]
	end
end

function onUnequipped()
	if holdAnim then print("Stopping hold Anim") holdAnim:Stop() holdAnim:Remove() end 
	if UnsheathAnim then UnsheathAnim:Stop() end
	if thrustAnim then thrustAnim:Stop() end
	if attackAnim then attackAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Tool.Handle.Touched:connect(blow)