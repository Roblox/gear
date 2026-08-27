local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")
local Fire = Handle:WaitForChild("Fire")

local Equipping = false
local Grip = nil

local AttackState = "Ruby"
local AttackDamage = 40
local AttackRecoil = 10
local AttackAble = true
local AttackDamaging = true
local AttackWindow = 1
local AttackWindup = 0.1
local AttackRestTime = 1
local AttackAnim = "Swing1"
local AttackVictims = {}

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

function onEquip()
	if Equipping then return end
	Equipping = true
	
	convertGrip()
	
	Equipping = false
end

function onUnequip()
	if Grip then
		Grip:Destroy()
	end
end

function notifyRecoil()
	local char = Tool.Parent
	if char and char:FindFirstChild("HumanoidRootPart") then
		local root = char.HumanoidRootPart
		
		local fire = Instance.new("Fire")
		fire.Heat = 15
		fire.Size = 14
		
		if AttackRecoil > 0 then
			fire.Color = Color3.new(0.6, 0, 0)
		else
			fire.Color = Color3.new(0, 0.6, 0)
		end
		
		fire.Parent = root
		delay(0.1, function()
			fire.Enabled = false
		end)
		game:GetService("Debris"):AddItem(fire)
	end
end

function onBladeTouched(part)
	if not AttackDamaging then return end
	if part:IsDescendantOf(Tool.Parent) then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		if not contains(AttackVictims, human) then
			table.insert(AttackVictims, human)
			tagHuman(human)
			human:TakeDamage(AttackDamage)
			
			local wielder = Tool.Parent
			if wielder and wielder:FindFirstChild("Humanoid") then
				wielder = wielder.Humanoid
				wielder:TakeDamage(AttackRecoil)
				notifyRecoil()
			end
		end
	end
end

function onSpecial1()
	if AttackState == "Ruby" then
		AttackDamage = 15
		AttackRecoil = -7.5
		AttackRestTime = 0.66
		Fire.Color = Color3.new(0, 0, 0.6)
		AttackState = "Sapphire"
	else
		AttackDamage = 40
		AttackRecoil = 15
		AttackRestTime = 1
		Fire.Color = Color3.new(0.6, 0, 0)
		AttackState = "Ruby"
	end
end

function onLeftDown()
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackRestTime, function()
		AttackAble = true
	end)
	
	delay(AttackWindup, function()
		AttackVictims = {}
		AttackDamaging = true
		delay(AttackWindow, function()
			AttackDamaging = false
		end)
	end)
	
	Remote:FireClient(getPlayer(), "PlayAnimation", AttackAnim)
	if AttackAnim == "Swing1" then
		AttackAnim = "Swing2"
	else
		AttackAnim = "Swing1"
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown()
	elseif func == "Special1" then
		onSpecial1()
	end
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Remote.OnServerEvent:connect(onRemote)
Handle.Touched:connect(onBladeTouched)

--set the AttackState to Ruby using the switching function
AttackState = "Sapphire"
onSpecial1()