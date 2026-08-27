local Tool = script.Parent
local Gun = Tool.Handle

local Player 
local Character 
local Humanoid
local Torso 

Tool.Enabled = true 

local RunService = Game:GetService('RunService')

local LastAttack = 0 
local DashTime = 0 
local LastKeyDown = 0

local Missile = Instance.new('Part')
Missile.Shape = 'Ball'
Missile.FormFactor = 3 
Missile.BrickColor = BrickColor.new('Bright blue')
Missile.Size = Vector3.new(0.4, 0.4, 0.4)

local FloatForce = Instance.new('BodyForce')
FloatForce.force = Vector3.new(0, Missile:GetMass() * 196.2, 0)
FloatForce.Parent = Missile 

local MissileVelocity = 75.0

local Debris = Game:GetService('Debris') 

local BodyGyro
local NumSpinCycles = 168 -- every 42 is 1.05 seconds
local TorsoCFrames_List = {}

local Mouse 

local function UnleashTheInnerBeast(key)
	key = key:lower()
	if key == 'w' then 
		local wTime = RunService.Stepped:wait()
		if (wTime - LastKeyDown < 0.2) then DashTime = wTime end 
		LastKeyDown = wTime 
	end 
end

local function Shoot(target)
	local target = target or Mouse.Hit.p 

	local missile = Missile:Clone() 

	local mScript = Tool:WaitForChild('MissileScript'):Clone()
	mScript.Parent = missile 
	mScript:WaitForChild('Character').Value = Character 

	missile.Parent = Game.Workspace 
	mScript.Disabled = false 

	missile.CFrame = Torso.CFrame + Torso.CFrame.lookVector * 2.0 
	missile.Velocity = (target - missile.Position).unit * MissileVelocity 

	Debris:AddItem(missile, 6.0) 
end 

local function SpinLikeTheWind()
	SpinAnim = Humanoid:LoadAnimation(Tool.SpinAnim)
	if SpinAnim then SpinAnim:Play() end

	BodyGyro = Instance.new("BodyGyro") 
	BodyGyro.P = 100000 
	BodyGyro.maxTorque = Vector3.new(BodyGyro.P, BodyGyro.P, BodyGyro.P) 
	BodyGyro.Name = "BG" 

	TorsoCFrames_List[1] = Torso.CFrame * CFrame.Angles(0, 1*math.pi/3, 0) 
	TorsoCFrames_List[2] = Torso.CFrame * CFrame.Angles(0, 2*math.pi/3, 0) 
	TorsoCFrames_List[3] = Torso.CFrame * CFrame.Angles(0, math.pi, 0) 
	TorsoCFrames_List[4] = Torso.CFrame * CFrame.Angles(0, 4*math.pi/3, 0) 
	TorsoCFrames_List[5] = Torso.CFrame * CFrame.Angles(0, 5*math.pi/3, 0) 
	TorsoCFrames_List[6] = Torso.CFrame 

	BodyGyro.Parent = Torso 

	Spawn(function()
		wait(2.1)
		if SpinAnim then SpinAnim:Play() end
	end)

	for i = 1, NumSpinCycles do 
		if math.random() < 0.2 then 
			Shoot(Torso.CFrame.p + Torso.CFrame.lookVector * 60.0)
		end 
		local c = i%6 + 1 
		if BodyGyro then BodyGyro.cframe = TorsoCFrames_List[c] end 
		wait(0.025) 
	end      	
 	
	if BodyGyro then BodyGyro:Destroy() end 
end 

local function OnActivated()
	if not Tool.Enabled  then 
		return 
	end 

	if not Torso or not Humanoid then 
		return 
	end 

	Tool.Enabled = false 

	local wTime = RunService.Stepped:wait() 
	if wTime - DashTime < 0.2 then 
		SpinLikeTheWind()
	else 
		Shoot() 
	end

	wait(0.25) 

	Tool.Enabled = true 
end

local function OnEquipped()
	Character = Tool.Parent 
	Player = Game.Players:GetPlayerFromCharacter(Character)

	Torso = Character:WaitForChild('Torso')
	Humanoid = Character:WaitForChild('Humanoid')

	Mouse = Player:GetMouse() 
	Mouse.KeyDown:connect(UnleashTheInnerBeast)
end 

local function OnUnequipped()
end 

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated) 