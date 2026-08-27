--Made by Stickmasterluke

local Tool = script.Parent
local OriginalGrip = Tool.Grip
--local OriginalGrip = CFrame.new(0.0500000045, 1.93715096e-007, -1.90000033, 0, 0, -1, -1, 1.31134158e-007, 0, 1.31134158e-007, 1, 0)
local CurrentGrip = OriginalGrip
local Enabled = true
local Equipped = false
local Debris = game:GetService("Debris")

local EquipAnim = Tool:WaitForChild('Equip')

-- CONSTANTS --
local SWING_SPEED = 1.5

function WaitFor(parent, name)
	while true do
		local child = parent:FindFirstChild(name)
		if child ~= nil then
			return child
		end
		wait()
	end
end

WaitFor(Tool, 'Handle')
function OnButton1Down(mouse)
	if not Enabled then
		return
	end
	Enabled = false
	mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
	wait(.75)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	Enabled = true
end

-- HELPER FUNCTIONS --
local function GetPointLight(color)
	local pointLight = Instance.new('PointLight')
	if color then
		pointLight.Color = color
	else
		pointLight.Color = Color3.new(255, 255, 0)
	end
	pointLight.Range = 8
	
	return pointLight
end

local function GetFire(size, heat)
	local fire = Instance.new('Fire')
	fire.Color = Color3.new(255, 255, 255)
	fire.SecondaryColor = Color3.new(208, 208, 0)
	fire.Size = size
	fire.Heat = heat
	
	return fire
end

function SwordUp()
	CurrentGrip = OriginalGrip
end

function SwordOut()
	CurrentGrip=OriginalGrip*CFrame.Angles(math.pi/4,.4,0)
end

function SpinSword(spinTime)
	delay(0,function()
		local startSpin = tick()
		local endSpin = startSpin + spinTime
		while tick() < endSpin do
			Tool.Grip = CurrentGrip * CFrame.Angles(math.pi * 2 * ((tick() - startSpin) / spinTime), 0, 0)
			wait()
		end
		Tool.Grip = CurrentGrip
	end)
end

Tool.Equipped:connect(function(mouse)
	Equipped = true
	local currentlast = lastequipped
	
	if mouse == nil then
		print("Mouse not found")
		return 
	end
	
	local humanoid = Tool.Parent:FindFirstChild('Humanoid')
	local theAnim = humanoid:LoadAnimation(EquipAnim)
	if humanoid and theAnim then
		theAnim:Play(nil, nil, 1.5)
	end
	
	local pointLight = GetPointLight(Color3.new(255, 255, 255))
	pointLight.Parent = Tool.Handle
	
	mouse.Icon = "rbxasset://textures\\GunCursor.png"
	mouse.Button1Down:connect(function()
		OnButton1Down(mouse)
	end)
	mouse.KeyDown:connect(function(key)
		key = string.lower(key)
		
		if key == "l" or key == "t" or key == "g" then
			local humanoid = Tool.Parent:FindFirstChild("Humanoid")
			if humanoid ~= nil then
				-- filler for something?
			end
		end
	end)
end)

Tool.Unequipped:connect(function()
	Equipped = false
end)

local function SpinAttack(torso)
	local spinForce = Instance.new("BodyAngularVelocity")
	spinForce.P = 1000000
	spinForce.angularvelocity = Vector3.new(0,20,0)
	spinForce.maxTorque = Vector3.new(spinForce.P, spinForce.P, spinForce.P)
	
	local pointLight = GetPointLight()
	local fire = GetFire(15, 15)
	
	spinForce.Parent = torso
	fire.Parent = torso
	pointLight.Parent = torso
	local sound = Tool.Handle:FindFirstChild('FlashSound')
	if sound then
		sound:Play()
	end
	wait(0.75)
	if sound then
		sound:Play()
	end
	wait(0.75)
	spinForce.Parent = nil
	fire.Parent = nil
	pointLight.Parent = nil
end

local function SpawnLight(torso)
	local part = Instance.new('Part')
	part.CFrame = CFrame.new(torso.Position - Vector3.new(0, 2.5, 0))
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	
	local fire = GetFire(25, 15)
	fire.Parent = part
	
	local pointLight = GetPointLight()
	pointLight.Parent = part
	part.Parent = game.Workspace
	Debris:AddItem(part, 1)
end

local function OverHeadSwing(torso)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.maxForce = Vector3.new(1,1,1) * 10^6
	bodyVelocity.velocity = ((torso.CFrame.lookVector * Vector3.new(1,0,1)) + Vector3.new(0,3,0)) * 10
	Debris:AddItem(bodyVelocity, 4)
	bodyVelocity.Parent = torso
	wait(0.25 * SWING_SPEED)
	SwordOut()
	
	local sound = Tool.Handle:FindFirstChild("FlashSound")
	if sound then
		sound:Play()
	end
	wait(0.15 * SWING_SPEED)
	
	if bodyVelocity then
		bodyVelocity.velocity = Vector3.new(0,-80,0)
	end
	
	wait(0.15 * SWING_SPEED)
	local sound2 = Tool.Handle:FindFirstChild('FlashSound')
	if sound2 then
		sound2:Play()
	end
	SpawnLight(torso)
	SwordUp()
	Tool.Grip = CurrentGrip
	
	if bodyVelocity then
		bodyVelocity:remove()
	end
	wait(1)
end

WaitFor(Tool,"RunAnim")
function OnAnimChanged()
	local humanoid = Tool.Parent:FindFirstChild('Humanoid')
	local torso = Tool.Parent:FindFirstChild('Torso')
	local anim = Tool:FindFirstChild(Tool.RunAnim.Value)
	
	if anim and torso and humanoid then
		local theAnim = humanoid:LoadAnimation(anim)
		if Tool.RunAnim.Value == 'SwordSpin' and theAnim then
			theAnim:Play(nil, nil, 0.25)
		else
			theAnim:Play(nil, nil, 1/SWING_SPEED)
		end
		
		if theAnim and humanoid.Health > 0 then
			if Tool.RunAnim.Value == "RightSlash" or Tool.RunAnim.Value == "LeftSlash" or Tool.RunAnim.Value == "OverHeadSwing" then
				SpinSword(0.5 * SWING_SPEED)
			end

			if Tool.RunAnim.Value == 'SwordSpin' then
				SpinAttack(torso)
			elseif Tool.RunAnim.Value=="OverHeadSwing" then
				OverHeadSwing(torso)
			else
				local sound = Tool.Handle:FindFirstChild("SlashSound")
				if sound then
					sound:Play()
				end
			end
		end
	end
end

Tool.RunAnim.Changed:connect(OnAnimChanged)
