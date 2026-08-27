--[[
	Fixed by ArceusInator 1/26/2015
	
	Thanks to Europeancow2 for reporting a bug where the kick attach would break NPCs
--]]

-------------- Sword Script ----------------
-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local GLib = require(206209239)
local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')
local Shield = WaitForChild(Tool, 'Shield')

local SWORD_DAMAGE = 25
local STUN_BONUS = 10

------- MESH IDs -----------
-- Preload these meshes
local BladeOnlyMesh = 'http://www.roblox.com/asset/?id=92541982'
local SwordOnlyMesh = 'http://www.roblox.com/asset/?id=96669672'
local CompleteMesh = 'http://www.roblox.com/asset/?id=92542016'
----------------------------

------- Animations ---------
local ShieldBashAnim = WaitForChild(Tool, "ShieldBash")
local EquipAnim = WaitForChild(Tool, "EquipAnim")
local SlashAnim = WaitForChild(Tool, "QuickSlash")
local ShieldWalkAnim = WaitForChild(Tool, "ShieldWalk")
local KickAnim = WaitForChild(Tool, "Kick")
----------------------------

------- Sounds -------------
local BashHit = WaitForChild(Handle, "BashHit")
local BashMiss = WaitForChild(Handle, "BashMiss")
local PowerUp = WaitForChild(Handle, "PowerUp")
local Slash = WaitForChild(Handle, "Slash")
local Sprint = WaitForChild(Handle, "Sprint")
local SwordDraw = WaitForChild(Handle, "SwordDraw")
local SwordHit = WaitForChild(Handle, "SwordHit")
local KickSound = WaitForChild(Handle, "Kick")
local YellSound = WaitForChild(Handle, "Yell")
----------------------------


------- My Character Variables -------
local MyCharacter
local MyHumanoid
local MyPlayer
local MyTorso
local MyMouse
---------------------------------------

local KickedScript = WaitForChild(script, "KickedScript")

WaitForChild(Shield, 'ShieldWeld'):Destroy()
local UnequippedWeld = WaitForChild(Shield, 'ShieldWeldBack')
UnequippedWeld.Part0 = Shield
UnequippedWeld.Part1 = Handle
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

local PitPart=Instance.new('Part')
PitPart.Transparency=1
PitPart.Size=Vector3.new(14, 0.2, 15)
	local PitDecal=Instance.new('Decal')
	PitDecal.Texture='http://www.roblox.com/asset/?id=96622746'
	PitDecal.Face='Top'
	PitDecal.Parent=PitPart
	local FallingSound = Instance.new('Sound')
	FallingSound.Volume=1
	FallingSound.SoundId='http://www.roblox.com/asset/?id=96636143'
	FallingSound.Parent=PitPart
PitPart.CanCollide=false
PitPart.Anchored=true



local MouseRightDownTime = tick()

local Swinging = false
local Bashing = false

print("Finished Loading")

function AbleToAttack()
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

function CloneWithoutChildren(objectToClone)
	local result = objectToClone:Clone()
	for k, v in pairs(result:GetChildren()) do
		v:Destroy()
	end
	return result
end

local WeldedToArm

function CreateArmWeld()
	if ArmShieldWeld then return end
	if MyCharacter and MyCharacter:FindFirstChild('Left Arm') then
		if not WeldedToArm then
			WeldedToArm = MyCharacter:FindFirstChild('Left Arm').ChildRemoved:connect(function(child) if child.Name == 'ArmWeld' then CreateArmWeld() end end)
		end
		ArmShieldWeld = Instance.new('Weld')
		ArmShieldWeld.Name = "ArmWeld"
		ArmShieldWeld.Part0 = MyCharacter:FindFirstChild('Left Arm')
		ArmShieldWeld.Part1 = Shield
		ArmShieldWeld.C0 = CFrame.new() * CFrame.Angles(math.rad(-70), math.rad(70), 0)
		ArmShieldWeld.C1 = CFrame.new() + Vector3.new(0, 0, .6)
		ArmShieldWeld.Parent = MyCharacter:FindFirstChild('Left Arm')

	else
		print('CreateArmWeld: you have no character or no left arm.')
	end
end

function DestroyArmWeld()
	if ArmShieldWeld then
		ArmShieldWeld:Destroy()
		ArmShieldWeld = nil
	end
	if WeldedToArm then
		WeldedToArm:disconnect()
		WeldedToArm = nil
	end
