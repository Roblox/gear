local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')

local Horns = Instance.new('Part')
Horns.Size = Vector3.new(4.15, 1.88, 2.1)
Horns.Name = 'Horns'
Horns.CanCollide = false
local HornsMesh = Instance.new('SpecialMesh')
HornsMesh.TextureId = 'http://www.roblox.com/asset?id=126694422'
HornsMesh.MeshId = 'http://www.roblox.com/asset?id=126694637'
HornsMesh.Scale = Vector3.new(0.8,0.8,0.8)
HornsMesh.Parent = Horns
local Fire = Instance.new('Fire')
Fire.Color = Color3.new(0,0,0)
Fire.SecondaryColor = Color3.new(1,0,0)
Fire.Heat = 10
Fire.Size = 10
Fire.Parent = Horns

local TorsoGyro = Instance.new('BodyGyro')
TorsoGyro.Name = 'HornPotionTorsoGyro'
TorsoGyro.maxTorque = Vector3.new(1E10,1E10,1E10)

local YLocker = Instance.new('BodyPosition')
YLocker.Name = 'HornPotionYLocker'
YLocker.maxForce = Vector3.new(0, 1E8, 0)

local Mover = Instance.new('BodyForce')
Mover.Name = 'HornPotionMover'
Mover.force = Vector3.new(0,0,0)

local Torso
local Head
local Humanoid
local HornsClone
local YLockerClone
local TorsoGyroClone
local MoverClone
local Angle = 0

local UP = 17
local DOWN = 18
local RIGHT = 19
local LEFT = 20

local FORCE_MAGNITUDE = 3E3
local DRAG_COEFFICIENT = 50
local DELTA_ANGLE = math.pi/20

local KeyIsPressed = {}

local TIME_BETWEEN_USES = 32
local BEFORE_SOUND_TIME = 0.5
local AFTER_SOUND_TIME = 1.5
local NUM_TRANSPARENCY_STEPS = 10
local NUM_BEND_STEPS = 10

local Anims = {}

local DrinkSound
local LaughSound

local Debris = game:GetService('Debris')

local Mouse

local HORN_WELD_C1 = CFrame.new(0, -0.9446, -0.6, -1, 0, 0, 0, 1, 0, 0, 0, -1)

local function Play(animationName)
	if not Anims[animationName] then
		local humanoid = Tool.Parent:FindFirstChild('Humanoid')
		if humanoid and humanoid:IsA('Humanoid') then
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

local function weldHornsTo(character)
	local hornsClone = Horns:Clone()
	hornsClone.Transparency = 1.0
	hornsClone.Parent = character
	local weld = Instance.new('ManualWeld')
	weld.Part0 = character.Head
	weld.Part1 = hornsClone
	weld.C0 = CFrame.new()
	weld.C1 = HORN_WELD_C1
	weld.Parent = character
	
	return hornsClone
end

local function resetGlobalVariables()
	Angle = 0
	MoverClone = nil
	YLockerClone = nil
	TorsoGyroClone = nil
end

function OnKeyDown(key)
	KeyIsPressed[string.byte(key)] = true
end

function OnKeyUp(key)
	KeyIsPressed[string.byte(key)] = false
end

function OnTouched(part)
	local character = part.Parent
	if character and character ~= Tool.Parent and not character:FindFirstChild('HornPotionDebounceTag') then
		local humanoid = character:FindFirstChild('Humanoid')
		if humanoid then
			local debounce = Instance.new('BoolValue')
			debounce.Name = 'HornPotionDebounceTag'
			debounce.Parent = character
			Debris:AddItem(debounce, 1)
			local tag = Instance.new('ObjectValue')
			tag.Value = game.Players.LocalPlayer
			tag.Name = 'creator'
			tag.Parent = humanoid
			Debris:AddItem(tag, 2)
			
			if HornsClone then
				humanoid:TakeDamage(HornsClone.Velocity.magnitude)
			else
				humanoid:TakeDamage(20)
			end
		end
	end
end

