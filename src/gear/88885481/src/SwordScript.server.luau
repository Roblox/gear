-- Military Sword 


local Tool = script.Parent
local Sword = Tool.Handle

local shield
local shieldMesh

local vCharacter

local damage = 9

Tool.Enabled = true

local debris = game:GetService("Debris")

local chanceToBreak = 10

local bbGui = Instance.new("BillboardGui") 
bbGui.Name = "MARKEDFORDEATH" 
bbGui.Size = UDim2.new(1, 0, 1, 0) 
bbGui.StudsOffset = Vector3.new(0, 2, 0) 

local image = Instance.new("ImageLabel") 
image.Name = "Child" 
image.Image = "http://www.roblox.com/asset/?id=53594614" 
image.Size = UDim2.new(1, 0, 1, 0) 
image.BackgroundTransparency = 1.0 
image.Parent = bbGui 

local function applyDebuff(char)	 
	local xSpot = Instance.new('IntValue') 
	xSpot.Value =  1
	if char then 
		if char:FindFirstChild('XMarksTheSpot') == nil then 
			xSpot = Instance.new('IntValue')
			xSpot.Name = 'XMarksTheSpot'
			xSpot.Value = 1 
			xSpot.Parent = char
		else 
			local cValue = char.XMarksTheSpot.Value 
			char.XMarksTheSpot:Destroy() 
			local xSpot = Instance.new('IntValue')
			xSpot.Name = 'XMarksTheSpot'
			xSpot.Value = cValue + 1 
			xSpot.Parent = char
		end 
	
		if char:FindFirstChild('Head') then 
			local head = char.Head
			if head:FindFirstChild('MARKEDFORDEATH') == nil then 
				local bClone = bbGui:Clone() 
				bClone.Parent = head 

				debris:AddItem(bClone, 5) 
			else 
				head.MARKEDFORDEATH:Destroy() 
			
				local bClone = bbGui:Clone() 
				bClone.Parent = head 

				bClone.Adornee = head 

				debris:AddItem(bClone, 5) 
			end  
		end 
	end 

	debris:AddItem(xSpot, 5) 

	return xSpot 
end 

function blow(hit)   -- For the Sword
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then
		rightArm = vCharacter:FindFirstChild("Right Arm")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Sword or rightGrip.Part1 == Sword) then 				
				tagHumanoid(humanoid, vPlayer)
				local multiplier = 1
				if humanoid.Parent:FindFirstChild('XMarksTheSpot') == nil then 
					local xSpot = applyDebuff(humanoid.Parent) 				
					multiplier = xSpot.Value 										
				else 
					local xSpot = applyDebuff(humanoid.Parent) 				
					multiplier = xSpot.Value 										
				end 

				humanoid:TakeDamage(damage * multiplier)						
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
		debris:AddItem(creatorTag, 1)
	end
end


function onActivated()	
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then 
		return
	end
end

function onEquipped()
	print("On Equip")
	vCharacter = Tool.Parent
	torso = vCharacter:FindFirstChild("Torso")	
end

function onUnequipped()
	torso = vCharacter:FindFirstChild("Torso")
	if torso then 
		shield = vCharacter:FindFirstChild("Shield") 
		shieldWeld = torso:FindFirstChild("ShieldHolder")
	end
	if shield then shield:Remove() end
	if shieldWeld then shieldWeld:Remove() end
	
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)
Sword.Touched:connect(blow)