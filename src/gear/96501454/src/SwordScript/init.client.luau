-------------- Sword Script ----------------
-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local PlayersService = Game:GetService('Players')
local DebrisService = Game:GetService('Debris')

local Tool = script.Parent
local Handle = WaitForChild(Tool, 'Handle')

local SWORD_DAMAGE = 40
local STUN_BONUS = 15

local INTERVAL_BETWEEN_LIGHTNING = 5
local LIGHTNING_RADIUS = 1
local MAX_SHOOTING_DISTANCE = 50


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


------- Connections ---------
local RightMouseConnection
local ShieldBlowConnection
local SwordBlowConnection
local MouseRightDownConnection
-----------------------------

local MouseRightDownTime = tick()

local LightningPart = Instance.new("Part")
LightningPart.Name = "Lightning"
LightningPart.FormFactor = 3
LightningPart.Size = Vector3.new(1, 1, 10)
LightningPart.Anchored = true

local LightningMesh = Instance.new("SpecialMesh")
LightningMesh.Scale = Vector3.new(0.6, 0.7, 0.6)
LightningMesh.MeshId = "http://www.roblox.com/asset/?id=65419828"
LightningMesh.TextureId = "http://www.roblox.com/asset/?id=65419395"
LightningMesh.VertexColor = Vector3.new(0.6, 1, 0.7)
LightningMesh.Parent = LightningPart


local Swinging = false


print("Finished Loading")

local function AbleToAttack()
	return MyCharacter and MyHumanoid and MyHumanoid.Health > 0 and MyTorso:FindFirstChild('Right Shoulder')
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

local function PointOnCircle(originX, originZ, radius, theta)
	local X = originX + radius * math.cos(theta)
	local Z = originZ + radius * math.sin(theta)
	return X, Z
end

-- It is conceptually easier to construct the lightning beam pointing up along
-- the pos-y axis and then rotate each point by the direction vector
local function CreateLightningBeam(start, direction, distance)
	local boltList = {}
	distance = math.min(MAX_SHOOTING_DISTANCE, math.max(distance, INTERVAL_BETWEEN_LIGHTNING))
	direction = direction.unit
	local orientationCFrame = CFrame.new(Vector3.new(), direction.unit) * CFrame.Angles(0, -math.pi / 2, math.pi / 2)
	for i = 1, distance / INTERVAL_BETWEEN_LIGHTNING do
		local currOrigin = Vector3.new(0, INTERVAL_BETWEEN_LIGHTNING, 0) * i
		local nextOrigin = Vector3.new(0, INTERVAL_BETWEEN_LIGHTNING, 0) * (i + 1)
		local rotationRandomness = math.random() * math.pi / 2
		for j = 1, 4 do
			local currX, currZ = PointOnCircle(currOrigin.x, currOrigin.z, LIGHTNING_RADIUS, (math.pi / 2) * j + rotationRandomness)
			local nextX, nextZ = PointOnCircle(nextOrigin.x, nextOrigin.z, LIGHTNING_RADIUS, (math.pi / 2) * (j+1) + rotationRandomness)
			local currBolt = Instance.new('Part')
			currBolt.Anchored = true
			currBolt.Size = Vector3.new(0.2, 0.2, INTERVAL_BETWEEN_LIGHTNING * 1.2)
			currBolt.CanCollide = false
			currBolt.Transparency = math.min(1, (math.random() + 0.5) / 2 + 0.08)
			table.insert(boltList, currBolt)
			local currPoint = Vector3.new(currX, currOrigin.Y, currZ)
			local nextPoint = Vector3.new(nextX, nextOrigin.Y, nextZ)
			-- Adjust because the part is centered in the middle not the tip
			currPoint = currPoint + ((nextPoint - currPoint).unit * (currBolt.Size.Y / 2))
			currPoint = (orientationCFrame * currPoint) + start
			nextPoint = (orientationCFrame * nextPoint) + start
			currBolt.CFrame = CFrame.new(currPoint, nextPoint) * CFrame.Angles(0, 0, -math.pi / 2)
			LightningMesh:Clone().Parent = currBolt
			DebrisService:AddItem(currBolt, 0.8)
			currBolt.Parent = Workspace
		end
	end
	for i = 1, 3 do
		Spawn(function()
			for k, v in pairs(boltList) do
				if v then
					if k % 4 == 0 then
						wait(0.05)
					end
					v.Transparency = v.Transparency / 3
				end
			end
		end)
		Delay(0.1, function()
			for k, v in pairs(boltList) do
				if v then
					if k % 4 == 0 then
						wait(0.05)
					end
					v.Transparency = v.Transparency * 3
				end
			end
		end)
		wait(0.3)
	end
