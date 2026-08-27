-------------- Sword Script ----------------
-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

-- super hacks
local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')
local SwordMesh = Handle:WaitForChild('Mesh')
SwordMesh.MeshId = 'http://www.roblox.com/asset/?id=139536155'
SwordMesh.Scale = Vector3.new(1, 1, 1)

--local Shield = WaitForChild(Tool, 'Shield')
local Shield = Instance.new('Part')
Shield.Name = 'Shield'
Shield.FormFactor = Enum.FormFactor.Custom
Shield.Size = Vector3.new(3.4, 4, 0.4)
local ShieldMesh = Instance.new('SpecialMesh')
ShieldMesh.MeshId = 'http://www.roblox.com/asset/?id=139536383'
ShieldMesh.TextureId = 'http://www.roblox.com/asset/?id=139536467'
ShieldMesh.Scale = Vector3.new(1.15, 1.15, 1.15)
ShieldMesh.Parent = Shield

Handle.CFrame = CFrame.new(Vector3.new(16.418, 23.099, 5.5)) * CFrame.Angles(math.rad(65.854), math.rad(-56.774), math.rad(-118.187))
Shield.CFrame = CFrame.new(Vector3.new(16.742, 21.514, 5.252)) * CFrame.Angles(math.rad(9.096), math.rad(-1.083), math.rad(-1.116))

local ShieldWeld = Instance.new('ManualWeld')
ShieldWeld.Name = 'ShieldWeld'
ShieldWeld.Part0 = Shield
ShieldWeld.Part1 = Handle
ShieldWeld.C0 = CFrame.new()
ShieldWeld.C1 = ShieldWeld.Part1.CFrame:inverse() * ShieldWeld.Part0.CFrame
ShieldWeld.Parent = Shield

Shield.Parent = Tool
-- end super hacks

local SWORD_DAMAGE = 37
local STUN_BONUS = 5

------- TOOL GRIP INFOS -----
local GripForward = Vector3.new(0, 0, -1)
local GripPos = Vector3.new(0, -1.35, 0)
local GripRight = Vector3.new(1, 0, 0)
local GripUp = Vector3.new(0, 1, 0)

--------



------- Animations ---------
local ShieldBashAnim = WaitForChild(Tool, "ShieldBash")
local EquipAnim = WaitForChild(Tool, "EquipAnim")
local SlashAnim = WaitForChild(Tool, "QuickSlash")
local ShieldWalkAnim = WaitForChild(Tool, "ShieldWalk")
----------------------------

------- Sounds -------------
local BashHit = WaitForChild(Handle, "BashHit")
local BashMiss = WaitForChild(Handle, "BashMiss")
local PowerUp = WaitForChild(Handle, "PowerUp")
local Slash = WaitForChild(Handle, "Slash")
local Sprint = WaitForChild(Handle, "Sprint")
local SwordDraw = WaitForChild(Handle, "SwordDraw")
local SwordHit = WaitForChild(Handle, "SwordHit")
----------------------------


------- My Character Variables -------
local MyCharacter
local MyHumanoid
local MyPlayer
local MyTorso
local MyMouse
---------------------------------------

local StunScript = WaitForChild(script, "StunScript")

local UnequippedWeld = WaitForChild(Shield, 'ShieldWeld')
local UnequippedWeldCopy = UnequippedWeld:Clone()
local ArmShieldWeld
local BackWeld = nil
local RightGrip = nil

------- Connections ---------
local RightMouseConnection
local ShieldBlowConnection
local SwordBlowConnection
local MouseRightDownConnection
-----------------------------

local MouseRightDownTime = tick()

local Swinging = false
local Bashing = false

print("Finished Loading")

local function AbleToAttack()
	return MyCharacter and MyHumanoid and MyHumanoid.Health > 0
end

function TagHumanoid(humanoid, player)
	-- Add more tags here to customize what tags are available.
	while humanoid:FindFirstChild('creator') do
		humanoid:FindFirstChild('creator'):Destroy()
	end 
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Value = player
	creatorTag.Name = "creator"
	creatorTag.Parent = humanoid
	DebrisService:AddItem(creatorTag, 1.5)
end

