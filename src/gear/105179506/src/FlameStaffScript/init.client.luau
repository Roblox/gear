--------------------
--| WaitForChild |--
--------------------

-- Waits for parent.child to exist, then returns it
local function WaitForChild(parent, childName)
	assert(parent, "ERROR: WaitForChild: parent is nil")
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end
--------------------------------

local ROTATION_SPIN_SPEED = math.pi / 5
local BLOCK_RESET_TIME = 0.5
local BLOCK_COOLDOWN = 2
local BUTTON_CLICK_TIME = 0.1
local ATTACK_DURATION = 0.46
local ATTACK_COOLDOWN = 1
local LARGE_NUMBER = 2 ^ 20
local BASE_CLAW_DAMAGE = 35
local BLOCK_VALUE_NAME = 'Blocking'

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local Handle
local SpinMotor
local RotatingPart
local FlameHolder
local ShieldFire

local MyMouse
local MyCharacter
local MyHumanoid

local Blocking = false
local Attacking = false
local BlockStartTick = 0
local BlockStopTick = 0
local LastAttackTick = 0
local RightButtonDownTick = 0
local LastBlockTick = 0

local HitsWithoutMissing = 0

local HitHumanoids = {}

local ClawAnim
local ClawTrack

local EnrageAnim
local EnrageTrack

local Claw
local ClawWeld
local BlockValue

local CreatorTag

function CreateSound(name, soundId, volume)
	local newSound = Instance.new('Sound')
	newSound.SoundId = soundId
	newSound.Name = name
	newSound.Volume = volume
	return newSound
end


local Sounds = {Hit = CreateSound('HitSound', 'http://www.roblox.com/Asset?ID=92597264', 0.5),
						Swing1 = CreateSound('SwingSound', 'http://www.roblox.com/Asset?ID=92597296', 0.4),
						Swing2 = CreateSound('SwingSound2', 'http://www.roblox.com/Asset?ID=92628581', 1)
			 }

local ShieldPart = nil

local ShieldPartPrefab = Instance.new('Part')
ShieldPartPrefab.TopSurface = 'Smooth'
ShieldPartPrefab.BottomSurface = 'Smooth'
ShieldPartPrefab.FormFactor = 'Custom'
ShieldPartPrefab.Size = Vector3.new(0.2,0.2,0.2)
ShieldPartPrefab.CanCollide = false
ShieldPartPrefab.Transparency = 0.6
local ShieldMeshPrefab = Instance.new('SpecialMesh')
ShieldMeshPrefab.MeshId = 'http://www.roblox.com/asset/?id=94736101'
ShieldMeshPrefab.TextureId = 'http://www.roblox.com/asset/?id=94735715'
ShieldMeshPrefab.VertexColor = Vector3.new(0,1,0.1)
ShieldMeshPrefab.Scale = Vector3.new(3.5,3.5,3.5)
ShieldMeshPrefab.Parent = ShieldPartPrefab



function FindCharacter(part)
	if part.Parent == nil or part == Workspace then return nil end
	if part:FindFirstChild('Humanoid') then return part end
	return FindCharacter(part.Parent)
end

-- This function checks in char1 is behind char2
function IsBehindCharacter(char1, char2)
	local char1Torso = char1:FindFirstChild('Torso')
	local char2Torso = char2:FindFirstChild('Torso')
	if char1Torso and char2Torso then
		local attackVector = (char1Torso.CFrame.p - char2Torso.CFrame.p).unit
		return attackVector:Dot(char2Torso.CFrame.lookVector) < 0
	end
	return false -- return nil to signify fail?
end

function IsCharacterBlocking(character)
	-- Stubbing this out for now
	return character and character:FindFirstChild(BLOCK_VALUE_NAME) and character[BLOCK_VALUE_NAME].Value
end

function IsTool()
	return script.Parent:IsA('Tool')
end

function IsLegoBody(character)
	-- Not sure if there is a less hacky way of doing this
	-- But I figure any body with a Left Hand must be a lego guy
	return (character and character:FindFirstChild('Left Hand') ~= nil)
end

function ApplyTag(target)
	while target:FindFirstChild('creator') do
		target.creator:Destroy()
	end
	CreatorTag:Clone().Parent = target
end