end

function CreateBackWeld()
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
		BackWeld.C0 = CFrame.new() * CFrame.Angles(0, math.rad(180), 0)
		BackWeld.C1 = CFrame.new() + Vector3.new(0, 0, 1.2)
		BackWeld.Parent = MyTorso
	else
		print("CreateBackWeld: Missing Torso or Shield.")
	end
end

function DestroyBackWeld()
	if BackWeld then
		print("Destroying BackWeld")
		BackWeld:Destroy()
		BackWeld = nil
	end
end

function DestroyRightGrip()
	if MyCharacter then
		local MyRightArm = MyCharacter:FindFirstChild('Right Arm')
		if MyRightArm then
			WaitForChild(MyRightArm, "RightGrip")
			RightGrip = MyRightArm:FindFirstChild('RightGrip'):Clone()
			MyRightArm:FindFirstChild('RightGrip'):Destroy()
		end
	end
end

function ResetRightGrip()
	if RightGrip and MyCharacter then
		local MyRightArm = MyCharacter:FindFirstChild('Right Arm')
		if MyRightArm then
			RightGrip.Parent = MyRightArm
		end
	end
end

local BashedPlayers = {}

function MakePit(torso)
	local dirVector=Vector3.new(torso.CFrame.p.x-script.Parent.Parent.Torso.CFrame.p.x,0,torso.CFrame.p.z-script.Parent.Parent.Torso.CFrame.p.z).unit
	PitPart.CFrame=CFrame.new(torso.CFrame.p+(dirVector*8)+Vector3.new(0,-3.3,0))
	PitPart.Parent=script.Parent
end

function SetCamera(length,pdir,target)
	local startTime=time()
	local cam= game.Workspace.CurrentCamera
	local normalDir=math.atan2(pdir.z,pdir.x)+math.pi/2
	local position=((MyTorso.CFrame.p+target)/2)+Vector3.new(math.cos(normalDir)*10,5,math.sin(normalDir)*10)
	while time()-startTime<length do
		cam.CameraType='Scriptable'
		cam.CoordinateFrame=CFrame.new(position,target)
		wait()
	end
	cam.CameraType='Custom'
end

local InTheAwesome=false
function THISISROBLOX(hit)
	if InTheAwesome then return end
	InTheAwesome=true
	if hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') and hit.Parent ~= MyCharacter and game:GetService'Players':GetPlayerFromCharacter(hit.Parent)~=nil and not GLib.IsTeammate(MyPlayer, GLib.GetPlayerFromPart(hit)) then
			
			TagHumanoid(hit.Parent.Humanoid, MyPlayer)
			
			if not hit.Parent:FindFirstChild('KickedScript') then
				local inKick=true
				local LockedPos=CFrame.new(script.Parent.Parent.Torso.CFrame.p,hit.Parent.Torso.CFrame.p)
				local EnemyLockedPos=CFrame.new(hit.Parent.Torso.CFrame.p,script.Parent.Parent.Torso.CFrame.p)
				Spawn(function()
					while inKick do
						MyTorso.CFrame=LockedPos
						hit.Parent.Torso.CFrame=EnemyLockedPos
						wait()
					end
				end)
				Spawn(function() SetCamera(5,hit.Parent.Torso.CFrame.p-MyTorso.CFrame.p,hit.Parent.Torso.CFrame.p)
				end)
				MakePit(hit.Parent.Torso)
				print('Adding kicked script')
				local kicked = KickedScript:Clone()
				kicked.Parent = hit.Parent
				kicked.Disabled = false
				YellSound:Play()
				wait(2.3)
				Tool.Animate:FireClient(MyPlayer, 'Kick', 'Play', .1, 1, 4)
				wait(1)
				--ADDFORCE
				local bashForce = Instance.new('BodyVelocity')
				bashForce.maxForce = Vector3.new(1000000, 0, 1000000)
				bashForce.velocity = (hit.Parent.Torso.CFrame.p - MyTorso.CFrame.p).unit * 40
				bashForce.Parent = hit.Parent.Torso
				--PLAY KICK SOUND
				KickSound:Play()
				Wait(.2)
				FallingSound:Play()
				inKick=false
				delay(6,function() PitPart.Parent=nil end)
				wait(2)
			end
			
		end
		InTheAwesome=false
end