local function CloneWithoutChildren(objectToClone)
	local result = objectToClone:Clone()
	for k, v in pairs(result:GetChildren()) do
		v:Destroy()
	end
	return result
end

local WeldedToArm

local function CreateArmWeld()
	if ArmShieldWeld then return end
	if MyCharacter and MyCharacter:FindFirstChild('Left Arm') then
		if not WeldedToArm then
			WeldedToArm = MyCharacter:FindFirstChild('Left Arm').ChildRemoved:connect(function(child) if child.Name == 'ArmWeld' then CreateArmWeld() end end)
		end
		ArmShieldWeld = Instance.new('Weld')
		ArmShieldWeld.Name = "ArmWeld"
		ArmShieldWeld.Part0 = MyCharacter:FindFirstChild('Left Arm')
		ArmShieldWeld.Part1 = Shield
		ArmShieldWeld.C0 = CFrame.new() * CFrame.Angles(-math.pi * 0.5, math.pi * 0.6, 0)
		ArmShieldWeld.C1 = CFrame.new() + Vector3.new(0, 0, 0.5)
		ArmShieldWeld.Parent = MyCharacter:FindFirstChild('Left Arm')

	else
		print('CreateArmWeld: you have no character or no left arm.')
	end
end

local function DestroyArmWeld()
	if ArmShieldWeld then
		ArmShieldWeld:Destroy()
		ArmShieldWeld = nil
	end
	if WeldedToArm then
		WeldedToArm:disconnect()
		WeldedToArm = nil
	end
end

local function CreateBackWeld()
	if MyTorso and Shield then
		print("Creating BackWeld")
		BackWeld = nil
		while MyTorso:FindFirstChild("BackWeld") do
			MyTorso:FindFirstChild("BackWeld"):Destroy()
		end
		BackWeld = Instance.new('Weld')
		BackWeld.Name = "BackWeld"
		BackWeld.Part0 = MyTorso
		BackWeld.Part1 = Shield
		BackWeld.C0 = CFrame.new() * CFrame.Angles(0, math.pi, 0)
		BackWeld.C1 = CFrame.new() + Vector3.new(0, 0, 1)
		BackWeld.Parent = MyTorso
	else
		print("CreateBackWeld: Missing Torso or Shield.")
	end
end

local function DestroyBackWeld()
	if BackWeld then
		print("Destroying BackWeld")
		BackWeld:Destroy()
		BackWeld = nil
	end
end

local function DestroyRightGrip()
	if MyCharacter then
		local MyRightArm = MyCharacter:FindFirstChild('Right Arm')
		if MyRightArm then
			WaitForChild(MyRightArm, "RightGrip")
			RightGrip = MyRightArm:FindFirstChild('RightGrip'):Clone()
			MyRightArm:FindFirstChild('RightGrip'):Destroy()
		end
	end
end

local function ResetRightGrip()
	if RightGrip and MyCharacter then
		local MyRightArm = MyCharacter:FindFirstChild('Right Arm')
		if MyRightArm then
			RightGrip.Parent = MyRightArm
		end
	end
end

local function CreateStunnedGui(player, character)
	if not player or not character or not character:FindFirstChild('Head') then return end
	local bg = Instance.new("BillboardGui")
	bg.Parent = character.Head
	bg.Adornee = character.Head
	-- Same size as Head
	bg.Size = UDim2.new(1, 0, 1, 0)
	-- Above (defaults to inside)
	bg.StudsOffset = Vector3.new(0, 2.5, 0)
	 
	local frame = Instance.new("Frame")
	frame.Parent = bg
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	 
	local text = Instance.new("TextLabel")
	text.Parent = frame
	text.Position = UDim2.new(0.25, 0, 0.25, 0)
	text.Size = UDim2.new(0.5, 0, 0.5, 0)
	text.TextColor3 = Color3.new(1, 39/255, 20/255)
	text.TextStrokeColor3 = Color3.new(1, 225/255, 73/255)
	text.TextStrokeTransparency = 0
	text.BackgroundTransparency = 1
	text.Text = "Stunned!"
	text.FontSize = Enum.FontSize.Size18
	DebrisService:AddItem(bg, 2)
end

local BashedPlayers = {}