end

local function CloneWithoutChildren(objectToClone)
	local result = objectToClone:Clone()
	for k, v in pairs(result:GetChildren()) do
		v:Destroy()
	end
	return result
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


function OnEquipped(mouse)
	MyCharacter = Tool.Parent
	MyPlayer = PlayersService.LocalPlayer
	MyHumanoid = WaitForChild(MyCharacter, 'Humanoid')
	MyTorso = WaitForChild(MyCharacter, 'Torso')
	MyMouse = mouse
	if MyMouse then
		MouseRightDownConnection = MyMouse.Button2Down:connect(function() MouseRightDownTime = tick() end)
	end
	if MyMouse then
		RightMouseConnection = MyMouse.Button2Up:connect(ShieldBash)
	end
	if Handle then
		SwordBlowConnection = Handle.Touched:connect(SwordAttackBlow)
	end
end


function OnUnequipped()
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
	endghtGrip = nil
	end
	if shieldWalk then
		print("Stopping shield walk")
		shieldWalk:Stop()
	end
end

local SlashedPlayers = {}

function SwordAttackBlow(hit)
	if Swinging and AbleToAttack() then
		if hit and hit.Parent and hit.Parent:FindFirstChild('Humanoid') and
				hit.Parent:FindFirstChild('Torso') and hit.Parent ~= MyCharacter and
				not SlashedPlayers[hit.Parent] then
			SlashedPlayers[hit.Parent] = true
			TagHumanoid(hit.Parent.Humanoid, MyPlayer)
			SwordHit:Play()
			-- if stunned
			if hit.Parent:FindFirstChild('StunScript') and hit.Parent.Humanoid.WalkSpeed == 0 then
				hit.Parent.Humanoid:TakeDamage(STUN_BONUS)
			end
			hit.Parent.Humanoid:TakeDamage(SWORD_DAMAGE)

			if not hit.Parent:FindFirstChild('StunScript') then
				CreateStunnedGui(PlayersService:GetPlayerFromCharacter(hit.Parent), hit.Parent)
				CreateStunnedGui(MyPlayer, hit.Parent)
				local stun = StunScript:Clone()
				stun.Parent = hit.Parent
				stun.Disabled = false
			end
			if #SlashedPlayers < 2 then
				CreateLightningBeam(hit.Parent.Torso.CFrame.p + Vector3.new(0, MAX_SHOOTING_DISTANCE - 7, 0), Vector3.new(0, -1, 0), MAX_SHOOTING_DISTANCE)
			end
		end
	end
end


function OnActivate()
	if Swinging or not AbleToAttack() then return end
	if UnequippedWeld then
		dontWait = true
		shieldWalk = PlayAnimation(ShieldWalkAnim, nil)
		--wait(0.4)
		if UnequippedWeld then UnequippedWeld:Destroy() end
		UnequippedWeld = nil
		SwordDraw:Play()
	else
		PlayAnimation(SlashAnim, nil)
	end
	SlashedPlayers = {}
	Swinging = true
	wait(2)
	--Slash:Play()
	--PlayAnimation(SlashAnim, nil)
	Swinging = false
end


Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivate)
