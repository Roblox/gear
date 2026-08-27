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


Tool.Enabled = true

local Damage = 24

local RBX_Debris = game:GetService("Debris")

local onCooldown = false



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

local soundPlaying = false

function blow(hit)	
	-- Do olympic weapons do damage?
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and humanoid ~= vHumanoid and vHumanoid then 
			humanoid.PlatformStand = true
			if not soundPlaying then
				soundPlaying = true
				if Tool:FindFirstChild('WhistleSound') then
					Tool:FindFirstChild('WhistleSound'):Play()
				end
				wait(1)
				if Tool:FindFirstChild('CheerSound') then
					Tool:FindFirstChild('CheerSound'):Play()
				end
				soundPlaying = false
			end
			wait(0.5)
			humanoid.PlatformStand = false
		end
	end
end



function rotateTorsoToMouse(mouse)
	if mouse and mouse.Hit then
		if exists(vCharacter) and exists(vCharacter.Torso) then
			local torsoLoc = vCharacter.Torso.CFrame.p
			local mouseLoc = Vector3.new(mouse.Hit.p.x, torsoLoc, mouse.Hit.p.x)
			vCharacter.Torso.CFrame = CFrame.new(torsoLoc, mouseLoc)
		end
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

function onEquipped()
	Tool.Enabled = true
	vCharacter = Tool.Parent 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	vTorso = vCharacter:FindFirstChild("Torso")
	if vHumanoid then
		vHumanoid.WalkSpeed = 0
	end
	swordOut()
end 

function idle()
	while wait(1.6) and Tool.Enabled do
		if exists(vCharacter) and exists(vTorso) then
			local bodyForce = Instance.new('BodyForce', vTorso)
			RBX_Debris:AddItem(bodyForce, 0.2)
			bodyForce.force = Vector3.new(0, 3300, 0)
		end
	end
end

function onUnequipped()
	if vHumanoid then
		vHumanoid.WalkSpeed = 16 --maybe store original walk speed?
	end
	Tool.Enabled = false
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Handle.Touched:connect(blow)

if Tool.ServerLunge then
	Tool.ServerLunge.Changed:connect(Lunge)
end


idle()



