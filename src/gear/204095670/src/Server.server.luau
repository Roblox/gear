local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")
local Mesh = Handle:WaitForChild("Mesh")

local Equipping = false
local Grip = nil

local StraightMeshData = "http://www.roblox.com/asset/?id=193827643"
local StraightGripPos = Vector3.new(0, 0, 1.5)
local BentMeshData = "http://www.roblox.com/asset/?id=193827593"
local BentGripPos = Vector3.new(0, 0.6, 0.5)
local Bent = true

local AttackAble = true
local AttackRestTime = 1.5
local AttackVictims = {}
local AttackDamage = 33
local AttackWindow = 0.66
local AttackDamaging = false
local AttackWindup = 0.1

function switchBend()
	if Bent then
		Mesh.MeshId = StraightMeshData
		--Tool.GripPos = StraightGripPos
	else
		Mesh.MeshId = BentMeshData
		--Tool.GripPos = BentGripPos
	end
	Bent = not Bent
end

function getPlayer()
	local char = Tool.Parent
	return game:GetService("Players"):GetPlayerFromCharacter(char)
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
	local tag = Instance.new("ObjectValue")
	tag.Value = getPlayer()
	tag.Name = "creator"
	tag.Parent = human
	game:GetService("Debris"):AddItem(tag)
end

function convertGrip()
	if Tool.Parent and Tool.Parent:FindFirstChild("Right Arm") then
		local weld = Tool.Parent["Right Arm"]:FindFirstChild("RightGrip")
		if weld then
			Grip = Instance.new("Motor6D")
			Grip.Name = "RightGrip"
			Grip.Part0 = weld.Part0
			Grip.Part1 = weld.Part1
			Grip.C0 = weld.C0
			Grip.C1 = weld.C1
			Grip.Parent = weld.Parent
			weld:Destroy()
		end
	end
end

function normal()
	if not AttackAble then return end
	
	--rest
	AttackAble = false
	delay(AttackRestTime, function()
		AttackAble = true
	end)
	
	--damage
	delay(AttackWindup, function()
		AttackVictims = {}
		AttackDamaging = true
		delay(AttackWindow, function()
			AttackDamaging = false
		end)
	end)
	
	--sound
	Handle.Swing.Pitch = math.random(90, 110)/100
	Handle.Swing:Play()
	
	Handle.Hit.Volume = 0
	Handle.Hit:Play()
	
	--animation
	switchBend()
	delay(0.66, function()
		switchBend()
	end)
	Remote:FireClient(getPlayer(), "PlayAnimation", "Swing1")
end

function shove(char)
	local wielder = Tool.Parent
	if wielder and wielder:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
		local shover = wielder.HumanoidRootPart
		local shovee = char.HumanoidRootPart
		
		local distance = 10
		local duration = 0.15
		local speed = distance/duration
		
		local velocity = (shovee.Position - shover.Position).unit * speed
		
		local shoveForce = Instance.new("BodyVelocity")
		shoveForce.maxForce = Vector3.new(1e9, 1e9, 1e9)
		shoveForce.velocity = velocity
		shoveForce.Parent = shovee
		game:GetService("Debris"):AddItem(shoveForce, duration)
		
		Handle.Hit.Volume = 0.5
	end
end

function onHandleTouched(part)
	if not AttackDamaging then return end
	if part:IsDescendantOf(Tool.Parent) then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		if not contains(AttackVictims, human) then
			table.insert(AttackVictims, human)
			tagHuman(human)
			human:TakeDamage(AttackDamage)
			shove(part.Parent)
		end
	end
end

function onEquip()
	if Equipping then return end
	Equipping = true
	
	convertGrip()
	
	--animation
	Remote:FireClient(getPlayer(), "PlayAnimation", "Idle")
	
	Equipping = false
end

function onUnequip()
	if Grip then
		Grip:Destroy()
	end
	
	--animation
	Remote:FireClient(getPlayer(), "StopAnimation", "Idle")
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "NormalStart" then
		normal()
	end
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Remote.OnServerEvent:connect(onRemote)
Handle.Touched:connect(onHandleTouched)