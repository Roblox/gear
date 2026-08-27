-- Tool Variables --
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local IsFreezing = Tool:WaitForChild('IsFreezing')
local FreezeAnim = Tool:WaitForChild('FreezeAnim')
local FreezeOtherScript = script:WaitForChild('FreezeOtherScript')
local RestorePlayerScript = script:WaitForChild('RestorePlayerScript')
local RunAnim = Tool:WaitForChild('RunAnim')
local NumHits = Tool:WaitForChild('NumHits')

-- GUI Variables --
local YetiClubGui = Tool:WaitForChild('YetiClubGui')
local BarFrame = YetiClubGui:WaitForChild('Bar')
local FillFrame = BarFrame:WaitForChild('Fill')
local ChargeText = BarFrame:WaitForChild('Charge')

-- Character Variables --
local Character = nil
local PlayerMouse = nil

local OriginalGrip = Tool.Grip
local CurrentGrip = OriginalGrip
local DebrisService = game:GetService("Debris")

local IsToolEnabled = true
local IsFreezing = false
local IsBreathingIce = false

-- GUI Helper Functions --
local function ShowGui()
	local player = game.Players.LocalPlayer
	if player then
		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui then
			FillFrame.BackgroundColor3 = Color3.new(171 * 0.004, 22 * 0.004, 24 * 0.004)
			YetiClubGui.Parent = playerGui
		end
	end
end

local function RemoveGui()
	YetiClubGui.Parent = Tool
	ChargeText.Text = '0%'
end

local function updateGui()
	if NumHits then
		local p = NumHits.Value / 3
		if p == 1 then
			FillFrame.BackgroundColor3 = Color3.new(1 * 0.004, 185 * 0.004, 29 * 0.004)
			ChargeText.Text = 'Press Q or E!'
		else
			ChargeText.Text = string.format('%i', p * 100) .. '%'
		end
		FillFrame.Size = UDim2.new(p, 0, 0.8, 0)
	end
end

NumHits.Changed:connect(function(val)
	if val == 0 then
		FillFrame.BackgroundColor3 = Color3.new(171 * 0.004, 22 * 0.004, 24 * 0.004)
	end
	updateGui()
end)

function swordUp()
	CurrentGrip = OriginalGrip
end

function swordOut()
	CurrentGrip = OriginalGrip * CFrame.Angles(math.pi * 0.25, 0.4, 0)
end

function Toolinsword(Toolintime)
	delay(0, function()
		local startToolin = tick()
		local endToolin = startToolin + Toolintime
		while tick() < endToolin do
			Tool.Grip = CurrentGrip * CFrame.Angles(math.pi * 2 * ((tick() - startToolin) / Toolintime), 0, 0)
			wait()
		end
		Tool.Grip = CurrentGrip
	end)
end

local function createFrost(parent, riseVelocity, smokeSize)
	local part = Instance.new('Part')
	part.Name = 'Effect'
	part.CanCollide = false
	part.Transparency = 1
	part.FormFactor = 'Custom'
	part.Size = Vector3.new(0, 0, 0)
	
	local frost = Instance.new("Smoke")
	frost.Color = Color3.new(0.8, 0.8, 1)
	frost.Size = smokeSize
	frost.RiseVelocity = riseVelocity
	frost.Parent = part
	
	local motor = Instance.new("Motor")
	motor.Part0 = parent
	motor.Part1 = part
	motor.C0 = CFrame.new(0, 0, 0) * CFrame.Angles((3 * math.pi) * 0.5, 0, 0)
	motor.Parent = part
	DebrisService:AddItem(part, 5)
	part.Parent = parent
	wait(0.2)
	
	return part
end

