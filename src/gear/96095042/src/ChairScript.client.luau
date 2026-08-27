print('Chair Script')
local function WaitForChild(parent, childName)
	print(parent, childName)
	while parent:FindFirstChild(childName) == nil do 
		wait()
	end 
	return parent[childName]
end 

local Tool = script.Parent 
local Chair = Tool.Handle 

local Player = Game.Players.LocalPlayer 

while Player.Character == nil or Player.Character.Parent~=game.Workspace do wait() end 
local Character = Player.Character
local Torso = WaitForChild(Character, 'Torso')
local Humanoid = WaitForChild(Character, 'Humanoid')

Spawn(function()
	while true do 
		print(Player.Parent, Player.Character)
		if Player.Character then print(Player.Character.Parent) print(Character.Parent) end
		wait(4.5)
	end 
end)

local FlightSpin
local FlightPower 
local FlightHold 

local DebrisService = Game:GetService('Debris')

local RightLeg = WaitForChild(Character, 'Right Leg')
local LeftLeg = WaitForChild(Character, 'Left Leg')

local LeftLegClone
local RightLegClone

local ChairActivate = WaitForChild(Tool, 'ChairActivate')

local Factor = 177
local Riding = false 

local AnimateScript = WaitForChild(Character, 'Animate')

local Gui = Instance.new('ScreenGui')
local RbxGui = LoadLibrary('RbxGui')

local TorsoConnection

local Mouse

local RightArm
local RightGrip

local Gravity = 196.2
local TimeTaken = 0
local Velocity = 200.0

local SitAnim 

local TrollWords_List = {
						"Haters gonna hate",
						"That's how you roll",
						"YESSSSSSS",
						"CHAIR POWAH",
						"SITTING IN THE FRONT SEAT",
						"TROLOLOLOLOLO",
						"COME AT ME BRUH",
						"CHAIR to the face",
						"Faster than a speeding stool"
					}

local function CreateCloneLegs()
	LeftLegClone = LeftLeg:Clone()
	RightLegClone = RightLeg:Clone()

	local lMotor = WaitForChild(Torso, 'Left Hip'):Clone()
	local rMotor = WaitForChild(Torso, 'Right Hip'):Clone()

	lMotor.Part1 = LeftLegClone
	rMotor.Part1 = RightLegClone

	lMotor.Name = 'Fake Left Hip'
	rMotor.Name = 'Fake Right Hip'

	lMotor.Parent = LeftLegClone
	rMotor.Parent = RightLegClone

	lMotor.C1 = lMotor.C1 * CFrame.Angles(0, 0, math.pi/2)
	rMotor.C1 = rMotor.C1 * CFrame.Angles(0, 0, -math.pi/2)

	LeftLegClone.Parent = Character
	RightLegClone.Parent = Character

	AnimateScript.Disabled = true
end

local function DestroyCloneLegs()
	if LeftLegClone then LeftLegClone:Destroy() end
	if RightLegClone then RightLegClone:Destroy() end
	AnimateScript.Disabled = false 	
end

local TrollStack = {} 