function PlayAnimation(Anim, speed)
	if MyHumanoid and Anim then
		print("Playing" , Anim.Name)
		if speed then
			Tool.Animate:FireClient(MyPlayer, Anim.Name, 'AdjSpeed', speed)
		end
		Tool.Animate:FireClient(MyPlayer, Anim.Name, 'Play')
	end
	return nil
end

function ShieldBash(hit)
	if tick() - MouseRightDownTime > 0.2 or InTheAwesome then return end
	if Bashing or UnequippedWeld or not AbleToAttack() then return end
	Bashing = true
	BashedPlayers = {}
	Sprint:Play()
	if MyTorso then
		local chargeForce = Instance.new('BodyVelocity')
		chargeForce.Name = "ChargeVelocity"
		chargeForce.maxForce = Vector3.new(1000000, 1000000, 1000000)
		chargeForce.velocity = (hit.p * Vector3.new(1, 0, 1) - MyTorso.CFrame.p * Vector3.new(1,0,1)).unit * 150
		chargeForce.Parent = MyTorso
		DebrisService:AddItem(chargeForce, 0.15)
		MyTorso.CFrame = CFrame.new(MyTorso.CFrame.p, MyTorso.CFrame.p + chargeForce.velocity)
		local gyro = Instance.new('BodyGyro')
		gyro.Parent = MyTorso
		DebrisService:AddItem(gyro, 0.3)
	end
	wait(0.1)
	-- Do Animation
	Tool.Animate:FireClient(MyPlayer, 'ShieldBashAnim', 'Play')
	print("Bash!")
	BashMiss:Play()
	wait(1.2)
	Bashing = false
end

local bladeHolder 

function PhaseInBlade() end


Tool.Input.OnServerEvent:connect(function(client, name, ...)
	if client == MyPlayer then
		if name == 'Mouse2' then
			local down, hit = ...
			
			if down then
				MouseRightDownTime = tick()
			else
				ShieldBash(hit)
			end
		elseif name == 'Mouse1' then
			local down = ...
			
			if down then
				OnActivate()
			end
		end
	end
end)

function OnEquipped()
	print('Equipped')
	MyCharacter = Tool.Parent
	MyPlayer = PlayersService:GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = WaitForChild(MyCharacter, 'Humanoid')
	MyTorso = WaitForChild(MyCharacter, 'Torso')
	if Shield then
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
	if Handle:FindFirstChild('Mesh') then
		Handle.Mesh.MeshId = SwordOnlyMesh
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

local HitEnabled=true
function SwordAttackBlow(hit)
	if Swinging and AbleToAttack() and HitEnabled then
		HitEnabled=false
		if hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') and hit.Parent ~= MyCharacter and not SlashedPlayers[hit.Parent] and not GLib.IsTeammate(MyPlayer, GLib.GetPlayerFromPart(hit)) then
			SlashedPlayers[hit.Parent] = true
			TagHumanoid(hit.Parent.Humanoid, MyPlayer)
			
			if hit.Parent.Humanoid.Health<25 then
				THISISROBLOX(hit)
			else
				SwordHit:Play()
				hit.Parent.Humanoid:TakeDamage(SWORD_DAMAGE)
			end
		end
		HitEnabled=true
	end
end


function OnActivate()
	if not Tool.Enabled or InTheAwesome then return end
	Tool.Enabled=false
	print('In OnActivate')
	if Swinging or not AbleToAttack() then return end
	local dontWait = false
	if UnequippedWeld then
		dontWait = true
		Tool.Animate:FireClient(MyPlayer, 'ShieldWalk', 'Play')
		--wait(0.4)
		if UnequippedWeld then UnequippedWeld:Destroy() end
		UnequippedWeld = nil
		while Shield:FindFirstChild('ShieldWeld') do
			Shield:FindFirstChild('ShieldWeld'):Destroy()
		end
		SwordDraw:Play()
		if Handle:FindFirstChild('Mesh') then
			--Handle.Mesh.MeshId = CompleteMesh
		end
		DestroyBackWeld()
	else
		Tool.Animate:FireClient(MyPlayer, 'QuickSlash', 'Play', .1, 1, 4)
	end
	CreateArmWeld()
	ResetRightGrip()
	SlashedPlayers = {}
	Swinging = true
	--Slash:Play()
	--PlayAnimation(SlashAnim, nil)
	if not dontWait then wait(0.8) end

	Swinging = false
	Tool.Enabled=true
end


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
--Tool.Activated:connect(OnActivate)