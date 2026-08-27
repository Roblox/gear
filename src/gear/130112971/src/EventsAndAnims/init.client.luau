local Tool = script.Parent
local Anims = {}
local LaserParts = Tool:WaitForChild('LaserParts')
local Handle = Tool:WaitForChild('Handle')
local SpecialMesh = Handle:WaitForChild('Mesh')
local ReequipScript = Tool:WaitForChild('ReequipScript')
local Mouse
local MouseIsDown = false
local MouseDownTime = 0

local Debris = game:GetService('Debris')

local CurrentColor = BrickColor.Random()
for _, part in pairs(LaserParts:GetChildren()) do
	local fire = part:FindFirstChild('Fire')
	if fire then fire.Color = CurrentColor.Color end
end

local function getBrightColor(brickColor)
	local color = brickColor.Color
	local maxComponent = math.max(color.r, math.max(color.g, color.b))
	return Color3.new(color.r/maxComponent, color.g/maxComponent, color.b/maxComponent)
end

local FirePart = Instance.new('Part')
FirePart.FormFactor = Enum.FormFactor.Custom
FirePart.Size = Vector3.new(0.2,0.2,0.2)
FirePart.Anchored = true
FirePart.Name = "FirePart"
local Fire = Instance.new('Fire', FirePart)
Fire.Size = 5
Fire.Heat = 9
--Fire.SecondaryColor = Color3.new(1,1,1)
local Light = Instance.new('PointLight', FirePart)
Light.Color = getBrightColor(CurrentColor)

local ChargeSound
local DingSound
local LaserSound


-- yay, stravant:
local function CFrameFromTopBack(at, top, back)
	local right = top:Cross(back)
	return CFrame.new(at.x, at.y, at.z,
		              right.x, top.x, back.x,
		              right.y, top.y, back.y,
		              right.z, top.z, back.z)
end

local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid.ClassName == 'Humanoid' then
			local unloadedAnim = Tool:FindFirstChild(animationName)
			if unloadedAnim then
				Anims[animationName] = humanoid:LoadAnimation(unloadedAnim)
			end
		end
	end
	if Anims[animationName] then
		Anims[animationName]:Play()
	end
end

local function Stop(animationName)
	if Anims[animationName] then 
		Anims[animationName]:Stop()
	end
end

local function makeLaser(pt1, pt2, power, color)
	if not color then color = BrickColor.Random() end
	local center = (pt1 + pt2) / 2
	local offset = pt2 - pt1
	local height = offset.magnitude
	local part = Instance.new('Part')
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 0.3
	part.FormFactor = Enum.FormFactor.Custom
	part.Size = Vector3.new(0.2,1,0.2)
	part.BrickColor = color
	local mesh = Instance.new('CylinderMesh', part)
	mesh.Scale = Vector3.new(power,height,power)
	
	Debris:AddItem(part, 0.5)
	part.Parent = Tool
	part.CFrame = CFrameFromTopBack(center, offset.unit, offset.unit:Cross(Vector3.new(0,1,0)))
end

local function damageTarget(target, power, color)
	local char = target.Parent
	if char and char ~= Tool.Parent then
		local humanoid = char:FindFirstChild('Humanoid')
		if not humanoid then
			char = char.Parent
			if char and char ~= Tool.Parent then
				humanoid = char:FindFirstChild('Humanoid')
			end
		end
		if humanoid then
			local tag = Instance.new('ObjectValue')
			tag.Name = 'creator'
			tag.Value = game.Players.LocalPlayer
			tag.Parent = humanoid
			
			humanoid:TakeDamage(15 * power ^ 1.18)
			local fire = Instance.new('Fire')
			fire.Color = color.Color
			fire.Size = 5 + power * 2
			fire.Heat = 9 + power * 3
			Debris:AddItem(fire, 2)
			fire.Parent = target
		end
	end		
end