function ShieldBashBlow(hit)
	if AbleToAttack() and Bashing then
		if hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') and hit.Parent ~= MyCharacter and not BashedPlayers[hit.Parent] then
			BashedPlayers[hit.Parent] = true
			print("Shield Blow")
			if hit.Parent:FindFirstChild('Torso') and MyTorso then
				
				local bashForce = Instance.new('BodyVelocity')
				bashForce.maxForce = Vector3.new(1000000, 1000000, 1000000)
				if MyTorso.Velocity.magnitude > 0.1 then
					bashForce.velocity = MyTorso.Velocity.unit * 100
				else
				 	bashForce.velocity = (hit.Parent.Torso.CFrame.p - MyTorso.CFrame.p).unit * 100
				end
				bashForce.Parent = hit.Parent.Torso
				DebrisService:AddItem(bashForce, 0.07)
				if MyTorso:FindFirstChild("ChargeVelocity") then
					MyTorso:FindFirstChild("ChargeVelocity"):Destroy()
					MyTorso.Velocity = Vector3.new()
				end
				CreateStunnedGui(PlayersService:GetPlayerFromCharacter(hit.Parent), hit.Parent)
				CreateStunnedGui(MyPlayer, hit.Parent)
			end
			if not hit.Parent:FindFirstChild('StunScript') then
				local stun = StunScript:Clone()
				stun.Parent = hit.Parent
				stun.Disabled = false
			end
			BashHit:Play()
			TagHumanoid(hit.Parent.Humanoid, MyPlayer)
			wait(0.1)
			if MyHumanoid then
				MyHumanoid.PlatformStand = false
			end
		end
	end
end

local function PlayAnimation(Anim, speed)
	if MyHumanoid and Anim then
		print("Playing" , Anim.Name)
		local AnimTrack = MyHumanoid:LoadAnimation(Anim)
		if speed then
			AnimTrack:AdjustSpeed(speed)
		end
		AnimTrack:Play()
		return AnimTrack
	end
	return nil
end

function ShieldBash()
	if tick() - MouseRightDownTime > 0.2 then return end
	if Bashing or UnequippedWeld or not AbleToAttack() then return end
	Bashing = true
	BashedPlayers = {}
	Sprint:Play()
	if MyTorso then
		local chargeForce = Instance.new('BodyVelocity')
		chargeForce.Name = "ChargeVelocity"
		chargeForce.maxForce = Vector3.new(1000000, 1000000, 1000000)
		chargeForce.velocity = (MyMouse.Hit.p * Vector3.new(1, 0, 1) - MyTorso.CFrame.p * Vector3.new(1,0,1)).unit * 150
		chargeForce.Parent = MyTorso
		DebrisService:AddItem(chargeForce, 0.15)
		MyTorso.CFrame = CFrame.new(MyTorso.CFrame.p, MyTorso.CFrame.p + chargeForce.velocity)
		local gyro = Instance.new('BodyGyro')
		gyro.Parent = MyTorso
		DebrisService:AddItem(gyro, 0.3)
	end
	wait(0.1)
	-- Do Animation
	PlayAnimation(ShieldBashAnim, nil)
	print("Bash!")
	BashMiss:Play()
	wait(1.2)
	Bashing = false
end

local bladeHolder 

local function PhaseInBlade()
	if bladeHolder then return end
	bladeHolder = CloneWithoutChildren(Handle)
	bladeHolder.Name = "Blade"
	local theMesh = Instance.new("SpecialMesh")
	theMesh.MeshId = BladeOnlyMesh
	theMesh.Parent = bladeHolder
	theMesh.TextureId = "http://www.roblox.com/asset/?id=92537877"
	theMesh.Scale = Vector3.new(0.7,0,0.7)
	bladeHolder.Parent = Tool
	local theWeld = Instance.new("Weld")
	theWeld.Part0 = bladeHolder
	theWeld.Part1 = Handle
	theWeld.C0 = CFrame.new() + Vector3.new(0, -0.92, 0.09)
	theWeld.Parent = bladeHolder
	PowerUp:Play()
	coroutine.resume(coroutine.create(function()
		for i = 1, 14 do
			if bladeHolder and theMesh then
				theMesh.Scale = theMesh.Scale + Vector3.new(0, 0.05, 0)
			end
			wait(0.03)
		end
	end))
