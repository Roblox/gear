local Tool = script.Parent
local Axe = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local leftAxe
local leftAxeWeld

local slashSound

local leftAxeConnection

Tool.Enabled = true

local axeDamage = 20

local damage = 22

local debris = game:GetService("Debris")

function tagHumanoid(humanoid, player)
	if humanoid ~= nil then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Value = player
		creatorTag.Parent = humanoid
		creatorTag.Name = "creator"
		debris:AddItem(creatorTag, 1)
	end
end

function slash(hit, arm, kamaHandle)
	local armWeld
	if hit and hit.Parent and vCharacter then 		
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)		
		if humanoid ~= nil and myHumanoid ~=nil and myHumanoid ~= humanoid then 			
			if arm == nil then 				
				arm = vCharacter:FindFirstChild("Right Arm")
			end
			if arm then 				
				armWeld = arm:FindFirstChild("LeftGrip") or arm:FindFirstChild("RightGrip")
				if armWeld and (armWeld.Part0 == kamaHandle or armWeld.Part1 == kamaHandle)  then					
					tagHumanoid(humanoid, vPlayer)
					humanoid:TakeDamage(axeDamage)
				end
			end 
		end
	end
end 

function blow(hit) 
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid") 
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer) 
			humanoid:TakeDamage(damage) 			
		end 
	end 
end 

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myLeftArm = vCharacter:FindFirstChild("Left Arm")
	if myTorso and myLeftArm and vCharacter:FindFirstChild("LeftAxe") == nil and leftAxeWeld == nil then 
		leftAxe = Axe:Clone()
		leftAxe.Name = "LeftAxe"
		leftAxe.Parent = vCharacter		

		leftAxeWeld = Instance.new("Weld")		
		leftAxeWeld.Part0 = myLeftArm
		leftAxeWeld.Part1 = leftAxe
		leftAxeWeld.C1 = CFrame.new(-1, 0, -1.9, -1.31134158e-007, -1, 2.18556949e-007, -1, 1.31134158e-007, 4.3711367e-008, -4.37113989e-008, -2.18556949e-007, -1)
		leftAxeWeld.Parent = myLeftArm 
		leftAxeWeld.Name = "LeftGrip"

		leftAxeConnection = leftAxe.Touched:connect(function(hit) slash(hit, myLeftArm, leftAxe) end)
	end	
end

function onUnequipped()
	if leftAxe then leftAxe:Remove() leftAxe = nil end
	if leftAxeWeld then leftAxeWeld:Remove() leftAxeWeld = nil end
	if slashSound then slashSound:Stop() end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Axe.Touched:connect(function(hit) slash(hit, nil, Axe) end)

local throwAxes = Tool:FindFirstChild("ThrowAxes")
while throwAxes == nil do 
	wait() 
	throwAxes = Tool:FindFirstChild("ThrowAxes")
end 

function throw(axeClone, direction, axe) 
	local spawnPos = axe.Position + direction * 4.0 
	axeClone.CFrame = CFrame.new(spawnPos, spawnPos + direction) * CFrame.Angles(0, 0, math.pi/2)	
	axeClone.CanCollide = false 

	axeClone.Velocity = direction * 65.0 
	--axeClone.RotVelocity = Vector3.new(100, 0, 0) 

	local floatForce = Instance.new("BodyForce") 
	floatForce.force = Vector3.new(0, axeClone:GetMass() * 196.1, 0) 
	floatForce.Parent = axeClone 

	axeClone.Parent = game.Workspace 

	print(axeClone)

	axeClone.Touched:connect(function(hit) blow(hit) end) 	
	debris:AddItem(axeClone, 5)
end 

throwAxes.Changed:connect(function()
	if throwAxes and throwAxes.Value == true and myHumanoid then 
		Tool.Enabled = false
		local target = myHumanoid.TargetPoint 
		local direction = (target - myTorso.Position).unit

		local axeClone = Axe:Clone()
		throw(axeClone, direction, Axe)	
		wait(0.25)
		local axeClone2 = Axe:Clone()
		throw(axeClone2, direction, leftAxe)
		Axe.Transparency = 1.0
		leftAxe.Transparency =  1.0
		wait(5.0)
		Tool.Enabled = true 
		Axe.Transparency = 0.0
		leftAxe.Transparency =  0.0
		wait(2.0)
		throwAxes.Value = false
	end 
end) 