function CreateClaw()
	DestroyClaw()
	Claw = Instance.new('Part')
	Claw.TopSurface = 'Smooth'
	Claw.BottomSurface = 'Smooth'
	Claw.FormFactor = 'Custom'
	Claw.Locked = true
	Claw.CanCollide = false
	Claw.Name = 'Claw'
	Claw.Size = Vector3.new(2, 2, 1)
	
	local clawMesh = Instance.new('SpecialMesh')
	clawMesh.MeshId = 'http://www.roblox.com/asset/?id=103743122'
	clawMesh.Scale = Vector3.new(0.75, 0.75, 0.75)
	clawMesh.TextureId = 'http://www.roblox.com/asset/?id=103743176'
	clawMesh.Parent = Claw	
	
	local clawWeldPart = MyCharacter:FindFirstChild('Left Arm')
	if IsLegoBody(MyCharacter) then
		clawWeldPart = MyCharacter:FindFirstChild('Left Hand')
	end
	if clawWeldPart then
		ClawWeld = Instance.new('ManualWeld')
		ClawWeld.Name = 'ClawWeld'
		ClawWeld.C0 = CFrame.Angles(0, math.pi/2, 0) * CFrame.Angles(-math.pi/2, 0,0) + Vector3.new(0,-2,0)
		ClawWeld.Part0 = clawWeldPart
		ClawWeld.Part1 = Claw
		ClawWeld.Parent = clawWeldPart
	end
	Claw.Parent = Tool
end

function DestroyClaw()
	if Claw then
		Claw:Destroy()
		Claw = nil
	end
	if ClawWeld then
		ClawWeld:Destroy()
		ClawWeld = nil
	end
end

local InBlowback = false
function SufferBlowback(otherTorso)
	if InBlowback then return end
	InBlowback = true
	local MyTorso = MyCharacter:FindFirstChild('Torso')
	if MyTorso then
		local bodyForce = MyTorso:FindFirstChild('BodyForce')
		if bodyForce and bodyForce.force.magnitude < 30000 then
			local blowBackForce = (MyTorso.CFrame.p - otherTorso.CFrame.p).unit * 32000 
			bodyForce.force = bodyForce.force + blowBackForce
			wait(0.5)
			bodyForce.force = bodyForce.force - blowBackForce
		end
	end
	InBlowback = false
end

function TweenMesh(mesh, start, final, duration)
	local startTime = tick()
	while	 tick() - startTime < duration do
		mesh.Scale = start:Lerp(final, (tick() - startTime) / duration)
		wait()
	end
end


function ToggleBlock()
	if tick() - LastAttackTick < ATTACK_COOLDOWN then
		return
	end
	if tick() - LastBlockTick < BLOCK_COOLDOWN then
		print("wait to block again")
		return
	end
	if not Blocking then
		LastBlockTick = tick()
		Blocking = true
		BlockValue.Value = Blocking		
		StartBlock()
		wait(BLOCK_RESET_TIME)
		EndBlock()
		Blocking = false		
		BlockValue.Value = Blocking
			--[[
			if tick() - BlockStopTick < BLOCK_RESET_TIME then
				return false
			end
			StartBlock()
		else
			if tick() - BlockStartTick < BLOCK_RESET_TIME then
				return false
			end
			EndBlock()
		end
		--]]
	end
	return true
end

function StartBlock()
	BlockStartTick = tick()
	ShieldPart = ShieldPartPrefab:Clone()
	local MyTorso = MyCharacter:FindFirstChild('Torso')
	if MyTorso then
		coroutine.wrap(TweenMesh)(ShieldPart.Mesh, Vector3.new(), ShieldPart.Mesh.Scale, BLOCK_RESET_TIME / 1.4)
		ShieldPart.Parent = MyTorso
		local weld = Instance.new('ManualWeld')
		weld.Part0 = MyTorso
		weld.Part1 = ShieldPart
		weld.Parent = ShieldPart
	end
	if SpinMotor then
		SpinMotor.MaxVelocity = ROTATION_SPIN_SPEED
		SpinMotor.CurrentAngle = 0
		SpinMotor.DesiredAngle = LARGE_NUMBER
	end
	if ShieldFire then
		ShieldFire.Enabled = true
	end
end


function EndBlock()
	BlockStopTick = tick()
	if ShieldPart then
		ShieldPart:Destroy()
		ShieldPart = nil
	end
	if SpinMotor then
		SpinMotor.CurrentAngle = 0
		SpinMotor.DesiredAngle = 0
	end
	if ShieldFire then
		ShieldFire.Enabled = false
	end
end


function OnRightButtonDown()
	print("Button DOWN")
	RightButtonDownTick = tick()
end

function OnRightButtonUp()
	print("Button UP")
	print(tick() - RightButtonDownTick)
	if tick() - RightButtonDownTick < BUTTON_CLICK_TIME then
		ToggleBlock()
	end
end


function OnKeyDown(key)
	key = string.byte(key)
	--print(key)
	-- 0 is ctrl (among some other special keys) and 48 is shift
	if key == string.byte('r') or key == 0 or key == 48 then
		ToggleBlock()	
	end
end