local function CreateBBGui(text, head)	
	if #TrollStack > 3 then return end 
	if head and number ~= 0 then
		local bbGui = Instance.new('BillboardGui')
		bbGui.Name = 'BoneBillboard'
		bbGui.Adornee = head 
		bbGui.Parent = head 
		bbGui.Size = UDim2.new(1, 0, 1, 0)		

		local tLabel = Instance.new('TextLabel')
		tLabel.Name = 'Damage'
		tLabel.Text = text
		tLabel.BackgroundTransparency = 1.0 
		--tLabel.TextScaled = true 
		tLabel.Font = Enum.Font.ArialBold
		tLabel.FontSize = Enum.FontSize.Size14 
		tLabel.TextStrokeColor3 = Color3.new(1, 1, 1)
		tLabel.TextStrokeTransparency = 0.5
		tLabel.Size = UDim2.new(2, 0, 1, 0)
		tLabel.Parent = bbGui 		
		tLabel.TextColor3 = Color3.new(0.63, 0.3, 0.37)	
		Spawn(function()
			local maxHeight = 5.0 
			local index = #TrollStack + 1
			TrollStack[#TrollStack + 1] = bbGui
			while bbGui and bbGui.StudsOffset.Y < maxHeight do 
				bbGui.StudsOffset = bbGui.StudsOffset + Vector3.new(0, 0.2, 0)
				wait(0.05)
			end 
			bbGui:Destroy()
			bbGui = nil 
			TrollStack[index] = nil 
		end)
	end 
end

local function LetTheTrollingBegin(hitPart)
	if hitPart and hitPart.Parent and hitPart.Parent:FindFirstChild('Humanoid') then 
		hitPart.Parent.Humanoid.Sit = true 
		CreateBBGui(TrollWords_List[math.random(1, #TrollWords_List)], Character:FindFirstChild('Head'))
	end 
end

function ComputeLaunchAngle(dx, dy, grav)	
	-- This function is nasty or what? :P 
	-- There are ways to solve launch angle of a projectile given a point in 3D space 
	-- This one solves for tan(theta) 
		
	-- Simplify the distance formula of a projectile 
	local g = math.abs(grav)
	local inRoot = (Velocity * Velocity * Velocity * Velocity) - (g * ((g * dx * dx) + (2 * dy * Velocity * Velocity)))
	if inRoot <= 0 then
		return 0.25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = ((Velocity * Velocity) + root) / (g*dx)

	local inATan2 = ((Velocity * Velocity) - root) / (g*dx)
	local a1 = math.atan(inATan1)
	local a2 = math.atan(inATan2)
	if a1 < a2 then return a1 end
	return a2
end

local function ThrowChair()
	Tool.Enabled = false 
	local cClone = Chair:Clone()	
	Chair.Transparency = 1.0	

	local spawnPos = Torso.Position + Torso.CFrame.lookVector * 3.0
	cClone.CFrame = CFrame.new(spawnPos)
	local target = Mouse.Hit.p

	local toTarget = target - spawnPos	
	local dY = toTarget.Y
	toTarget = Vector3.new(toTarget.X, 0, toTarget.Z)
	local dXZ = toTarget.magnitude
	toTarget = toTarget.unit 
	local theta = ComputeLaunchAngle(dXZ, dY, Gravity)	

	local angleY = math.sin(theta)
	local angleXZ = math.cos(theta)

	local vY = angleY *  Velocity  
	local vX = toTarget.X * angleXZ * Velocity 
	local vZ = toTarget.Z * angleXZ * Velocity 		

	cClone.Velocity = Vector3.new(vX, vY, vZ)
	cClone.Parent = Game.Workspace 
	cClone.Touched:connect(function(hitPart)
		if hitPart and hitPart.Parent and hitPart.Parent ~= Character and cClone and cClone:FindFirstChild('Welded') == nil and hitPart.Parent:FindFirstChild('Humanoid') then 
			cClone.Size = Vector3.new(6, 6, 6)			
			local cWeld = Instance.new('Weld')
			cWeld.Name = 'Welded'
			cWeld.Part0 = hitPart
			cWeld.Part1 = cClone 
			cWeld.Parent = cClone 
			cWeld.C1 = cClone.CFrame * hitPart.CFrame:inverse()

			DebrisService:AddItem(cClone, 4.5)
		end 
	end)
	Spawn(function()
		wait(3.5)
		if cClone:FindFirstChild('Welded') == nil then 
			cClone:Destroy()
		end 
	end)
	cClone.CanCollide = true 
	wait(3.5)

	Chair.Transparency = 0.0
	Tool.Enabled = true 
end

local function OnActivated()
	if not Tool.Enabled then 
		return 
	end 	

	if ChairActivate.Value == false then 
		Riding = true 

		FlightSpin = Instance.new("BodyGyro")
		FlightPower = Instance.new("BodyVelocity")
		FlightHold = Instance.new("BodyPosition")

		FlightHold.Name = "FlightHold"
		FlightHold.P = 100000
		FlightHold.maxForce = Vector3.new(0, 0, 0)


		FlightPower.Name = "FlightPower"
		FlightPower.velocity = Vector3.new(0, 0, 0)
		FlightPower.P = 1000000
		FlightPower.maxForce = Vector3.new(FlightPower.P, FlightPower.P, FlightPower.P)
		FlightPower.P = 10000

		FlightSpin.Name = "FlightSpin"
		FlightSpin.P = 1000000
		FlightSpin.maxTorque = Vector3.new(0, FlightSpin.P, 0)

		FlightSpin.cframe = Torso.CFrame
		FlightHold.position = Torso.Position

		FlightSpin.Parent = Torso		
		FlightHold.Parent = Torso
		FlightPower.Parent = Torso
		 
		ChairActivate.Value = true 

		RightArm = WaitForChild(Character, 'Right Arm')
		print(Character, RightArm, Character.Parent)
		--Game.Selection:Set({RightArm}) 
		RightGrip = WaitForChild(RightArm, 'RightGrip')
		RightGrip.Part0 = Torso
		RightGrip.Part1 = Chair	
		Chair.Size = Vector3.new(5, 3, 5) 
		RightGrip.Parent = Torso 
		RightGrip.C1 = CFrame.new(0, 0.6, 0, 1, -1.36735394e-014, 1.74845582e-007, -1.74845553e-007, 1.31134186e-007, 1, -2.34655502e-014, -1, 1.31134186e-007)

		--CreateCloneLegs() 

		SitAnim = Humanoid:LoadAnimation(Tool.SitAnim)
		if SitAnim then SitAnim:Play() end 

		--RightLeg.Transparency = 1.0
		--LeftLeg.Transparency = 1.0

		--local rMotor = WaitForChild(Torso, 'Right Shoulder')
		--rMotor.C1 = rMotor.C1 * CFrame.Angles(0, 0, math.pi/2)
		TorsoConnection = Torso.Touched:connect(LetTheTrollingBegin)
		Chair.Touched:connect(LetTheTrollingBegin)
	end 
end

local function SetHealth(factor)	
	local ratio = Humanoid.Health/Humanoid.MaxHealth
	Humanoid.MaxHealth = Humanoid.MaxHealth + factor 	

	print('setting', Humanoid.MaxHealth, ratio, factor)

	if factor > 0 then 
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

local function CreateHelpText()
	if Gui.Parent then return end 
	Gui = Instance.new('ScreenGui')
	Gui.Parent = WaitForChild(Player, 'PlayerGui')

	local sText = Instance.new('TextLabel')
	sText.Parent = Gui 
	sText.Text = "Can't throw your chair while you are riding it! Please unequip and reequip to throw."
	sText.FontSize = Enum.FontSize.Size18
	sText.Font = Enum.Font.ArialBold 
	sText.BackgroundTransparency = 1.0 
	sText.Size = UDim2.new(0, 500, 0, 100)
	sText.TextWrapped = true 
	sText.Position = UDim2.new(0.5, -200, 0, -100)
	sText.TextColor3 = Color3.new(1, 0, 0)
	sText.TextStrokeColor3 = Color3.new(1, 1, 1)
	sText.TextStrokeTransparency = 0.5

	sText:TweenPosition(UDim2.new(0.5, -250, 0, 70), 1, 1, 1, true)

	wait(7.5)
	Gui:ClearAllChildren()
	Gui.Parent = nil
end 

local function OnEquipped(mouse)
	Character = Tool.Parent 
	Torso = WaitForChild(Character, 'Torso')
	Mouse = mouse
	--SetHealth(Factor)
	if mouse then 
		mouse.KeyDown:connect(function(key)
			key = key:lower()
			if key == 'q' then 
				if Riding == true then 
					CreateHelpText()
				elseif Tool.Enabled then 
					ThrowChair()
				end 
			end 
		end)
	end 
	Tool.GripPos = Vector3.new(0, 1, 1)
end

local function OnUnequipped()
	if FlightSpin then FlightSpin:Destroy() end 
	if FlightPower then FlightPower:Destroy() end 
	if FlightHold then FlightHold:Destroy() end 

	--RightLeg.Transparency = 0.0
	--LeftLeg.Transparency = 0.0

	--DestroyCloneLegs()
	--SetHealth(-Factor)
	Riding = false 
	if TorsoConnection then TorsoConnection:disconnect() end

	Chair.Size = Vector3.new(2.5, 0.8, 3.5)

	if SitAnim then SitAnim:Stop() end 
	ChairActivate.Value = false 
end 

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)



