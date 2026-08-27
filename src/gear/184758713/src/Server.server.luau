local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local Motor

local AttackNumber = 1
local AttackDamage = 30
local AttackWindow = 0.6
local AttackRest = 1.25
local AttackAble = true
local AttackDamaging = false
local AttackHit = {}

function getPlayerChar()
	local char = Tool.Parent
	local player = game:GetService("Players"):GetPlayerFromCharacter(char)
	return player, char
end

function convertWeldToMotor(weld)
	local m = Instance.new("Motor6D")
	m.Name = weld.Name
	m.Part0 = weld.Part0
	m.Part1 = weld.Part1
	m.C0 = weld.C0
	m.C1 = weld.C1
	
	local parent = weld.Parent
	weld:Destroy()
	m.Parent = parent
	
	Motor = m
end

function changeGrip()
	local player, char = getPlayerChar()
	while not char:FindFirstChild("Right Arm") do wait() end
	while not char["Right Arm"]:FindFirstChild("RightGrip") do wait() end
	convertWeldToMotor(char["Right Arm"].RightGrip)
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
	local player, char = getPlayerChar()
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = player
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function openAttackWindow()
	AttackHit = {}
	
	AttackDamaging = true
	delay(AttackWindow, function()
		AttackDamaging = false
	end)
end

function onTouched(part)
	if not AttackDamaging then return end
	
	local player, char = getPlayerChar()
	
	if part.Parent and part.Parent ~= char and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		if not contains(AttackHit, human) then
			table.insert(AttackHit, human)
			tagHuman(human)
			human:TakeDamage(AttackDamage)
			
			local pitch = math.random(60, 80)/100
			playSound("HitSound", pitch, 1)
			playSound("HitSound2", pitch + 0.3, 1)
		end
	end
end

function onTouchedSpecial(part)
	local player, char = getPlayerChar()
	
	if part.Parent and part.Parent ~= char and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		if not contains(AttackHit, human) then
			table.insert(AttackHit, human)
			tagHuman(human)
			human:TakeDamage(AttackDamage)
		end
	end
end

function special()
	local player, char = getPlayerChar()
	local root = char:FindFirstChild("HumanoidRootPart")
	if root then
		openAttackWindow()
		
		local c = root.CFrame
		local dz = -8
		for t = 0, 1, 1/15 do
			delay(t, function()
				local pos = c:pointToWorldSpace(Vector3.new(0, -2.5, dz))
				
				local e = Instance.new("Explosion")
				e.BlastPressure = 0
				e.Position = pos
				e.Hit:connect(onTouchedSpecial)
				e.Parent = workspace
				
				dz = dz - 6
			end)
		end
		
		playSound("Explosion", 0.9, 1)
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

function attack()
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackRest, function()
		AttackAble = true
	end)
	
	local player, char = getPlayerChar()
	
	if AttackNumber < 5 then
		if AttackNumber == 1 or AttackNumber == 3 then
			Remote:FireClient(player, "PlayAnimation", "SwingRightToLeft")
		elseif AttackNumber == 2 or AttackNumber == 4 then
			Remote:FireClient(player, "PlayAnimation", "SwingLeftToRight")
		end
		
		openAttackWindow()
		playSound("SwingSound")
	else
		Remote:FireClient(player, "PlayAnimation", "Slam")
		
		delay(1.1, function()
			for _, obj in pairs(Handle:GetChildren()) do
				if obj:IsA("Fire") then
					obj.Enabled = false
					game:GetService("Debris"):AddItem(obj)
				end
			end
		end)
		
		delay(1.1, special)
		
		playSound("FireSound", 1.5)
		
		AttackNumber = 0
	end
	
	AttackNumber = AttackNumber + 1
	
	if AttackNumber == 5 then
		local fire = Instance.new("Fire")
		fire.Parent = Handle
	end
end

function onRemote(callingPlayer, func, ...)
	local player, char = getPlayerChar()
	if callingPlayer == player then
		if func == "Attack" then
			attack()
		end
	end
end

function onEquipped()
	--ensure unequip
	onUnequipped()
	
	--convert grip to a motor
	changeGrip()
end

function onUnequipped()
	if Motor then
		Motor:Destroy()
	end
end

--connect events
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnServerEvent:connect(onRemote)
Handle.Touched:connect(onTouched)