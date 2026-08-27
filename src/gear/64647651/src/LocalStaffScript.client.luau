local Tool = script.Parent
local Staff = Tool.Handle

local vCharacter
local myTorso
local myHumanoid 

Tool.Enabled = true 

local staffAnim

local summonZombies
local activeZombies

while Staff:FindFirstChild("FirePart") == nil or Staff:FindFirstChild("FireWeld") == nil do 
	wait()
end

local firePart = Staff.FirePart
local fireWeld = Staff.FireWeld 

function staffUp()
	Tool.GripPos = Vector3.new(0, 0, -4.5) 
end

function staffDown()
	Tool.GripPos = Vector3.new(0, 0, -0.6)
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	
	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false

	staffUp()

	local fire = firePart:FindFirstChild("Fire")
	if fire then fire.Enabled = true end

	wait(2.0)	

	activeZombies = Tool:FindFirstChild("ActiveZombies")
	if activeZombies and activeZombies.Value == false then 
		summonZombies = Tool:FindFirstChild("SummonZombies")
		if summonZombies then summonZombies.Value = true end
	end

	wait(0.4)
	staffDown()
	if fire then fire.Enabled = false end

	wait(10.0)
	Tool.Enabled = true
end

function onEquipped()
	if fireWeld then 
		local storeWeld = fireWeld:Clone()
		storeWeld.Parent = Staff
	end
end

function onUnequipped()
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
