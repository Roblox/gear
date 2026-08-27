local Tool = script.Parent
local Kama = Tool.Handle

local vCharacter
local myTorso
local myHumanoid

local leftKama
local leftKamaWeld

local slashSound

local leftKamaConnection

Tool.Enabled = true

local kamaDamage = 20

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
					humanoid:TakeDamage(kamaDamage)
				end
			end 
		end
	end
end 

function onEquipped()
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myLeftArm = vCharacter:FindFirstChild("Left Arm")
	if myTorso and myLeftArm and vCharacter:FindFirstChild("LeftKama") == nil and leftKamaWeld == nil then 
		leftKama = Kama:Clone()
		leftKama.Name = "LeftKama"
		leftKama.Parent = vCharacter		

		leftKamaWeld = Instance.new("Weld")		
		leftKamaWeld.Part0 = myLeftArm
		leftKamaWeld.Part1 = leftKama
		leftKamaWeld.C1 = (CFrame.new(Vector3.new(0, 2, 0)) * CFrame.Angles(0, -math.pi/2, 0) * CFrame.Angles(math.pi/2, 0, 0)) + Vector3.new(-1.7, -3, 0)
		leftKamaWeld.Parent = myLeftArm 
		leftKamaWeld.Name = "LeftGrip"

		leftKamaConnection = leftKama.Touched:connect(function(hit) slash(hit, myLeftArm, leftKama) end)
	end	
end

function onUnequipped()
	if leftKama then leftKama:Remove() leftKama = nil end
	if leftKamaWeld then leftKamaWeld:Remove() leftKamaWeld = nil end
	if slashSound then slashSound:Stop() end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Kama.Touched:connect(function(hit) slash(hit, nil, Kama) end)
