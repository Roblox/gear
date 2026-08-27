local function WaitForChild(parent, childName)
	while parent:FindFirstChild(childName) == nil do 
		wait()
	end 
	return parent[childName]
end 

local Player = Game.Players.LocalPlayer 
local Character
local Torso 
local Humanoid 

local Tool = script.Parent 
local Glove = Tool.Handle 

local DebrisService = Game:GetService('Debris')
local RunService = Game:GetService('RunService')

local LastAttack = 0

local LeftGlove 

local LeftGrip 

local NewBV

local Lunging = false 

local Damage = 14

local Unequipped = false 

local function TagHumanoid(humanoid)
	if humanoid and Player then
		local cTag = Instance.new('ObjectValue')
		cTag.Name = 'creator'
		cTag.Value = Player 
		cTag.Parent = humanoid

		DebrisService:AddItem(cTag, 1)
	end 
end 

local function Blow(hitPart, damage)
	if hitPart and hitPart.Parent then 
		local humanoid = hitPart.Parent:FindFirstChild('Humanoid')
		if hitPart.Parent:IsA('Hat') and hitPart.Parent.Parent then 
			humanoid = hitPart.Parent.Parent:FindFirstChild('Humanoid')
		end 
		if humanoid and humanoid ~= Humanoid then 
			TagHumanoid(humanoid)
			humanoid:TakeDamage(damage)			
		end 
	end
end

local function Lunge()	

	Lunging = true 

	LungeAnim = Humanoid:LoadAnimation(Tool.LungeAnim)
	if LungeAnim then LungeAnim:Play() end 

	local target = Humanoid.TargetPoint 
	local direction = (target - Torso.Position) * Vector3.new(1, 0, 1) 
	NewBV = nil 	

	if direction.magnitude > .01 then 
		direction = direction.unit 
		NewBV = Instance.new("BodyVelocity") 
		NewBV.P = 100000 
		NewBV.maxForce = Vector3.new(NewBV.P, 0, NewBV.P) 
		NewBV.velocity = direction * 50 
		NewBV.Parent = Torso
		Torso.CFrame = CFrame.new(Torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, Torso.Position.Y, 0)) 
	end 
	wait(0.75) 
	if NewBV ~= nil then 
		NewBV:Destroy() 
	end 
	Lunging = false 	
	wait(0.5)      
end

local function OnActivated()
	if Tool.Enabled == false then 
		return 
	end 

	if not Humanoid or not Torso then 
		return 
	end 

	local timestep = RunService.Stepped:wait() 
	if (timestep - LastAttack < 0.2) then 		
		if Lunging == true then return end 
		Lunge()      	
	else 
		SlashAnim = Humanoid:LoadAnimation(Tool.SlashAnim)
		if SlashAnim then SlashAnim:Play() end 
	end 

	LastAttack = timestep

	Tool.Enabled = true      
end

local function StrengthenThySoul(healthBoost, walkSpeedBoost)
	if Humanoid.WalkSpeed >= 23 then return end 
	if Humanoid then 
		Humanoid.WalkSpeed = Humanoid.WalkSpeed + walkSpeedBoost

		local ratio = Humanoid.Health/Humanoid.MaxHealth

		if Humanoid.MaxHealth + healthBoost < 100 then 
			Humanoid.MaxHealth = 100 
		else 
			Humanoid.MaxHealth = Humanoid.MaxHealth + healthBoost
		end 

		if Humanoid.Health < ratio * Humanoid.MaxHealth then 
			while Humanoid.Health < ratio * Humanoid.MaxHealth do
				Humanoid.Health = ratio * Humanoid.MaxHealth 
				wait() 
			end
		else 
			while Humanoid.Health > ratio * Humanoid.MaxHealth do 
				Humanoid.Health = ratio * Humanoid.MaxHealth 
				wait() 
			end 
		end 
	end 
end 

local function OnEquipped()
	Unequipped = false 
	Character = Tool.Parent 
	Torso = WaitForChild(Character, 'Torso')
	Humanoid = WaitForChild(Character, 'Humanoid')

	Humanoid.WalkSpeed = 17.0

	local leftArm = WaitForChild(Character, 'Left Arm')
	if leftArm:FindFirstChild('LeftGrip') == nil then 
		LeftGlove = Glove:Clone()

		LeftGrip = Instance.new('Weld')
		LeftGrip.Name = 'LeftGrip'
		LeftGrip.Part0 = leftArm 
		LeftGrip.Part1 = LeftGlove
		LeftGrip.C1 = CFrame.new(0, 0, 1.6, 1, 1.74845567e-007, 1.74845539e-007, 1.74845553e-007, -4.37113883e-008, -1, -1.74845553e-007, 1, -4.37114203e-008)

		LeftGrip.Parent = leftArm 

		LeftGlove.Parent = Character 

		LeftGlove.Touched:connect(function(hitPart) Blow(hitPart, Damage) end)
	end 

	Spawn(function()
		while not Unequipped do 
			local timeOfDay = Game.Lighting.TimeOfDay 
			local hours = tonumber(string.sub(timeOfDay, 1, 2))
			if hours >= 19 or hours < 6 then 
				StrengthenThySoul(110, 6.0)
			end 
			wait(2.0)
		end 
	end)
end 

local function OnUnequipped()
	if LeftGlove then LeftGlove:Destroy() end 
	if NewBV then NewBV:Destroy() end 
	if SlashAnim then SlashAnim:Stop() end 
	if LungeAnim then LungeAnim:Stop() end
	Unequipped = true  
	StrengthenThySoul(-110, -6.0)
	Humanoid.WalkSpeed = 16.0
end 

Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped) 

Glove.Touched:connect(function(hitPart) Blow(hitPart, Damage) end)