function Run()
	while HornsClone and YLockerClone and TorsoGyroClone and MoverClone and Torso and Head do
		local speed = Torso.Velocity.magnitude
		if Anims['RunAnim'] then
			Anims['RunAnim']:AdjustSpeed(speed / 10)
		end
		local fire = HornsClone:FindFirstChild('Fire')
		if fire then
			fire.Heat = speed / 5
			fire.Size = speed / 4
		end		
		
		local camera = Workspace.CurrentCamera
		local cameraLook = camera.Focus.p - camera.CoordinateFrame.p
		cameraLook = Vector3.new(cameraLook.x, 0, cameraLook.z).unit
		local leftVector = Vector3.new(0,1,0):Cross(cameraLook)
		
		local part, point = Workspace:FindPartOnRay(Ray.new(Head.Position, Vector3.new(0,-999,-0)), Torso.Parent)
		if part then
			--print(part.Name)
			YLockerClone.position = Vector3.new(0, math.max(point.y + 2, Torso.Position.y - 10), 0)
		else
			YLockerClone.position = Vector3.new(0, Torso.Position.y - 10, 0)
		end
		
		local isFirstPerson = false
		if (camera.CoordinateFrame.p - Head.Position).magnitude < 0.5 then
			print(tostring(cameraLook))
			isFirstPerson = true
		end

		local force = Vector3.new(0,0,0)
		local gyroCFrame = TorsoGyroClone.cframe
		if KeyIsPressed[UP] or KeyIsPressed[string.byte('w')] or KeyIsPressed[string.byte('W')] then
			force = force + FORCE_MAGNITUDE * cameraLook
			gyroCFrame = CFrame.new(Vector3.new(), cameraLook) * CFrame.Angles(-math.pi/2,0,0)
		end
		if KeyIsPressed[DOWN] or KeyIsPressed[string.byte('s')] or KeyIsPressed[string.byte('S')] then
			force = force - FORCE_MAGNITUDE * cameraLook
			gyroCFrame = CFrame.new(Vector3.new(), -cameraLook) * CFrame.Angles(-math.pi/2,0,0)
		end
		if KeyIsPressed[LEFT] or KeyIsPressed[string.byte('a')] or KeyIsPressed[string.byte('A')] then
			force = force + FORCE_MAGNITUDE * leftVector
			Angle = math.min(Angle + DELTA_ANGLE, math.pi/2)
			gyroCFrame = CFrame.new(Vector3.new(), cameraLook) * CFrame.Angles(-math.pi/2, 0, Angle)		
		end
		if KeyIsPressed[RIGHT] or KeyIsPressed[string.byte('d')] or KeyIsPressed[string.byte('D')] then
			force = force - FORCE_MAGNITUDE * leftVector
			Angle = math.max(Angle - DELTA_ANGLE, -math.pi/2)
			gyroCFrame = CFrame.new(Vector3.new(), cameraLook) * CFrame.Angles(-math.pi/2, 0, Angle)		
		end
		
		local drag = -DRAG_COEFFICIENT * Torso.Velocity		
		
		MoverClone.force = force + drag
		if isFirstPerson then
			TorsoGyroClone.cframe = CFrame.Angles(-math.pi/2, 0, 0)
		else
			TorsoGyroClone.cframe = gyroCFrame
		end
		wait()
	end
end
		

function OnActivated()
	if Tool.Enabled then
		resetGlobalVariables()
		Tool.Enabled = false
		local character = Tool.Parent
		if character then
			Play('EatAnim')
			wait(BEFORE_SOUND_TIME)
			if character == Tool.Parent then
				DrinkSound = Tool:FindFirstChild('DrinkSound')
				if DrinkSound then DrinkSound:Play() end				
				Torso = character:FindFirstChild('Torso')
				Head = character:FindFirstChild('Head')
				Humanoid = character:FindFirstChild('Humanoid')
				if Torso and Head and Humanoid then
					HornsClone = weldHornsTo(character)
					HornsClone.Touched:connect(OnTouched)
					for i = 1, NUM_TRANSPARENCY_STEPS do
						Handle.Transparency = i / NUM_TRANSPARENCY_STEPS
						HornsClone.Transparency = 1 - i / NUM_TRANSPARENCY_STEPS
						wait(AFTER_SOUND_TIME / NUM_TRANSPARENCY_STEPS)
					end
					if DrinkSound then DrinkSound:Stop() end --prevent it from reaching the "ahhh" part... didn't want to upload a new sound
					--addFloatForce(character).Parent = Torso
					if character == Tool.Parent then
						YLockerClone = YLocker:Clone()
						YLockerClone.position = Torso.Position - Vector3.new(0, 1, 0)
						YLockerClone.Parent = Torso
						Humanoid.PlatformStand = true
						TorsoGyroClone = TorsoGyro:Clone()
						TorsoGyroClone.cframe = Torso.CFrame * CFrame.Angles(-math.pi/2,0,0)
						TorsoGyroClone.Parent = Torso
						MoverClone = Mover:Clone()
						MoverClone.Parent = Torso
						LaughSound = Tool:FindFirstChild('LaughSound')
						if LaughSound then LaughSound:Play() end
						if Mouse then 
							Mouse.KeyDown:connect(OnKeyDown)
							Mouse.KeyUp:connect(OnKeyUp)
						end
						Play('RunAnim')
						if Anims['RunAnim'] then Anims['RunAnim']:AdjustSpeed(0) end	-- Don't start running till you get mouse presses
						Spawn(Run)
					end
				end
				if DrinkSound then DrinkSound:Stop() end	
			end
		end
	end
end

function OnEquipped(mouse)
	Stop('EatAnim')
	Stop('RunAnim')
	Handle.Transparency = 0.0
	if mouse then Mouse = mouse end
	Tool.Enabled = true
end

function OnUnequipped()
	if Torso then
		local gyro = Torso:FindFirstChild('HornPotionTorsoGyro')
		if gyro then gyro:Destroy() end
		local bodyPos = Torso:FindFirstChild('HornPotionYLocker')
		if bodyPos then bodyPos:Destroy() end
		local mover = Torso:FindFirstChild('HornPotionMover')
		if mover then mover:Destroy() end
	end
	if HornsClone then HornsClone:Destroy() end
	if Humanoid then Humanoid.PlatformStand = false end
	Stop('EatAnim')
	Stop('RunAnim')
	if LaughSound then LaughSound:Stop() end
	if DrinkSound then DrinkSound:Stop() end
end
	

Tool.Equipped:connect(OnEquipped)
Tool.Activated:connect(OnActivated)
Tool.Unequipped:connect(OnUnequipped)

