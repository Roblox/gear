local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")

local AttackAble = true
local AttackDamaging = false
local AttackWindow = 0.5
local AttackRestTime = 1
local AttackDamage = 34
local AttackType = "Slash"
local AttackTypes = {"Slash", "Chop", "Spin"}
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
			if human.Parent:FindFirstChild("HumanoidRootPart") then
				giftTransform(human.Parent.HumanoidRootPart)
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

function r(lower, upper)
	return lower + math.random() * (upper - lower)
end

function giftTransform(victimCamAnchor)
	--ensure mesh
	if not victimCamAnchor:FindFirstChild("Mesh") then
		Instance.new("SpecialMesh", victimCamAnchor).Name = "Mesh"
	end
	
	--clear the character
	local char = victimCamAnchor.Parent
	for _, obj in pairs(char:GetChildren()) do
		if obj:IsA("BasePart") and obj ~= victimCamAnchor then
			obj:Destroy()
		end
	end
	
	--morph head
	victimCamAnchor.BrickColor = BrickColor.new("White")
	victimCamAnchor.Size = Vector3.new(2, 2, 2)
	victimCamAnchor.Transparency = 0
	victimCamAnchor.Mesh.MeshType = "FileMesh"
	victimCamAnchor.Mesh.Scale = Vector3.new(1.5, 1.5, 1.5)
	victimCamAnchor.Mesh.MeshId = "http://www.roblox.com/asset/?id=1237207"
	victimCamAnchor.Mesh.TextureId = "http://www.roblox.com/asset/?id=6020478"
	victimCamAnchor.Mesh.VertexColor = Vector3.new(r(0.5, 1), r(0.5, 1), r(0.5, 1))
	
	--sound
	playSound("Paper", nil, 1)
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
	AttackType = AttackTypes[math.random(1, 3)]
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