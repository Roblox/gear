local function waitForChild(parent, instance)
	while parent:FindFirstChild(instance) == nil do 
		print(instance) 
		wait() 
	end 
	return parent:FindFirstChild(instance)
end 

local Tool = script.Parent 
local Handle = Tool.Handle 

local vCharacter
local vPlayer
local vTorso
local vHumanoid 

local vMouse

Tool.Enabled = true

local Damage = 24

local RBX_Debris = game:GetService("Debris")

local onCooldown = false

local aDown = false
local dDown = false

local VaultSound = Tool:FindFirstChild('VaultSound')

local CheerSound = Tool:FindFirstChild('CheerSound')

local RunSound = Tool:FindFirstChild('RunSound')

function calculateMassRecursive(rootPart)
	local sum = 0
	if rootPart:IsA('Part') then sum = sum + rootPart:GetMass() end
	for _, v in pairs(rootPart:GetChildren()) do
		sum = sum + calculateMassRecursive(v)
	end
	return sum
end

function exists(object)
	if not object then
		--print("Object doesn't exist or is false.")
		return false
	end
	return true
end

function blow(hit)	
	-- Do olympic weapons do damage?
end

--[[
function lunge(backwards)
	if onCooldown then return end
	onCooldown = true
	if Tool.DoLunge then
		Tool.DoLunge:Invoke()
	end
	if exists(vTorso) then
	wait(0.2)
		local rightVector = vTorso.CFrame.lookVector:Cross(Vector3.new(0, 1, 0))
		local jumpVel = Instance.new('BodyVelocity', vTorso)
		RBX_Debris:AddItem(jumpVel, 0.5)
		-- make them jump to the side and up a little
		jumpVel.velocity = rightVector * 45
		if backwards then
			jumpVel.velocity = jumpVel.velocity * -1
		end
		jumpVel.velocity = jumpVel.velocity --+ Vector3.new(0, 15, 0)
		jumpVel.maxForce = Vector3.new(5000000, 4500, 5000000)
		vHumanoid.Jump = true
	end
	wait(0.7)
	onCooldown = false
end
]]

function onActivate()
	--lunge()
	if vHumanoid then
		vHumanoid.Jump = true
	end
end

-- these all could be refactors to be the same function

function playVault(value)
	if VaultSound then
		VaultSound:Play()
	end
end

function playRun(value)
	if RunSound then
		RunSound:Play()
	end
end

function stopRun(value)
	if RunSound then
		RunSound:Stop()
	end
end

function playCheer(value)
	if CheerSound then
		CheerSound:Play()
	end
end

function swordUp()
	Tool.GripForward = Vector3.new(1, 0, 0)
	Tool.GripRight = Vector3.new(0, 0, 1)
	Tool.GripUp = Vector3.new(0, 1, 0)
end

function swordOut()
	Tool.GripForward = Vector3.new(0, 1, 0)
	Tool.GripRight = Vector3.new(1, 0, 0)
	Tool.GripUp = Vector3.new(0, 0, 1)
end

local equipped = false

function onEquipped(mouse)
	if equipped then return end
	equipped = true
	Tool.Enabled = true
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vTorso = vCharacter:FindFirstChild("Torso")
	if mouse then
		vMouse = mouse
	end

end 


function onUnequipped()
	equipped = false
	Tool.Enabled = false
	stopRun()
end

Tool.Activated:connect(onActivate)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Handle.Touched:connect(blow)

-- bind the playVault 
if Tool.playVault then
	Tool.playVault.Changed:connect(playVault)
end

-- bind the playCheer 
if Tool.playCheer then
	Tool.playCheer.Changed:connect(playCheer)
end

-- bind the playRun 
if Tool.playRun then
	Tool.playRun.Changed:connect(playRun)
end

-- bind the playRun 
if Tool.stopRun then
	Tool.stopRun.Changed:connect(stopRun)
end