local function onBreathingIce(humanoid, torso, head)
	IsBreathingIce = true
	if NumHits then
		NumHits.Value = 0
	end
	Tool.IsFreezing.Value = IsBreathingIce
	local previousWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0.1
	local freezeAnim = humanoid:LoadAnimation(FreezeAnim)
	freezeAnim:Play(nil, nil, 1.5)
	swordUp()
	Tool.Grip = CurrentGrip
	wait(0.25)
	
	local sound = Handle:FindFirstChild("FreezeSound")
	if sound then
		sound:play()
	end
	
	part = createFrost(head, 8, 0.5)
	
	for i=1,8 do
		if part and part.Parent then
			local part2 = Instance.new("Part")
			part2.Name = "Effect"
			part2.Transparency = 1
			part2.CanCollide = false
			part2.FormFactor = "Custom"
			part2.Position = part.Position
			part2.Shape = "Ball"
			part2.Size = Vector3.new(3, 3, 3)
			part2.Velocity = (torso.CFrame.lookVector * 40) + (Vector3.new((math.random() - 0.5) * 2, (math.random() - 0.5) * 2,(math.random() - 0.5) * 2) * 8)
			
			local bodyForce = Instance.new("BodyForce")
			bodyForce.force = Vector3.new(0, part2:GetMass() * 196.2, 0)
			bodyForce.Parent = part2
			
			local freezeScript = FreezeOtherScript:Clone()
			freezeScript.Parent = part2
			freezeScript.Disabled = false
			
			local objectValue = Instance.new('ObjectValue')
			objectValue.Name = 'RestorePlayer'
			objectValue.Value = RestorePlayerScript
			objectValue.Parent = part2
			
			local c = Instance.new("ObjectValue")
			c.Name = "creator"
			c.Value = game.Players.LocalPlayer
			c.Parent = part2
			DebrisService:AddItem(part2, 1)
			part2.Parent = game.Workspace
		end
		wait(0.35)
	end
	
	IsBreathingIce = false
	local canBreath = Tool:FindFirstChild('CanBreath')
	if canBreath then
		ChargeText.Text = '0%'
		canBreath.Value = false
	end
	Tool.IsFreezing.Value = IsBreathingIce
	humanoid.WalkSpeed = previousWalkSpeed
	
	wait(0.4)
	if sound then
		sound:Stop()
	end
	
	wait(0.1)
	
	if part then
		part:remove()
	end
end

local function onKeyDown(key)
	key = string.lower(key)
	
	if key == 'q' or key =='e' then
		if Character then
			local humanoid = Character:FindFirstChild('Humanoid')
			local torso = Character:FindFirstChild('Torso')
			local head = Character:FindFirstChild('Head')
			
			if humanoid and humanoid.Health > 0 and torso and head then
				if not IsBreathingIce then
					local canBreath = Tool:FindFirstChild('CanBreath')
					if canBreath and canBreath.Value then
						onBreathingIce(humanoid, torso, head)
					end
				end
			end
		end
	end
end

local function onEquipped(mouse)
	--local currentlast = lastequipped
	
	if not mouse then
		print("Mouse not found")
		return 
	end
	
	PlayerMouse = mouse
	
	-- change icon
	PlayerMouse.Icon = 'rbxasset://textures\\GunCursor.png'	
	Character = Tool.Parent
	ShowGui()
	PlayerMouse.KeyDown:connect(onKeyDown)
end

local function onActivated()
	if not IsToolEnabled then
		return
	end
	
	IsToolEnabled = false
	
	if PlayerMouse then
		PlayerMouse.Icon = 'rbxasset://textures\\GunWaitCursor.png'
		wait(0.75)
		PlayerMouse.Icon = 'rbxasset://textures\\GunCursor.png'
	end
	
	IsToolEnabled = true
end

local function onUnequipped()
	RemoveGui()
end

Tool.Equipped:connect(onEquipped)
Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)

RunAnim.Changed:connect(function()
	if Character then
		local humanoid = Character:FindFirstChild("Humanoid")
		local torso = Character:FindFirstChild("Torso")
		local anim = Tool:FindFirstChild(RunAnim.Value)
		if anim and torso and humanoid then
			local theAnim = humanoid:LoadAnimation(anim)
			if theAnim and humanoid.Health > 0 then
				theAnim:Play()
				if RunAnim.Value == 'RightSlash' then
					Toolinsword(0.5)
				end
				if RunAnim.Value == 'OverHeadSwing' then
					wait(0.25)
					swordOut()
					Tool.Grip = CurrentGrip
					wait(0.5)
					swordUp()
					Tool.Grip = CurrentGrip
				elseif RunAnim.Value == 'OverHeadSwingFast' then
					wait(0.125)
					swordOut()
					Tool.Grip = CurrentGrip
					wait(0.25)
					swordUp()
					Tool.Grip = CurrentGrip
				end
			end
		end
	end
end)