function OnActivated(power)
	SpecialMesh.VertexColor = Vector3.new(1,1,1)
	power = power and math.min(5, math.max(1, power)) or 1
	if Mouse and Tool.Enabled then
		Tool.Enabled = false
		local reequipClone = ReequipScript:Clone()
		reequipClone.Parent = Tool
		reequipClone.Disabled = false
		
		Play('FireAnim')
		LaserSound = Handle:FindFirstChild('LaserSound')
		if LaserSound then 
			LaserSound.Volume = 0.1 + power * 0.02
			LaserSound:Play()
		end
		
		Mouse.TargetFilter = Tool.Parent
		local targetPoint = Mouse.Hit.p
		local target = Mouse.Target
		
		if not target then 
			targetPoint = Handle.Position + (Mouse.Hit.p - Handle.Position).unit * 1000
		else
			damageTarget(target, power, CurrentColor)
		end

		for _, part in pairs(LaserParts:GetChildren()) do
			makeLaser(part.Position, targetPoint, power, CurrentColor)
		end
		local firePartClone = FirePart:Clone()
		firePartClone:WaitForChild('PointLight').Color = getBrightColor(CurrentColor)
		firePartClone.PointLight.Range = 8 + 5 * (power - 1)
		Debris:AddItem(firePartClone, 0.5)
		firePartClone.Parent = Tool
		firePartClone.CFrame = CFrame.new(targetPoint)
		local fireClone = firePartClone:WaitForChild('Fire')
		fireClone.Size = 5 + power * 2
		fireClone.Heat = 9 + power * 3
		fireClone.Color = CurrentColor.Color
		
		CurrentColor = BrickColor.Random()
		for _, part in pairs(LaserParts:GetChildren()) do
			local fire = part:FindFirstChild('Fire')
			if fire then 
				fire.Size = 2
				fire.Heat = 1
				fire.Enabled = false 
			end			
		end
		wait(0.4)
		for _, part in pairs(LaserParts:GetChildren()) do
			local fire = part:FindFirstChild('Fire')
			if fire then
				fire.Enabled = true
				fire.Color = CurrentColor.Color
			end
		end
		
	end
end

function OnButton1Down()
	local measuredMouseDownTime = false
	MouseIsDown = true
	local power = 0
	local alreadyDinged = false
	ChargeSound = Handle:FindFirstChild('ChargeSound')
	if ChargeSound then ChargeSound:Play() end
	while MouseIsDown do
		if not measuredMouseDownTime and Tool.Enabled then
			print"Hi"
			measuredMouseDownTime = true
			MouseDownTime = tick()
		end
		power = measuredMouseDownTime and tick() - MouseDownTime or 0
		if power > 5 and not alreadyDinged then
			alreadyDinged = true
			if ChargeSound then ChargeSound:Stop() end
			DingSound = Handle:FindFirstChild('DingSound')
			if DingSound then DingSound:Play() end
			SpecialMesh.VertexColor = Vector3.new(1,0,0)
		end
		for _, part in pairs(LaserParts:GetChildren()) do
			local fire = part:FindFirstChild('Fire')
			if fire then
				fire.Size = 2 + power
				fire.Heat = 1 + 3 * power
			end
		end
		wait()
	end
end

function OnButton1Up()
	if ChargeSound then ChargeSound:Stop() end
	if MouseIsDown then
		MouseIsDown = false
		local power = tick() - MouseDownTime
		OnActivated(power)
	end
end

function OnEquipped(mouse)
	Mouse = mouse
	if Mouse then
		Mouse.Button1Down:connect(OnButton1Down)
		Mouse.Button1Up:connect(OnButton1Up)
	else
		Tool.Activated:connect(OnActivated)
	end	
	Play('EquipAnim')
end

function OnUnequipped()
	MouseIsDown = false
	Stop('EquipAnim')
	Stop('FireAnim')
	if LaserSound then LaserSound:Stop() end
	if DingSound then DingSound:Stop() end
	if ChargeSound then ChargeSound:Stop() end
	SpecialMesh.VertexColor = Vector3.new(1,1,1)
	for _, part in pairs(LaserParts:GetChildren()) do
		local fire = part:FindFirstChild('Fire')
		if fire then
			fire.Enabled = true
			fire.Color = CurrentColor.Color
			fire.Size = 2
			fire.Heat = 1
		end
	end
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)