function OnEquipped(mouse)
	print("Entering Equip")
	-- Get the childrens
	MyMouse = mouse
	
	ClawAnim = WaitForChild(script, 'ClawAttack')
	-- Got the childrens
	if IsTool() then
		MyCharacter = Tool.Parent
		Handle = WaitForChild(Tool, 'Handle')
		SpinMotor = WaitForChild(Handle, 'Motor6D')
		RotatingPart = WaitForChild(Tool, 'RotatingPart')
		FlameHolder = WaitForChild(Tool, 'FlameHolder')
		ShieldFire = WaitForChild(FlameHolder, 'Flame')
		wait()
		--CreateClaw()
		-- Use zombie syringe inject if your a normal person
		ClawAnim.AnimationId = 'http://www.roblox.com/Asset?ID=93642075'
	else
		MyCharacter = script.Parent.Parent
		MyMouse = MyPlayer:GetMouse()
		Claw = WaitForChild(MyCharacter, 'Claw')
		Handle = WaitForChild(MyCharacter, 'Staff')
		SpinMotor = WaitForChild(Handle, 'BladeGrip')
		RotatingPart = WaitForChild(MyCharacter, 'StaffBlade')
	end
	
	
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = WaitForChild(MyCharacter, 'Humanoid')
	ClawTrack = MyHumanoid:LoadAnimation(ClawAnim)
	CreatorTag = Instance.new('ObjectValue')
	CreatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
	CreatorTag.Value = MyPlayer	
	if IsTool() then
		EnrageAnim = WaitForChild(script, 'Enrage')
		EnrageTrack = MyHumanoid:LoadAnimation(EnrageAnim)
	end
	--Claw.Touched:connect(OnHit)
	for _, sound in pairs(Sounds) do
		sound.Parent = Handle		
	end
	if SpinMotor then
		SpinMotor.MaxVelocity = ROTATION_SPIN_SPEED
	end	

	-- Wait is needed here because creating more objects will trigger equip again, and exceed re-entry depth.
	wait()

	-- might need to clean-up old block values before-hand if they exist?
	BlockValue = Instance.new('BoolValue')
	BlockValue.Value = false
	BlockValue.Name = BLOCK_VALUE_NAME
	BlockValue.Parent = MyCharacter
	-- activate shielding
	--[[
	MyMouse.Button2Down:connect(OnRightButtonDown)
	MyMouse.Button2Up:connect(OnRightButtonUp)
	MyMouse.KeyDown:connect(OnKeyDown)
	--]]
	print("Exiting Equip")
end

function OnUnequipped()
	print("Entering Unequip")
	if Blocking then
		EndBlock()
	end
	--DestroyClaw()
	BlockValue:Destroy()
	-- stop all sounds
	-- stop all weapon anims
	print("Exiting Unequip")
end

function OnHit(hitPart)
	if Attacking then
		-- Do hit processing logic
		local myHumanoid = MyCharacter:FindFirstChild('Humanoid')
		local hitCharacter = FindCharacter(hitPart)
		local hitHumanoid = hitCharacter and hitCharacter:FindFirstChild('Humanoid')
		local hitPlayer = hitCharacter and PlayersService:GetPlayerFromCharacter(hitCharacter)
		if myHumanoid and myHumanoid.Health > 0 and hitCharacter and
			hitHumanoid and hitHumanoid.Health > 0 and not HitHumanoids[hitHumanoid] then
			if hitPlayer and MyPlayer and (hitPlayer.TeamColor ~= MyPlayer.TeamColor or IsTool()) then
				-- Determine if hit character is blocking
				if IsCharacterBlocking(hitCharacter) and not IsBehindCharacter(MyCharacter, hitCharacter) then
						-- get staggered
						SufferBlowback(hitCharacter:FindFirstChild('Torso'))
				else
					-- deal dmg
					print("dmg")
					Sounds['Hit']:Play()
					if hitHumanoid.Health <= BASE_CLAW_DAMAGE and EnrageTrack then
						EnrageTrack:Play()
					end
					hitHumanoid:TakeDamage(BASE_CLAW_DAMAGE)
					HitsWithoutMissing = HitsWithoutMissing + 1
					if HitsWithoutMissing == 3 and Workspace:FindFirstChild('MainGameScript') then
						local threeHits = Instance.new('ObjectValue')
						threeHits.Value = MyPlayer
						threeHits.Name = 'HitStreak'
						threeHits.Parent = Workspace:FindFirstChild('MainGameScript')
					end
						
					CreateHitEffect(hitPart.CFrame.p)
					ApplyTag(hitHumanoid)

				end
				HitHumanoids[hitHumanoid] = true
			end
		end
	end
end

