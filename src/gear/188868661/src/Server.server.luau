local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Remote = Tool:WaitForChild("Remote")
local ProjectileScript = Tool:WaitForChild("Projectile")

local LeftHandle
local Equipping = false

local AttackType = "ThrowRight"
local AttackAble = true
local AttackRest = 1
local AttackDamage = 20

local KnivesOut = {}
local KnivesDone = {}

function equipLeft()
	unequipLeft()
	
	local larm = Tool.Parent:FindFirstChild("Left Arm")
	if larm then
		local left = Handle:clone()
		left.Parent = Tool
		
		local w = Instance.new("Weld")
		w.Part0 = larm
		w.Part1 = left
		w.C0 = CFrame.new(0, -1, -1.25)
		w.Parent = w.Part0
		
		LeftHandle = left
	end
end

function unequipLeft()
	if LeftHandle then
		LeftHandle:Destroy()
		LeftHandle = nil
	end
end

function onEquipped()
	if Equipping then return end
	Equipping = true
	
	onUnequipped()
	
	equipLeft()
	
	Equipping = false
end

function onUnequipped()
	unequipLeft()
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

function onKnifeTouched(knife, part)
	if contains(KnivesDone, knife) then return end
	if contains(KnivesOut, part) then return end
	if part:IsDescendantOf(Tool.Parent) then return end
	
	knife.Projectile:Destroy()
	
	local w = Instance.new("Weld")
	w.Part0 = part
	w.Part1 = knife
	w.C0 = part.CFrame:toObjectSpace(knife.CFrame)
	w.Parent = w.Part0
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		tagHuman(human)
		human:TakeDamage(AttackDamage)
	end

	table.insert(KnivesDone, knife)
end

function throwKnife(handle, target)
	local vector = target - handle.Position
	
	local knife = Handle:Clone()
	knife.Transparency = 0
	knife.CFrame = CFrame.new(handle.Position, target)
	knife.Velocity = vector.unit * 128
	knife.Touched:connect(function(part)
		onKnifeTouched(knife, part)
	end)
	knife.Parent = workspace
	
	local scr = ProjectileScript:Clone()
	scr.Disabled = false
	scr.Parent = knife
	
	game:GetService("Debris"):AddItem(knife)
	
	table.insert(KnivesOut, knife)
		
	handle.Transparency = 1
	delay(0.25, function()
		handle.Transparency = 0
	end)
end

function attack(target)
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackRest, function()
		AttackAble = true
	end)
	
	if AttackType == "ThrowRight" then
		Remote:FireClient(getPlayer(), "PlayAnimation", "ThrowRight")
		AttackType = "ThrowLeft"
		
		delay(0.25, function()
			throwKnife(Handle, target)
		end)
	elseif AttackType == "ThrowLeft" then
		Remote:FireClient(getPlayer(), "PlayAnimation", "ThrowLeft")
		AttackType = "ThrowDouble"
		
		delay(0.25, function()
			throwKnife(LeftHandle, target)
		end)
	elseif AttackType == "ThrowDouble" then
		Remote:FireClient(getPlayer(), "PlayAnimation", "ThrowDouble")
		AttackType = "ThrowRight"
		
		delay(0.25, function()
			throwKnife(Handle, target)
			throwKnife(LeftHandle, target)
		end)
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		attack(...)
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnServerEvent:connect(onRemote)

Tool:WaitForChild("ThumbnailHandle"):Destroy()