end



function OnEquipped(mouse)
	MyCharacter = Tool.Parent
	MyPlayer = PlayersService.LocalPlayer
	MyHumanoid = WaitForChild(MyCharacter, 'Humanoid')
	MyTorso = WaitForChild(MyCharacter, 'Torso')
	MyMouse = mouse
	Handle.Transparency = 0
	Shield.Transparency = 0
	Tool.GripForward = GripForward
	Tool.GripPos = GripPos
	Tool.GripRight = GripRight
	Tool.GripUp = GripUp
	if MyMouse then
		MouseRightDownConnection = MyMouse.Button2Down:connect(function() MouseRightDownTime = tick() end)
	end
	if MyMouse then
		RightMouseConnection = MyMouse.Button2Up:connect(ShieldBash)
	end
	if Shield then
		ShieldBlowConnection = Shield.Touched:connect(ShieldBashBlow)
		Shield.CanCollide = false
	end
	if Handle then
		SwordBlowConnection = Handle.Touched:connect(SwordAttackBlow)
	end
	wait(0.1)
	coroutine.resume(coroutine.create(DestroyRightGrip))
	CreateBackWeld()
	if UnequippedWeldCopy then
		if UnequippedWeld then UnequippedWeld:Destroy() end
		UnequippedWeld = UnequippedWeldCopy:Clone()
		UnequippedWeld.Parent = Shield
	end
end

local shieldWalk

function OnUnequipped()
	DestroyBackWeld()
	DestroyArmWeld()
	if Shield then
		if UnEquippedWeld then UnequippedWeld:Destroy() end
		UnequippedWeld = nil
		UnequippedWeld = UnequippedWeldCopy:Clone()
		UnequippedWeld.Parent = Shield
	else
		print("Unable to recreate shield weld")
	end
	if bladeHolder then
		bladeHolder:Destroy()
		bladeHolder = nil
	end
	if RightMouseConnection then
		RightMouseConnection:disconnect()
		RightMouseConnection = nil
	end
	if MouseRightDownConnection then
		MouseRightDownConnection:disconnect()
		MouseRightDownConnection = nil
	end
	if ShieldBlowConnection then
		ShieldBlowConnection:disconnect()
		ShieldBlowConnection = nil
	end
	if SwordBlowConnection then
		SwordBlowConnection:disconnect()
		SwordBlowConnection = nil
	end
	if Shield then
		Shield.CanCollide = true
	end
	if RightGrip then
		RightGrip:Destroy()
		RightGrip = nil
	end
	if shieldWalk then
		print("Stopping shield walk")
		shieldWalk:Stop()
	end
end

local SlashedPlayers = {}

function SwordAttackBlow(hit)
	if Swinging and AbleToAttack() then
		if hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') and hit.Parent ~= MyCharacter and not SlashedPlayers[hit.Parent] then
			SlashedPlayers[hit.Parent] = true
			TagHumanoid(hit.Parent.Humanoid, MyPlayer)
			SwordHit:Play()
			hit.Parent.Humanoid:TakeDamage(SWORD_DAMAGE)
			-- if stunned
			if hit.Parent:FindFirstChild('StunScript') then
				hit.Parent.Humanoid:TakeDamage(STUN_BONUS)
			end
		end
	end
end


function OnActivate()
	if Swinging or not AbleToAttack() then return end
	local dontWait = false
	if UnequippedWeld then
		dontWait = true
		shieldWalk = PlayAnimation(ShieldWalkAnim, nil)
		--wait(0.4)
		if UnequippedWeld then UnequippedWeld:Destroy() end
		UnequippedWeld = nil
		while Shield:FindFirstChild('ShieldWeld') do
			Shield:FindFirstChild('ShieldWeld'):Destroy()
		end
		SwordDraw:Play()
		DestroyBackWeld()
		--PhaseInBlade()
	else
		PlayAnimation(SlashAnim, nil)
	end
	CreateArmWeld()
	ResetRightGrip()
	SlashedPlayers = {}
	Swinging = true
	if Slash then
		Slash:Play()
	end
	--PlayAnimation(SlashAnim, nil)
	if not dontWait then wait(0.8) end

	Swinging = false
end


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivate)