function OnActivated()
	if tick() - LastAttackTick < ATTACK_COOLDOWN then
		print("wait to attack again")
		return
	end
	if tick() - LastBlockTick < BLOCK_RESET_TIME * 2 then
		print("wait to attack after block")
	return
	end
	if Blocking then
		print("Can't attack while blocking")
		return	
	end
	Sounds['Swing2']:Play()
	LastAttackTick = tick()
	Attacking = true
	HitHumanoids = {}

	--ClawTrack:AdjustSpeed(1)
	-- play attack with left claw weapon animation
	if IsTool() then
		ClawTrack:Play(0.1, 1, 1.5)
		if SpinMotor then
			SpinMotor.DesiredAngle = LARGE_NUMBER
		end
		if ShieldFire then
			ShieldFire.Enabled = true
		end
	else
		ClawTrack:Play(0.25, 1, 2.35)
	end
	
	--ClawTrack:AdjustSpeed(3)

	wait(0.1) -- Wait for Claw not to be back
	
	--ClawTrack:AdjustSpeed(1/3)
	if Claw then
		if Claw:FindFirstChild('Mesh') then
			Claw.Mesh.VertexColor = Vector3.new(1,0,0)		
		end
	end
	
	local connections = {}
	if Claw then
		table.insert(connections, Claw.Touched:connect(OnHit))
	end
	if IsTool() then
		if Handle then
			table.insert(connections, Handle.Touched:connect(OnHit))
		end
		if RotatingPart then
			table.insert(connections, RotatingPart.Touched:connect(OnHit))
		end
		if FlameHolder then
			table.insert(connections, FlameHolder.Touched:connect(OnHit))
		end
	end
	
	
	--[[
	while wait() do
	for i = -1, 1, 1 do
     local ray = Ray.new(myTorso.CFrame * Vector3.new(i, -i, 0), myTorso.CFrame.lookVector * 4)
     --DebugShowRay(ray)
     local hitPart, hitPos = Workspace:FindPartOnRayWithIgnoreList(ray, {MyCharacter})
     if hit then
			OnHit(hit)
     end
	end	
	--]]
	
	-- Temp testing code while we have no anims
	--[[
	local myTorso = MyCharacter:FindFirstChild('Torso')
	if myTorso then
		-- do a triple raycast check
		for i = -1, 1 do
			local rightVector = Vector3.new(0,1,0):Cross(myTorso.CFrame.lookVector)
			local offset = i * rightVector
			local hitPart, hitPos = Workspace:FindPartOnRayWithIgnoreList(Ray.new(myTorso.CFrame.p + offset, myTorso.CFrame.lookVector * 4), {MyCharacter})
			if hitPart then
				OnHit(hitPart)
			end
		end
	end
	--]]
	wait(ATTACK_DURATION)
	if Claw and Claw:FindFirstChild('Mesh') then
		Claw.Mesh.VertexColor = Vector3.new(1,1,1)		
	end
	if IsTool() then
		if SpinMotor then
			SpinMotor.CurrentAngle = 0
			SpinMotor.DesiredAngle = 0
		end
		if ShieldFire then
			ShieldFire.Enabled = false
		end
	end
	for _, connection in pairs(connections) do
		connection:disconnect()
	end
	
	local hitSomething = false
	for humanoid, _ in pairs(HitHumanoids) do
		hitSomething = true
		break		
	end
	if not hitSomething then
		HitsWithoutMissing = 0
	end
	
	
	Attacking = false
end


if IsTool() then
	Tool.Equipped:connect(OnEquipped)
	Tool.Unequipped:connect(OnUnequipped)
	Tool.Activated:connect(OnActivated)
else
	MyCharacter = script.Parent.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	MyMouse = MyPlayer:GetMouse()
	OnEquipped()
	MyMouse.Button1Down:connect(OnActivated)
end

function CreateHitEffect(hitPos)
	local effect = Instance.new('Part')
	effect.Name = 'effect'
	effect.TopSurface = 'Smooth'
	effect.BottomSurface = 'Smooth'
	effect.Transparency = 1
	effect.Anchored = true
	effect.CanCollide = false
	effect.FormFactor = 'Custom'
	effect.Size = Vector3.new(0.2,0.2,0.2)
	effect.CFrame = CFrame.new(hitPos)
	local sparkles = Instance.new('Sparkles')
	sparkles.SparkleColor = Color3.new(1, 0.1, 0)
	sparkles.Parent = effect
	effect.Parent = Workspace
	
	DebrisService:AddItem(effect, 0.39)
end

-- Tool Creation code, may be used later?
--local tool = Game.Selection:Get()[1]; local fh = tool.RotatingPart:Clone(); fh.Name = 'FlameHolder'; local weld = Instance.new('ManualWeld'); weld.Parent = tool.RotatingPart; weld.Part0 = tool.RotatingPart; weld.Part1 = fh;
--local weld = Game.Selection:Get()[1]; weld.C0 = CFrame.new(0, 0, -1) ; weld.C1 = CFrame.Angles(math.pi/2, 0, 0)
