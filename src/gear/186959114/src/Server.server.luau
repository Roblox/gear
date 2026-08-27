local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")

local AttackAble = true
local AttackDamaging = false
local AttackWindow = 0.5
local AttackRestTime = 1
local AttackDamage = 34
local AttackType = "Slash"
local AttackConnection

function onEquipped()
	--ensure unequip
	onUnequipped()
	
	AttackConnection = Handle.Touched:connect(onBladeTouched)
end

function onUnequipped()
	if AttackConnection then
		AttackConnection:disconnect()
	end
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function onBladeTouched(part)
	if not AttackDamaging then return end
	
	if not part:IsDescendantOf(Tool.Parent) and part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		tagHuman(human)
		human:TakeDamage(AttackDamage)
		AttackDamaging = false
		playSound("Hit")
		
		if human.Health <= 0 then
			if human.Parent:FindFirstChild("Head") then
				snowmanTransform(human.Parent.Head)
			end
		end
	end
end

function playSound(name, pitch, volume)
	local sound = Handle:FindFirstChild(name)
	if sound then
		sound.Pitch = pitch or math.random(90, 110)/100
		sound.Volume = volume or 0.5
		sound:Play()
	end
end

function weld(a, b, c0)
	b.CFrame = a.CFrame:toWorldSpace(c0)
	
	local w = Instance.new("Weld")
	w.Part0 = a
	w.Part1 = b
	w.C0 = c0
	w.Parent = w.Part0
end

function snowmanTransform(victimHead)
	--clear the character
	local char = victimHead.Parent
	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("BasePart") and obj ~= victimHead then
			obj:Destroy()
		end
	end
	
	--morph head
	victimHead.BrickColor = BrickColor.new("White")
	victimHead.Mesh.MeshType = "Sphere"
	victimHead.Mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
	victimHead.Size = Vector3.new(1, 1, 1)
	victimHead.Material = "Ice"
	
	--sound
	playSound("Ice", nil, 1)
	
	--snowman
	local part = Instance.new("Part")
	part.FormFactor = "Symmetric"
	part.Shape = "Ball"
	part.TopSurface = "Smooth"
	part.BottomSurface = "Smooth"
	part.BrickColor = BrickColor.new("White")
	part.Material = "Ice"
	
	local head = part:Clone()
	head.CFrame = victimHead.CFrame
	head.Size = Vector3.new(1, 1, 1)
	head.Parent = char
	weld(victimHead, head, CFrame.new())
	
	local hat = part:Clone()
	hat.Size = Vector3.new(1, 1, 1)
	hat.Parent = char
	weld(head, hat, CFrame.new(0, 1, 0))
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = "FileMesh"
	mesh.MeshId = "http://www.roblox.com/asset/?id=57475891"
	mesh.TextureId = "http://www.roblox.com/asset/?id=60191351"
	mesh.Parent = hat
	
	local torso = part:Clone()
	torso.Size = Vector3.new(2, 2, 2)
	torso.Parent = char
	weld(head, torso, CFrame.new(0, -1.5, 0))
	
	local base = part:Clone()
	base.Size = Vector3.new(3, 3, 3)
	base.Parent = char
	weld(torso, base, CFrame.new(0, -2, 0))
	local gyro = Instance.new("BodyGyro")
	gyro.cframe = CFrame.new()
	gyro.maxTorque = Vector3.new(math.huge, 0, math.huge)
	gyro.Parent = base
	
	local arm = part:Clone()
	arm.Shape = "Block"
	arm.FormFactor = "Custom"
	arm.BrickColor = BrickColor.new("Brown")
	arm.Material = "Wood"
	
	local larm = arm:Clone()
	larm.Size = Vector3.new(2, 0.2, 0.2)
	larm.Parent = char
	weld(torso, larm, CFrame.Angles(0, 0, math.pi/8) * CFrame.new(1.5, 0, 0))
	
	local rarm = arm:Clone()
	rarm.Size = Vector3.new(2, 0.2, 0.2)
	rarm.Parent = char
	weld(torso, rarm, CFrame.Angles(0, 0, -math.pi/8) * CFrame.new(-1.5, 0, 0))
	
	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("BasePart") then
			obj.Anchored = true
		end
	end
end

function attack()
	if not AttackAble then return end
	
	--rest
	AttackAble = false
	delay(AttackRestTime, function()
		AttackAble = true
	end)
	
	--animate
	Remote:FireClient(getPlayer(), "PlayAnimation", AttackType)
	if AttackType == "Slash" then
		AttackType = "Chop"
	elseif AttackType == "Chop" then
		AttackType = "Spin"
	else
		AttackType = "Slash"
	end
	playSound("Slash")
	
	--open damage window
	delay(0.1, function()
		AttackDamaging = true
		delay(AttackWindow, function()
			AttackDamaging = false
		end)
	end)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Attack" then
		attack()
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnServerEvent:connect(onRemote)