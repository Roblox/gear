--[[
	Fixed by ArceusInator
	- Works with FE
	- First person/mouselock no longer breaks everything
	- Player no longer trips over themselves
--]]

local Tool = script.Parent 
local Blade = Tool.Handle 

local RunService = Game:GetService('RunService')
local DebrisService = Game:GetService('Debris')
local Players = game:GetService("Players")

local SpinAnim 
local SlashAnim 

local LastAttack = 0 
local DashTime = 0 
local LastKeyDown = 0
local LeftBlade = nil 

local Damage = 25 

local CritChance = 0.22 
local CritMultiplier = 2.25
local ChanceToBreak = 0.20

local BodyGyro

local NumSpinCycles = 168 -- every 42 is 1.05 seconds

local TorsoCFrames_List = {}

local Anims_List = {Tool:WaitForChild('SlashAnim'), Tool:WaitForChild('RightSwingFast'), Tool:WaitForChild('LeftSwingFast')}

local function TagHumanoid(humanoid)
	if humanoid and Player then 
		local cTag = Instance.new('ObjectValue')
		cTag.Name = 'creator'
		cTag.Value = Player
		cTag.Parent = humanoid

		DebrisService:AddItem(cTag, 1.0)
	end 
end 

local function CreateBBGui(number, head, critted)
	wait(0.15)
	if head and number ~= 0 then
		local bbGui = Instance.new('BillboardGui')
		bbGui.Name = 'BoneBillboard'
		bbGui.Adornee = head 
		bbGui.Parent = head 
		bbGui.Size = UDim2.new(1, 0, 1, 0)		

		local tLabel = Instance.new('TextLabel')
		tLabel.Name = 'Damage'
		tLabel.Text = math.floor(number)
		tLabel.BackgroundTransparency = 1.0 
		tLabel.TextScaled = true 
		tLabel.Font = Enum.Font.ArialBold
		tLabel.FontSize = Enum.FontSize.Size12 
		tLabel.TextStrokeColor3 = Color3.new(1, 1, 1)
		tLabel.TextStrokeTransparency = 0.5
		tLabel.Size = UDim2.new(1, 0, 1, 0)
		tLabel.Parent = bbGui 		

		if critted then 
			tLabel.TextColor3 = Color3.new(1, 0, 0)
			tLabel.Size = UDim2.new(1.4, 0, 1.4, 0)
		else 
			tLabel.TextColor3 = Color3.new(0.83, 0.45, 0.13)
		end 
		Spawn(function()
			local maxHeight = 5.0 
			while bbGui and bbGui.StudsOffset.Y < maxHeight do 
				bbGui.StudsOffset = bbGui.StudsOffset + Vector3.new(0, 0.2, 0)
				wait(0.05)
			end 
			bbGui:Destroy()
		end)
	end 
end

local function Blow(part, hitPart, damage)
	if part and part.Transparency ==  0.0 and hitPart and hitPart.Parent then 
		local humanoid = hitPart.Parent:FindFirstChild('Humanoid') 
		if hitPart.Parent:IsA('Hat') and hitPart.Parent.Parent then 
			humanoid = hitPart.Parent.Parent:FindFirstChild('Humanoid')
		end 
		if humanoid and humanoid ~= Humanoid then 
			local critted = false 
			TagHumanoid(humanoid)
			if math.random(0, 1) <= CritChance then 
				damage = damage * CritMultiplier		
				critted = true 	
			end 
			CreateBBGui(damage, humanoid.Parent:FindFirstChild('Head'), critted) 
			humanoid:TakeDamage(damage)
			if hitPart and not hitPart.Parent:FindFirstChild("ForceField") and math.random(0, 1) < ChanceToBreak then --Fix implemented by Luckymaxer
				hitPart:BreakJoints() 
				if hitPart.Name == 'Head' or hitPart.Name == 'Torso' then 
					CreateBBGui(9001, humanoid.Parent:FindFirstChild('Head'), critted)
					Humanoid:TakeDamage(-damage)
				end  
			end 
		end 
	end 
end

local function CreateCloneBlade()
	if LeftBlade == nil then 
		LeftBlade = Blade:Clone()
		LeftBlade.Transparency = 1.0
		LeftBlade.CanCollide = false

		local rightArm = Character:WaitForChild('Right Arm')
		local rightGrip = rightArm:WaitForChild('RightGrip')
		local leftArm = Character:WaitForChild('Left Arm')
		
		local leftGrip = rightGrip:Clone()
		leftGrip.Name = 'LeftGrip'
		leftGrip.Part0 = LeftBlade
		leftGrip.Part1 = leftArm 
		leftGrip.Parent = leftArm 
		leftGrip.C1 = CFrame.new(0, -1.1, -1.1, -1, 0, -8.74227766e-008, 0, 1, 0, 8.74227766e-008, 0, -1)

		LeftBlade.Parent = Character
	end 
end

local function SpinLikeTheWind()
	SpinAnim = Humanoid:LoadAnimation(Tool.SpinAnim)
	if SpinAnim then SpinAnim:Play() end

	if LeftBlade.Transparency == 1.0 then 
		LeftBlade.Transparency = 0.0
	else 
		Blade.Transparency = 0.0
	end 
	
	local oldAutoRotate = Humanoid.AutoRotate
	Humanoid.AutoRotate = false

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
		local c = i%6 + 1 
		if BodyGyro then BodyGyro.cframe = TorsoCFrames_List[c] end 
		wait(0.025) 
	end      	
 	
	if BodyGyro then BodyGyro:Destroy() end 
	if LeftBlade.Transparency == 0.0 then 
		LeftBlade.Transparency = 1.0
	else 
		Blade.Transparency = 1.0
	end 
	
	Humanoid.AutoRotate = oldAutoRotate
	wait(2.0) 	
end 

local function UnleashTheInnerBeast(key)
	key = key:lower()
	if key == 'w' then 
		local wTime = RunService.Stepped:wait()
		if (wTime - LastKeyDown < 0.2) then DashTime = wTime end 
		LastKeyDown = wTime 
	end 
end

local function OnActivated()
	if not Torso or not Humanoid then 
		return 
	end 

	if not Tool.Enabled then 
		return 
	end 

	Tool.Enabled = false 

	local wTime = RunService.Stepped:wait()
	if wTime - DashTime < 0.2 then
		SpinLikeTheWind()
	else 
		SlashAnim = Humanoid:LoadAnimation(Anims_List[math.random(1, #Anims_List)])		
		if SlashAnim then SlashAnim:Play() end 
	end 

	wait(0.25)
	Tool.Enabled = true 
end 

local equipped = false
local function OnEquipped()
	if equipped then return end
	equipped = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Humanoid.Torso
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end	
	CreateCloneBlade()
end 

Tool.KeyDown.OnServerEvent:connect(function(client, key)
	if client.Character == Tool.Parent then
		UnleashTheInnerBeast(key)
	end
end)

local function OnUnequipped()
	if not equipped then return end
	equipped = false
	if SpinAnim then SpinAnim:Stop() end 
	if SlashAnim then SlashAnim:Stop() end 
	Blade.Transparency = 0.0

	if BodyGyro then BodyGyro:Destroy() end 
end 

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)

Blade.Touched:connect(function(hitPart) Blow(Blade, hitPart, Damage) end)