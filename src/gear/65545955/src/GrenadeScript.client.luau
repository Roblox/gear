local Tool = script.Parent 
local Grenade = Tool.Handle 

while Grenade:FindFirstChild("Sparkles") == nil do wait() end

local vCharacter 
local myTorso
local myHumanoid
local vPlayer

local sparkles = Grenade.Sparkles

Tool.Enabled = true

local debris = game:GetService("Debris")

function shoot(direction, grenadeClone)
	if myTorso and myHumanoid then 
		local spawnPos = Grenade.Position + direction * 4.0 
		grenadeClone.CFrame = CFrame.new(spawnPos, spawnPos + direction) 
	
		grenadeClone.Velocity = (direction + Vector3.new(0, 2, 0)).unit * 50.0
		grenadeClone.RotVelocity = Vector3.new(0, 10, 0)

		local floatForce = Instance.new("BodyForce")
		floatForce.force = Vector3.new(0, grenadeClone:GetMass() * 98.1, 0)
		floatForce.Parent = grenadeClone 
		
		local cloneScript = Tool.BlowScript:Clone()
		cloneScript.Parent = grenadeClone
		cloneScript.Disabled = false
		
		grenadeClone.Parent = game.Workspace				
	end	
end

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	if myTorso == nil or myHumanoid == nil then 
		return 
	end

	Tool.Enabled = false 

	local grenadeClone = Grenade:Clone()
	grenadeClone.CanCollide = true 
	
	Grenade.Transparency = 1.0
	if sparkles then sparkles.Enabled = false end	
	
	local target = myHumanoid.TargetPoint 
	local direction = (target - Grenade.Position).unit 
	
	shoot(direction, grenadeClone)

	wait(4.0)
	if sparkles then sparkles.Enabled = true end	
	Grenade.Transparency = 0.0
	Tool.Enabled = true 
end 

function onEquipped()	
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if sparkles and sparkles.Enabled == false then wait(1.0) sparkles.Enabled = true end	
end

function onUnequipped()
	if throwAnim then throwAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)