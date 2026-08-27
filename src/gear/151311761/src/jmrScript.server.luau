-----------------------
--|    Variables    |--
-----------------------
local Tool = script.Parent
local Handle = Tool:WaitForChild('Handle')
local DebrisService = Game:GetService('Debris')
local Players = Game:GetService('Players')
local TheCharacter = nil
--
local HitPlayers = {}
local RemoteEvents = Tool:WaitForChild('RemoteEvents')
local OnKilledPlayer = RemoteEvents:WaitForChild('OnKilledPlayer')

-----------------------
--|    Constants    |--
-----------------------
local BASE_DMG = 25
local MAX_DMG = 100
local MAX_CHARGE_TIME = 1.5
local FIRE_OFFSET = Vector3.new(1.25, 1.5, -6.25)
local SPEED = 50
--
local ChargeModifier = 0
local ChargeStartTime = 0

-- Returns a character ancestor and its Humanoid, or nil
local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

local function FindCharacterFace()
	if TheCharacter then
		local head = TheCharacter:FindFirstChild('Head')
		if head then
			local face = head:FindFirstChild('face')
			return face
		end
	end
end

local function FireCannonBall(position, velocity)
	local p = Instance.new('Part')
	p.FormFactor = Enum.FormFactor.Custom
	p.Size = Vector3.new(1, 1, 1)
	p.BrickColor = BrickColor.new('Black')
	p.CanCollide = false
	p.CFrame = CFrame.new(position)
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	
	local mesh = Instance.new('SpecialMesh')
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	
	local bodyVelocity = Instance.new('BodyVelocity')
	bodyVelocity.velocity = velocity
	bodyVelocity.Parent = p
	
	local smoke = Instance.new('Smoke')
	smoke.Color = Color3.new(141/255, 141/255, 141/255)
	smoke.Parent = p
	
	p.Touched:connect(function(other)
		local hitCharacter, hitHumanoid = FindCharacterAncestor(other)
		local thisCharacter = nil
		if Tool.Parent then
			thisCharacter = Tool.Parent
		end
		if hitCharacter == thisCharacter then
			return
		end
		local dmg = (BASE_DMG * 2) * ChargeModifier + BASE_DMG
		if dmg >= 100 then
			local player = Players:GetPlayerFromCharacter(thisCharacter)
			OnKilledPlayer:FireClient(player)
			local e = Instance.new('Explosion')
			e.Position = other.Position
			e.Parent = Workspace
			DebrisService:AddItem(e, 2)
		end
		if HitPlayers.hitCharacter then
			return
		end
		--
		if hitCharacter and hitHumanoid and hitHumanoid.Health > 0 then
			HitPlayers.hitCharacter = true
			hitHumanoid:TakeDamage(dmg)
			p.Parent = nil
			Delay(1, function()
				if HitPlayers.hitCharacter then
					HitPlayers.hitCharacter = nil
				end
			end)
		end
	end)
	
	DebrisService:AddItem(smoke, 2.5)
	
	p.Parent = Workspace
	DebrisService:AddItem(p, 3)
end

-----------------------
--|  Remote Events  |--
-----------------------
local FireEvent = RemoteEvents:WaitForChild('OnFire')
local ChargeEvent = RemoteEvents:WaitForChild('OnCharge')

local function OnFire()
	local character = Tool.Parent
	local torso = character:FindFirstChild('Torso')
	local pos = Vector3.new()
	if torso then
		pos = (torso.CFrame:inverse() * torso.Position) + FIRE_OFFSET
		pos = torso.CFrame * pos
		local direction = Vector3.new(Handle.CFrame.lookVector.x, 0, Handle.CFrame.lookVector.z).unit
		FireCannonBall(pos, direction * SPEED)
		ChargeModifier = ChargeStartTime > 0 and math.min(tick() - ChargeStartTime, MAX_CHARGE_TIME) or 0
		ChargeStartTime = 0
	end
end

local function OnCharge()
	ChargeStartTime = tick()
end

local CachedFace = nil
local function OnEquip()
	TheCharacter = Tool.Parent
	local face = FindCharacterFace()
	if face then
		CachedFace = face.Texture
		face.Texture = 'http://www.roblox.com/asset/?id=19366214'
	end
end

local function OnUnequip()
	local face = FindCharacterFace()
	if face and CachedFace then
		face.Texture = CachedFace
	end
end

FireEvent.OnServerEvent:connect(OnFire)
ChargeEvent.OnServerEvent:connect(OnCharge)
Tool.Equipped:connect(OnEquip)
Tool.Unequipped:connect(OnUnequip)
